param(
  [Parameter(Mandatory=$true)][string]$Pack,
  [switch]$NoSafetyBackup
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'data-common.ps1')
$repo = Get-NorthRepoRoot
$manifest = Import-NorthDataPackInternal -Repo $repo -Pack $Pack -NoSafetyBackup:$NoSafetyBackup
Write-Host "Imported NORTH data pack created $($manifest.created_utc)." -ForegroundColor Green
& (Join-Path $PSScriptRoot 'check.ps1')
