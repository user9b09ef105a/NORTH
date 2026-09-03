param([string]$Destination = '')
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'data-common.ps1')
$repo = Get-NorthRepoRoot
Ensure-NorthLocalWorkspace -Repo $repo
if ([string]::IsNullOrWhiteSpace($Destination)) {
  $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
  $Destination = Join-Path $repo ".north\backups\NORTH_Data_Backup_$stamp.zip"
}
$pack = New-NorthDataPack -Repo $repo -Destination $Destination -Purpose 'backup'
Write-Host "Backup created: $pack" -ForegroundColor Green
