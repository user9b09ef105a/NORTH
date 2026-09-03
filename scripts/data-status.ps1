$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'data-common.ps1')
$repo = Get-NorthRepoRoot
Ensure-NorthLocalWorkspace -Repo $repo
$stats = Get-NorthDataStats -Repo $repo
$backups = @(Get-ChildItem -LiteralPath (Join-Path $repo '.north\backups') -Filter '*.zip' -File -ErrorAction SilentlyContinue)
$exports = @(Get-ChildItem -LiteralPath (Join-Path $repo '.north\exports') -Filter '*.zip' -File -ErrorAction SilentlyContinue)
Write-Host 'NORTH data status' -ForegroundColor Cyan
Write-Host ("Version:        {0}" -f (Get-NorthVersion -Repo $repo))
Write-Host ("Posts:          {0}" -f $stats.posts)
Write-Host ("Drafts:         {0}" -f $stats.drafts)
Write-Host ("Media files:    {0}" -f $stats.media_files)
Write-Host ("Media volume:   {0:N1} MB" -f ($stats.media_bytes / 1MB))
Write-Host ("Profile:        {0}" -f $(if ($stats.profile_present) { 'present' } else { 'missing/fallback' }))
Write-Host ("Local backups:  {0}" -f $backups.Count)
Write-Host ("Local exports:  {0}" -f $exports.Count)
if ($backups.Count -gt 0) {
  $latest = $backups | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  Write-Host ("Latest backup:  {0}" -f $latest.FullName) -ForegroundColor DarkGray
}
