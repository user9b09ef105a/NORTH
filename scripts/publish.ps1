param(
  [Parameter(Mandatory = $true)]
  [string]$Message,

  [string]$BaseBranch = 'main',
  [string]$Remote = 'origin',
  [string]$Branch = '',
  [ValidateSet('rebase','squash')]
  [string]$MergeMethod = 'rebase',
  [string]$PrTitle = '',
  [string]$PrBody = '',
  [switch]$NoMerge,
  [switch]$SkipPostMergeChecks
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
Set-Location $repo

function Invoke-NativeChecked {
  param(
    [Parameter(Mandatory = $true)][string]$File,
    [Parameter(Mandatory = $true)][string[]]$Arguments,
    [switch]$Capture
  )

  if ($Capture) {
    $output = @(& $File @Arguments 2>&1)
    $code = $LASTEXITCODE
    if ($code -ne 0) {
      $details = ($output | ForEach-Object { "$_" }) -join "`n"
      throw ("Command failed ({0}): {1} {2}`n{3}" -f $code, $File, ($Arguments -join ' '), $details)
    }
    return (($output | ForEach-Object { "$_" }) -join "`n").Trim()
  }

  & $File @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw ("Command failed ({0}): {1} {2}" -f $LASTEXITCODE, $File, ($Arguments -join ' '))
  }
}

function Convert-ToBranchSlug {
  param([string]$Value)

  $slug = $Value.ToLowerInvariant() -replace '[^a-z0-9]+', '-'
  $slug = $slug -replace '^-|-$', ''
  if ([string]::IsNullOrWhiteSpace($slug)) { $slug = 'publish' }
  if ($slug.Length -gt 42) {
    $slug = $slug.Substring(0, 42) -replace '-+$', ''
  }
  return $slug
}

function Get-CurrentBranch {
  $name = Invoke-NativeChecked -File 'git' -Arguments @('branch','--show-current') -Capture
  if ([string]::IsNullOrWhiteSpace($name)) {
    throw 'Detached HEAD is not supported by NORTH Publish. Switch to main or a normal content branch first.'
  }
  return $name.Trim()
}

function Wait-ForPrChecks {
  param(
    [int]$Number,
    [string]$Repository
  )

  Write-Host 'Waiting for GitHub pull-request checks...' -ForegroundColor Cyan
  $checksAppeared = $false
  for ($attempt = 0; $attempt -lt 30; $attempt++) {
    $json = Invoke-NativeChecked -File 'gh' -Arguments @(
      'pr','view',"$Number",'--repo',$Repository,'--json','statusCheckRollup'
    ) -Capture
    $state = $json | ConvertFrom-Json
    if (@($state.statusCheckRollup).Count -gt 0) {
      $checksAppeared = $true
      break
    }
    Start-Sleep -Seconds 4
  }

  if (-not $checksAppeared) {
    throw 'No pull-request checks appeared within two minutes. The PR is left open; inspect GitHub Actions before merging.'
  }

  & gh pr checks $Number --repo $Repository --watch
  if ($LASTEXITCODE -ne 0) {
    throw 'One or more pull-request checks failed. The PR is left open and was not merged.'
  }

  $json = Invoke-NativeChecked -File 'gh' -Arguments @(
    'pr','view',"$Number",'--repo',$Repository,'--json','statusCheckRollup'
  ) -Capture
  $state = $json | ConvertFrom-Json
  $quality = @($state.statusCheckRollup | Where-Object { $_.name -eq 'Quality' -and $_.workflowName -eq 'NORTH Quality Gate' })
  if ($quality.Count -eq 0) {
    throw 'The required NORTH Quality Gate / Quality check was not reported. The PR is left open.'
  }
  if ($quality[0].conclusion -ne 'SUCCESS') {
    throw ("NORTH Quality Gate did not succeed (conclusion: {0}). The PR is left open." -f $quality[0].conclusion)
  }
}

function Wait-ForWorkflowRun {
  param(
    [string]$Repository,
    [string]$Commit,
    [string]$WorkflowName
  )

  $run = $null
  for ($attempt = 0; $attempt -lt 36; $attempt++) {
    $json = Invoke-NativeChecked -File 'gh' -Arguments @(
      'run','list','--repo',$Repository,'--commit',$Commit,'--event','push','--limit','20',
      '--json','databaseId,workflowName,status,conclusion,url'
    ) -Capture
    $runs = @($json | ConvertFrom-Json)
    $run = @($runs | Where-Object { $_.workflowName -eq $WorkflowName } | Select-Object -First 1)
    if ($run.Count -gt 0) {
      $run = $run[0]
      break
    }
    Start-Sleep -Seconds 5
  }

  if ($null -eq $run) {
    Write-Warning "GitHub did not report '$WorkflowName' within three minutes. The merge succeeded; verify Actions manually."
    return
  }

  Write-Host ("Watching {0}..." -f $WorkflowName) -ForegroundColor Cyan
  & gh run watch $run.databaseId --repo $Repository --exit-status
  if ($LASTEXITCODE -ne 0) {
    throw ("The content was merged, but '{0}' failed. Inspect: {1}" -f $WorkflowName, $run.url)
  }

  Write-Host ("{0}: passed" -f $WorkflowName) -ForegroundColor Green
}

if (-not (Test-Path -LiteralPath '.git')) {
  throw 'This folder is not a Git repository.'
}
if (Test-Path -LiteralPath '.north-workspace.json') {
  throw 'Publishing is disabled inside a NORTH upgrade/sample workspace. Apply source changes back to the live repository first.'
}
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  throw 'Git is required but was not found in PATH.'
}
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  throw 'GitHub CLI (gh) is required for protected publishing. Install/authenticate gh, then run NORTH Publish again.'
}

# Confirm GitHub CLI authentication before changing branches or committing anything.
Invoke-NativeChecked -File 'gh' -Arguments @('auth','status') | Out-Null
$repository = Invoke-NativeChecked -File 'gh' -Arguments @('repo','view','--json','nameWithOwner','--jq','.nameWithOwner') -Capture
if ([string]::IsNullOrWhiteSpace($repository)) {
  throw 'Could not resolve the GitHub repository from the current working tree.'
}

Invoke-NativeChecked -File 'git' -Arguments @('remote','get-url',$Remote) -Capture | Out-Null
Write-Host ("NORTH protected publish -> {0}" -f $repository) -ForegroundColor Cyan

# Fetch first so a publication is never based unknowingly on a stale main branch.
Invoke-NativeChecked -File 'git' -Arguments @('fetch',$Remote,'--prune')
$currentBranch = Get-CurrentBranch
$createdBranch = $false

if ($currentBranch -eq $BaseBranch) {
  $workingState = Invoke-NativeChecked -File 'git' -Arguments @('status','--porcelain=v1','--untracked-files=all') -Capture
  $mainAheadText = Invoke-NativeChecked -File 'git' -Arguments @('rev-list','--count',"$Remote/$BaseBranch..HEAD") -Capture
  $mainBehindText = Invoke-NativeChecked -File 'git' -Arguments @('rev-list','--count',"HEAD..$Remote/$BaseBranch") -Capture
  $mainAhead = [int]$mainAheadText.Trim()
  $mainBehind = [int]$mainBehindText.Trim()

  if ($mainAhead -gt 0) {
    throw ("Local {0} contains {1} commit(s) not present on {2}/{0}. NORTH will not guess how to reconcile protected main. Preserve/reconcile those commits first, then publish again." -f $BaseBranch, $mainAhead, $Remote)
  }

  if ($mainBehind -gt 0) {
    if ([string]::IsNullOrWhiteSpace($workingState)) {
      Write-Host ("Synchronizing {0} with {1}/{0}..." -f $BaseBranch, $Remote) -ForegroundColor DarkGray
      Invoke-NativeChecked -File 'git' -Arguments @('pull','--ff-only',$Remote,$BaseBranch)
    }
    else {
      throw ("{0} is behind {1}/{0} and the working tree has changes. Preserve your work, synchronize main, then publish again." -f $BaseBranch, $Remote)
    }
  }

  if ([string]::IsNullOrWhiteSpace($Branch)) {
    $slug = Convert-ToBranchSlug $Message
    $Branch = "content/{0}-{1}" -f (Get-Date -Format 'yyyyMMdd-HHmmss'), $slug
  }

  $existingLocal = Invoke-NativeChecked -File 'git' -Arguments @('branch','--list',$Branch) -Capture
  if (-not [string]::IsNullOrWhiteSpace($existingLocal)) {
    throw "Local branch already exists: $Branch"
  }

  Invoke-NativeChecked -File 'git' -Arguments @('switch','-c',$Branch)
  $currentBranch = $Branch
  $createdBranch = $true
  Write-Host ("Created protected publishing branch: {0}" -f $currentBranch) -ForegroundColor Green
}
elseif (-not [string]::IsNullOrWhiteSpace($Branch) -and $Branch -ne $currentBranch) {
  throw ("You are already on branch '{0}', but -Branch requested '{1}'. Switch branches or omit -Branch." -f $currentBranch, $Branch)
}

if ($currentBranch -eq $BaseBranch) {
  throw 'NORTH Publish will not commit directly to the protected base branch.'
}

# Validate all tracked and untracked publishable material before staging. This
# catches secrets, oversized media, bad metadata, and source integrity problems.
& (Join-Path $PSScriptRoot 'check.ps1')
if ($LASTEXITCODE -ne 0) { throw 'NORTH source checks failed.' }

Invoke-NativeChecked -File 'git' -Arguments @('add','--all')
Invoke-NativeChecked -File 'git' -Arguments @('diff','--cached','--check')
$staged = Invoke-NativeChecked -File 'git' -Arguments @('diff','--cached','--name-only') -Capture

if (-not [string]::IsNullOrWhiteSpace($staged)) {
  Write-Host 'Staged publication:' -ForegroundColor Cyan
  Write-Host $staged -ForegroundColor DarkGray
  Invoke-NativeChecked -File 'git' -Arguments @('commit','-m',$Message)
}

$aheadText = Invoke-NativeChecked -File 'git' -Arguments @('rev-list','--count',"$Remote/$BaseBranch..HEAD") -Capture
$ahead = 0
if (-not [int]::TryParse($aheadText.Trim(), [ref]$ahead)) {
  throw "Could not determine commits ahead of $Remote/$BaseBranch."
}

if ($ahead -lt 1) {
  Write-Host 'Nothing to publish.' -ForegroundColor Yellow
  if ($createdBranch) {
    Invoke-NativeChecked -File 'git' -Arguments @('switch',$BaseBranch)
    Invoke-NativeChecked -File 'git' -Arguments @('branch','-D',$currentBranch)
  }
  exit 0
}

# Re-run the staged/source validation after the commit so the exact branch state
# going to GitHub is known-good.
& (Join-Path $PSScriptRoot 'check.ps1')
if ($LASTEXITCODE -ne 0) { throw 'NORTH checks failed after commit.' }

Invoke-NativeChecked -File 'git' -Arguments @('push','-u',$Remote,$currentBranch)

$existingJson = Invoke-NativeChecked -File 'gh' -Arguments @(
  'pr','list','--repo',$repository,'--head',$currentBranch,'--base',$BaseBranch,
  '--state','open','--limit','1','--json','number,url'
) -Capture
$existing = @(
  $existingJson |
    ConvertFrom-Json |
    Where-Object {
      $null -ne $_ -and
      [int]$_.number -gt 0 -and
      -not [string]::IsNullOrWhiteSpace([string]$_.url)
    }
)

if ($existing.Count -gt 0) {
  $prNumber = [int]$existing[0].number
  $prUrl = [string]$existing[0].url
  Write-Host ("Using existing pull request #{0}: {1}" -f $prNumber, $prUrl) -ForegroundColor Cyan
}
else {
  if ([string]::IsNullOrWhiteSpace($PrTitle)) { $PrTitle = $Message }
  if ([string]::IsNullOrWhiteSpace($PrBody)) {
    $PrBody = @"
Automated by the NORTH protected publishing workflow.

- Source branch: $currentBranch
- Local NORTH checks: passed
- Required GitHub Quality Gate: must pass before merge
- Merge strategy: $MergeMethod
"@
  }

  $prUrl = Invoke-NativeChecked -File 'gh' -Arguments @(
    'pr','create','--repo',$repository,'--base',$BaseBranch,'--head',$currentBranch,
    '--title',$PrTitle,'--body',$PrBody
  ) -Capture

  $prJson = Invoke-NativeChecked -File 'gh' -Arguments @(
    'pr','view',$currentBranch,'--repo',$repository,'--json','number,url'
  ) -Capture
  $pr = $prJson | ConvertFrom-Json
  $prNumber = [int]$pr.number
  $prUrl = [string]$pr.url
  Write-Host ("Created pull request #{0}: {1}" -f $prNumber, $prUrl) -ForegroundColor Green
}

Wait-ForPrChecks -Number $prNumber -Repository $repository

if ($NoMerge) {
  Write-Host ("Quality passed. PR #{0} is ready for manual review/merge: {1}" -f $prNumber, $prUrl) -ForegroundColor Green
  exit 0
}

$mergeFlag = if ($MergeMethod -eq 'squash') { '--squash' } else { '--rebase' }
& gh pr merge $prNumber --repo $repository $mergeFlag --delete-branch
if ($LASTEXITCODE -ne 0) {
  throw ("Quality passed, but repository policy did not allow an immediate merge. PR #{0} remains open: {1}" -f $prNumber, $prUrl)
}

$mergedJson = Invoke-NativeChecked -File 'gh' -Arguments @(
  'pr','view',"$prNumber",'--repo',$repository,'--json','state,mergedAt,mergeCommit,url'
) -Capture
$merged = $mergedJson | ConvertFrom-Json
if ($merged.state -ne 'MERGED') {
  throw ("GitHub did not report PR #{0} as merged. Inspect: {1}" -f $prNumber, $prUrl)
}
$mergeCommit = [string]$merged.mergeCommit.oid

Invoke-NativeChecked -File 'git' -Arguments @('switch',$BaseBranch)
Invoke-NativeChecked -File 'git' -Arguments @('fetch',$Remote)
Invoke-NativeChecked -File 'git' -Arguments @('pull','--ff-only',$Remote,$BaseBranch)

$localBranch = Invoke-NativeChecked -File 'git' -Arguments @('branch','--list',$currentBranch) -Capture
if (-not [string]::IsNullOrWhiteSpace($localBranch)) {
  # Rebase/squash merges create a new commit SHA, so -D is intentional here.
  Invoke-NativeChecked -File 'git' -Arguments @('branch','-D',$currentBranch)
}
Invoke-NativeChecked -File 'git' -Arguments @('remote','prune',$Remote)

Write-Host ("Merged PR #{0}. Local {1} is synchronized." -f $prNumber, $BaseBranch) -ForegroundColor Green

if (-not $SkipPostMergeChecks) {
  Wait-ForWorkflowRun -Repository $repository -Commit $mergeCommit -WorkflowName 'NORTH Quality Gate'
  Wait-ForWorkflowRun -Repository $repository -Commit $mergeCommit -WorkflowName 'Deploy NORTH to GitHub Pages'
}

Write-Host ''
Write-Host 'NORTH publication complete.' -ForegroundColor Green
Write-Host ("Repository: {0}" -f $repository) -ForegroundColor DarkGray
Write-Host ("Pull request: {0}" -f $prUrl) -ForegroundColor DarkGray
Write-Host ("Main commit: {0}" -f $mergeCommit) -ForegroundColor DarkGray
