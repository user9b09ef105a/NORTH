param([Parameter(Mandatory=$true)][string]$Pack)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'data-common.ps1')
$repo = Get-NorthRepoRoot
Ensure-NorthLocalWorkspace -Repo $repo
$temp = Join-Path $repo ('.north\tmp\verify-' + [guid]::NewGuid().ToString('N'))
try {
  Expand-NorthZipSafe -ZipPath $Pack -Destination $temp
  $packRoot = Join-Path $temp 'north-data-pack-v1'
  if (-not (Test-Path -LiteralPath $packRoot)) { throw 'Expected north-data-pack-v1 root folder was not found.' }
  $manifest = Test-NorthDataPackFolder -PackRoot $packRoot
  Write-Host 'NORTH data pack verified.' -ForegroundColor Green
  Write-Host ("Created:  {0}" -f $manifest.created_utc) -ForegroundColor DarkGray
  Write-Host ("Version:  {0}" -f $manifest.north_version) -ForegroundColor DarkGray
  Write-Host ("Purpose:  {0}" -f $manifest.purpose) -ForegroundColor DarkGray
}
finally {
  if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
}
