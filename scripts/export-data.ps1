param(
  [string]$Destination = '',
  [switch]$ExcludeDrafts,
  [switch]$ExcludeProfile
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'data-common.ps1')
$repo = Get-NorthRepoRoot
Ensure-NorthLocalWorkspace -Repo $repo
if ([string]::IsNullOrWhiteSpace($Destination)) {
  $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
  $Destination = Join-Path $repo ".north\exports\NORTH_Data_Export_$stamp.zip"
}
$pack = New-NorthDataPack -Repo $repo -Destination $Destination -ExcludeDrafts:$ExcludeDrafts -ExcludeProfile:$ExcludeProfile -Purpose 'portable-export'
Write-Host "Portable data pack created: $pack" -ForegroundColor Green
if (-not $ExcludeDrafts) { Write-Host 'This pack includes local drafts. Treat it as private backup data.' -ForegroundColor Yellow }
