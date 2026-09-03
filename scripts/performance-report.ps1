$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
Set-Location $repo

$targets = @(
  'assets/css/main.css',
  'assets/js/site.js',
  'assets/js/intelligence.js',
  'assets/brand/north-banner.webp',
  'assets/brand/north-profile.webp',
  'assets/brand/north-social-card.jpg'
)

Write-Host 'NORTH front-end performance report' -ForegroundColor Cyan
$total = 0L
foreach ($relative in $targets) {
  $path = Join-Path $repo $relative
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    Write-Host ('[MISS] {0}' -f $relative) -ForegroundColor Yellow
    continue
  }
  $item = Get-Item -LiteralPath $path
  $total += $item.Length
  Write-Host ('{0,8:N1} KB  {1}' -f ($item.Length / 1KB), $relative)
}
Write-Host ''
Write-Host ('Core front-end + brand payload tracked here: {0:N1} KB' -f ($total / 1KB)) -ForegroundColor Green
Write-Host 'Non-essential intelligence.js is loaded only after page load / browser idle.' -ForegroundColor DarkGray
Write-Host 'Library search metadata is normalized once and filter updates use cached records.' -ForegroundColor DarkGray
