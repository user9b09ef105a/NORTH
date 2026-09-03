param(
  [string]$Owner = 'user9b09ef105a',
  [string]$Repo = 'NORTH',
  [ValidateSet('public','private')]
  [string]$Visibility = 'public'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root
$slug = "$Owner/$Repo"

function Require-Command([string]$Name) {
  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    throw "$Name is required but was not found in PATH."
  }
}

function Invoke-Checked {
  param([string]$File, [string[]]$Arguments)
  & $File @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "Command failed ($LASTEXITCODE): $File $($Arguments -join ' ')"
  }
}
function Test-NativeSuccess {
  param(
    [string]$File,
    [string[]]$Arguments
  )

  $previous = $ErrorActionPreference

  try {
    $ErrorActionPreference = 'SilentlyContinue'
    & $File @Arguments *> $null
    return ($LASTEXITCODE -eq 0)
  }
  finally {
    $ErrorActionPreference = $previous
  }
}

Require-Command 'git'
Require-Command 'gh'
Invoke-Checked 'gh' @('auth','status')

# Refuse to overwrite an existing GitHub repository.
$repoExists = Test-NativeSuccess 'gh' @(
  'repo','view',$slug,'--json','name'
)

if ($repoExists) {
  throw "GitHub repository already exists: https://github.com/$slug"
}

Write-Host 'Running NORTH checks...' -ForegroundColor Cyan

try {
  & (Join-Path $PSScriptRoot 'check.ps1')
}
catch {
  throw "NORTH checks failed: $($_.Exception.Message)"
}

if (-not (Test-Path -LiteralPath '.git')) {
  Invoke-Checked 'git' @('init','-b','main')
}
else {
  $branch = (& git branch --show-current).Trim()
  if ($branch -and $branch -ne 'main') {
    throw "Existing Git repository is on '$branch'. Expected main."
  }
  $originExists = Test-NativeSuccess 'git' @(
    'remote','get-url','origin'
  )

  if ($originExists) {
    throw 'An origin remote already exists. This script is intended for first setup only.'
  }
}

Invoke-Checked 'git' @('add','--all')
Invoke-Checked 'git' @('diff','--cached','--check')

$hasHead = Test-NativeSuccess 'git' @(
  'rev-parse','--verify','HEAD'
)

if (-not $hasHead) {
  Invoke-Checked 'git' @(
    'commit',
    '-m',
    'Initial release: NORTH'
  )
}

$visibilityFlag = if ($Visibility -eq 'private') { '--private' } else { '--public' }
Invoke-Checked 'gh' @(
  'repo','create',$slug,$visibilityFlag,
  '--source',$root,
  '--remote','origin',
  '--push',
  '--description','NORTH - bilingual knowledge and publishing site.'
)

# Normal merge behavior for protected pull-request publishing.
& gh repo edit $slug `
  --enable-issues `
  --enable-wiki=false `
  --enable-projects=false `
  --enable-merge-commit=false `
  --enable-squash-merge `
  --enable-rebase-merge `
  --delete-branch-on-merge
if ($LASTEXITCODE -ne 0) {
  Write-Warning 'Some repository settings could not be applied automatically. Review Settings > General.'
}

# Enable Pages using the workflow already present in the repository.
& gh api --method POST "repos/$slug/pages" -f build_type=workflow 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
  Write-Warning 'Pages was not enabled automatically. Use Settings > Pages > GitHub Actions.'
}
else {
  Write-Host 'GitHub Pages enabled.' -ForegroundColor Green
  & gh workflow run 'pages.yml' --repo $slug 2>$null | Out-Null
}

# Wait briefly for the first Quality run so the required check is known to GitHub.
Write-Host 'Waiting for the initial Quality run...' -ForegroundColor Cyan
$qualityRun = ''
for ($i = 0; $i -lt 30; $i++) {
  $qualityRun = (& gh run list --repo $slug --workflow quality.yml --branch main --limit 1 --json databaseId --jq '.[0].databaseId' 2>$null).Trim()
  if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($qualityRun)) { break }
  Start-Sleep -Seconds 4
}
if (-not [string]::IsNullOrWhiteSpace($qualityRun)) {
  & gh run watch $qualityRun --repo $slug --exit-status
  if ($LASTEXITCODE -ne 0) {
    throw 'Initial NORTH Quality run failed. Fix the reported issue before protecting main.'
  }
}
else {
  Write-Warning 'No Quality run was detected yet. Ruleset creation will still be attempted.'
}

# Recommended single-maintainer ruleset.
$ruleset = @{
  name = 'NORTH main protection'
  target = 'branch'
  enforcement = 'active'
  conditions = @{
    ref_name = @{
      include = @('~DEFAULT_BRANCH')
      exclude = @()
    }
  }
  rules = @(
    @{ type = 'deletion' },
    @{ type = 'non_fast_forward' },
    @{ type = 'required_linear_history' },
    @{
      type = 'pull_request'
      parameters = @{
        allowed_merge_methods = @('squash','rebase')
        dismiss_stale_reviews_on_push = $false
        require_code_owner_review = $false
        require_last_push_approval = $false
        required_approving_review_count = 0
        required_review_thread_resolution = $true
      }
    },
    @{
      type = 'required_status_checks'
      parameters = @{
        do_not_enforce_on_create = $true
        required_status_checks = @(@{ context = 'Quality' })
        strict_required_status_checks_policy = $false
      }
    }
  )
}

$temp = Join-Path $env:TEMP ("north-ruleset-{0}.json" -f [guid]::NewGuid().ToString('N'))
try {
  $json = $ruleset | ConvertTo-Json -Depth 10
  $utf8 = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($temp, $json, $utf8)
  & gh api --method POST "repos/$slug/rulesets" --input $temp | Out-Null
  if ($LASTEXITCODE -ne 0) {
    Write-Warning 'The main ruleset could not be created automatically. In GitHub Settings > Rules > Rulesets, protect the default branch by requiring pull requests and the Quality check, blocking force pushes/deletion, and keeping required approvals at 0 for a single maintainer.'
  }
  else {
    Write-Host 'Protected main ruleset created.' -ForegroundColor Green
  }
}
finally {
  Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue
}

Write-Host ''
Write-Host 'NORTH setup complete.' -ForegroundColor Green
Write-Host "Repository: https://github.com/$slug"
if ($Visibility -eq 'public') {
  Write-Host "Pages:      https://$Owner.github.io/$Repo/"
}
Write-Host ''
Write-Host 'Normal workflow:'
Write-Host '  .\\scripts\\new-content.ps1 ...'
Write-Host '  .\\scripts\\publish.ps1 -Message "content: publish update"'
