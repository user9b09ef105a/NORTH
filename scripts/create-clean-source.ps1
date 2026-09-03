param([string]$Destination = '')
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'data-common.ps1')
$repo = Get-NorthRepoRoot
Ensure-NorthLocalWorkspace -Repo $repo
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
if ([string]::IsNullOrWhiteSpace($Destination)) {
  $Destination = Join-Path $repo ".north\exports\NORTH_Clean_Source_$stamp.zip"
}
$destinationFull = [IO.Path]::GetFullPath($Destination)
$parent = Split-Path -Parent $destinationFull
if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
$temp = Join-Path $repo ('.north\tmp\source-' + [guid]::NewGuid().ToString('N'))
$tree = Join-Path $temp 'north-main'
try {
  New-NorthCleanSourceTree -Repo $repo -DestinationRoot $tree
  if (Test-Path -LiteralPath $destinationFull) { Remove-Item -LiteralPath $destinationFull -Force }
  [IO.Compression.ZipFile]::CreateFromDirectory($tree, $destinationFull, [IO.Compression.CompressionLevel]::Optimal, $true)
  Write-Host "Clean sample-data source created: $destinationFull" -ForegroundColor Green
  Write-Host 'Real posts, drafts, media, profile, Git metadata, secrets, and .north backups are excluded.' -ForegroundColor DarkGray
}
finally {
  if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
}
