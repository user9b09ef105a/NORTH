param(
  [Parameter(Mandatory=$true)][string]$Workspace,
  [switch]$Force
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'data-common.ps1')
$repo = Get-NorthRepoRoot
$workspaceFull = [IO.Path]::GetFullPath($Workspace)
if (-not (Test-Path -LiteralPath $workspaceFull -PathType Container)) { throw "Workspace not found: $workspaceFull" }
[void](Read-NorthOwnership -Root $workspaceFull)
if (Test-Path -LiteralPath (Join-Path $repo '.git')) {
  $dirty = @(git -C $repo status --porcelain)
  $sourceDirty = @()
  foreach ($line in $dirty) {
    if ($line.Length -lt 4) { continue }
    $path = $line.Substring(3).Trim().Replace('\','/')
    $isData = $path.StartsWith('_posts/') -or $path.StartsWith('_drafts/') -or $path.StartsWith('assets/media/') -or ($path -eq '_data/profile.json')
    if (-not $isData) { $sourceDirty += $line }
  }
  if ($sourceDirty.Count -gt 0 -and -not $Force) {
    throw "Source-owned files have uncommitted changes. Commit/stash them first, or rerun with -Force:`n$($sourceDirty -join "`n")"
  }
}
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = Join-Path $repo ".north\backups\NORTH_Data_PreSourceApply_$stamp.zip"
[void](New-NorthDataPack -Repo $repo -Destination $backup -Purpose 'pre-source-apply')
Write-Host "Safety data backup: $backup" -ForegroundColor DarkGray
Copy-NorthSourceOwnedTree -SourceRoot $workspaceFull -DestinationRoot $repo
Write-Host 'Source-only update applied. Real posts, drafts, media, and profile were preserved.' -ForegroundColor Green
& (Join-Path $repo 'scripts\test-powershell.ps1')
& (Join-Path $repo 'scripts\check.ps1')
