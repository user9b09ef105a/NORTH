param(
  [string]$Backup = '',
  [switch]$NoSafetyBackup
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'data-common.ps1')
$repo = Get-NorthRepoRoot
Ensure-NorthLocalWorkspace -Repo $repo
if ([string]::IsNullOrWhiteSpace($Backup)) {
  $latest = Get-ChildItem -LiteralPath (Join-Path $repo '.north\backups') -Filter 'NORTH_Data_*.zip' -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if ($null -eq $latest) { throw 'No NORTH data backup exists yet.' }
  $Backup = $latest.FullName
}
$manifest = Import-NorthDataPackInternal -Repo $repo -Pack $Backup -NoSafetyBackup:$NoSafetyBackup
Write-Host "Restored NORTH data from: $Backup" -ForegroundColor Green
Write-Host "Original pack version: $($manifest.north_version)" -ForegroundColor DarkGray
& (Join-Path $PSScriptRoot 'check.ps1')
