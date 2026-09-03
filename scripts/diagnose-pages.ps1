param(
  [Parameter(Mandatory = $true)]
  [string]$SiteUrl
)

$ErrorActionPreference = 'Stop'
$base = $SiteUrl.TrimEnd('/')
$paths = @(
  '/',
  '/assets/css/main.css',
  '/assets/js/site.js',
  '/library/',
  '/topics/',
  '/projects/',
  '/archive/',
  '/search/',
  '/search.json',
  '/feed.xml',
  '/feed-en.xml',
  '/feed-fa.xml',
  '/sitemap.xml'
)

Write-Host 'NORTH Pages diagnostics' -ForegroundColor Cyan
Write-Host ("Base URL: {0}" -f $base) -ForegroundColor DarkGray

$failed = $false
foreach ($path in $paths) {
  if ($path -eq '/') {
    $url = "$base/"
  }
  else {
    $url = "$base$path"
  }

  try {
    $response = Invoke-WebRequest `
      -Uri $url `
      -Method Get `
      -MaximumRedirection 5 `
      -UseBasicParsing

    $statusCode = [int]$response.StatusCode
    if ($statusCode -ge 200 -and $statusCode -lt 400) {
      Write-Host ("[OK {0}] {1}" -f $statusCode, $url) -ForegroundColor Green
    }
    else {
      $failed = $true
      Write-Host ("[FAIL {0}] {1}" -f $statusCode, $url) -ForegroundColor Red
    }
  }
  catch {
    $failed = $true
    $message = $_.Exception.Message
    Write-Host ("[FAIL] {0} - {1}" -f $url, $message) -ForegroundColor Red
  }
}

if ($failed) {
  throw 'One or more NORTH Pages diagnostic checks failed.'
}

Write-Host 'All NORTH Pages diagnostic checks passed.' -ForegroundColor Green
