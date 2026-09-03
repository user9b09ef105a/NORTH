$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
Set-Location $repo

$required = @(
  '_config.yml',
  '_data/taxonomy.yml',
  'index.md',
  'library.md',
  'assets/css/main.css',
  'assets/js/site.js',
  'assets/js/intelligence.js',
  'assets/brand/north-banner.webp',
  'assets/brand/north-profile.webp',
  'assets/brand/north-social-card.jpg',
  '.github/workflows/pages.yml',
  'feed-en.xml',
  'feed-fa.xml',
  'north.version.json',
  'north.ownership.json',
  'LICENSE',
  'CONTRIBUTING.md',
  'docs/PUBLISHING.md',
  'docs/DATA_LIFECYCLE.md',
  '.github/PULL_REQUEST_TEMPLATE.md',
  '.github/workflows/quality.yml',
  '.github/ISSUE_TEMPLATE/bug_report.yml',
  '.github/ISSUE_TEMPLATE/feature_request.yml',
  '.github/ISSUE_TEMPLATE/knowledge_contribution.yml',
  '.github/ISSUE_TEMPLATE/config.yml',
  '_data/profile.json',
  '_data/profile.example.json',
  '_sample-data/profile.json',
  'scripts/data-common.ps1',
  'scripts/backup-data.ps1',
  'scripts/export-data.ps1',
  'scripts/import-data.ps1',
  'scripts/restore-data.ps1',
  'scripts/create-clean-source.ps1',
  'scripts/new-upgrade-workspace.ps1',
  'scripts/apply-source-update.ps1',
  'scripts/data-status.ps1',
  'scripts/verify-data-pack.ps1',
  'scripts/init-profile.ps1',
  'scripts/performance-report.ps1',
  'scripts/new-content.ps1',
  'scripts/publish-draft.ps1',
  'scripts/publish.ps1',
  'scripts/setup-github.ps1'
)

foreach ($path in $required) {
  $fullPath = Join-Path $repo $path
  if (-not (Test-Path -LiteralPath $fullPath)) {
    throw "Missing required file: $path"
  }
}

# License integrity.
$licenseText = Get-Content -LiteralPath (Join-Path $repo 'LICENSE') -Raw -Encoding UTF8
if ($licenseText -notmatch 'Apache License\s+Version 2\.0') {
  throw 'LICENSE is not the expected Apache License 2.0 text.'
}

# Front-end performance budgets protect NORTH from accidental source bloat.
$performanceBudgets = @{
  'assets/css/main.css' = 100KB
  'assets/js/site.js' = 55KB
  'assets/js/intelligence.js' = 30KB
  'assets/brand/north-banner.webp' = 180KB
}
foreach ($relative in $performanceBudgets.Keys) {
  $asset = Get-Item -LiteralPath (Join-Path $repo $relative)
  if ($asset.Length -gt $performanceBudgets[$relative]) {
    throw ('Performance budget exceeded: {0} is {1:N1} KB (budget {2:N1} KB).' -f $relative, ($asset.Length / 1KB), ($performanceBudgets[$relative] / 1KB))
  }
}

# Parse every PowerShell helper before doing any publishing checks. This catches
# Windows PowerShell 5.1 syntax problems without executing the helper scripts.
$scriptFiles = @(Get-ChildItem -LiteralPath (Join-Path $repo 'scripts') -Filter '*.ps1' -File)
foreach ($scriptFile in $scriptFiles) {
  $scriptBytes = [System.IO.File]::ReadAllBytes($scriptFile.FullName)
  $hasUtf8Bom = (
    $scriptBytes.Length -ge 3 -and
    $scriptBytes[0] -eq 0xEF -and
    $scriptBytes[1] -eq 0xBB -and
    $scriptBytes[2] -eq 0xBF
  )
  $hasNonAscii = $false
  foreach ($scriptByte in $scriptBytes) {
    if ($scriptByte -gt 0x7F) {
      $hasNonAscii = $true
      break
    }
  }
  if ($hasNonAscii -and -not $hasUtf8Bom) {
    throw ('PowerShell encoding validation failed for {0}: non-ASCII content requires a UTF-8 BOM for Windows PowerShell 5.1 compatibility.' -f $scriptFile.Name)
  }

  $tokens = $null
  $parseErrors = $null
  [void][System.Management.Automation.Language.Parser]::ParseFile(
    $scriptFile.FullName,
    [ref]$tokens,
    [ref]$parseErrors
  )
  if ($parseErrors -and $parseErrors.Count -gt 0) {
    $details = ($parseErrors | ForEach-Object {
      '{0}:{1}:{2} {3}' -f $scriptFile.Name, $_.Extent.StartLineNumber, $_.Extent.StartColumnNumber, $_.Message
    }) -join "`n"
    throw "PowerShell syntax validation failed:`n$details"
  }
}

if (Test-Path -LiteralPath '.git') {
  $paths = @(git ls-files --cached --others --exclude-standard)
  if ($LASTEXITCODE -ne 0) {
    throw 'Could not enumerate Git publishable files.'
  }

  $allFiles = @(
    foreach ($path in $paths) {
      $candidate = Join-Path $repo $path
      if (Test-Path -LiteralPath $candidate -PathType Leaf) {
        Get-Item -LiteralPath $candidate -Force
      }
    }
  )
}
else {
  $allFiles = @(
    Get-ChildItem -Path $repo -Recurse -Force -File |
      Where-Object {
        ($_.FullName -notmatch '[\\/]\.git[\\/]') -and
        ($_.FullName -notmatch '[\\/]_drafts[\\/]') -and
        ($_.FullName -notmatch '[\\/]_site[\\/]') -and
        ($_.FullName -notmatch '[\\/]vendor[\\/]') -and
        ($_.FullName -notmatch '[\\/]\.north[\\/]')
      }
  )
}

$forbiddenNames = @('.env', 'id_rsa', 'id_ed25519', 'credentials.json')
$forbiddenExtensions = @('.pem', '.p12', '.pfx')
$bad = @(
  $allFiles | Where-Object {
    ($forbiddenNames -contains $_.Name) -or
    ($forbiddenExtensions -contains $_.Extension.ToLowerInvariant())
  }
)
if ($bad.Count -gt 0) {
  throw "Potential secret/private-key files found. Remove them before publishing:`n$(($bad.FullName) -join "`n")"
}

$large = @($allFiles | Where-Object { $_.Length -gt 50MB })
if ($large.Count -gt 0) {
  $details = ($large | ForEach-Object {
    "{0} ({1:N1} MB)" -f $_.FullName, ($_.Length / 1MB)
  }) -join "`n"
  throw "NORTH caps local publishable files at 50 MB for long-term Pages health. Use external media hosting:`n$details"
}

$warn = @($allFiles | Where-Object { $_.Length -gt 10MB })
if ($warn.Count -gt 0) {
  $details = ($warn | ForEach-Object {
    "{0} ({1:N1} MB)" -f $_.FullName, ($_.Length / 1MB)
  }) -join "`n"
  Write-Warning "Large local files detected (>10 MB):`n$details"
}

$mediaRoot = Join-Path $repo 'assets/media'
$mediaFiles = @(Get-ChildItem -LiteralPath $mediaRoot -Recurse -File -ErrorAction SilentlyContinue)
$mediaBytes = ($mediaFiles | Measure-Object Length -Sum).Sum
if ($null -eq $mediaBytes) { $mediaBytes = 0 }
if ($mediaBytes -gt 500MB) {
  Write-Warning ("Local media is {0:N1} MB. Start moving large/frequent audio and video to external hosting." -f ($mediaBytes / 1MB))
}

$textExtensions = @('.md','.html','.yml','.yaml','.json','.txt','.js','.css','.ps1')
foreach ($file in ($allFiles | Where-Object {
  ($_.Length -lt 2MB) -and ($textExtensions -contains $_.Extension.ToLowerInvariant())
})) {
  $text = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction SilentlyContinue
  if ($text -match '-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----') {
    throw "Private-key material detected: $($file.FullName)"
  }
}

$kinds = @('post','project','note','signal','image','audio','video','document','tweet')
$langs = @('en','fa')
$domains = @('software','architecture','ai','systems','research','product','design','business','career','knowledge','general')
$natures = @('analysis','guide','research','case-study','build-log','reference','opinion','learning','journal','announcement')
$mediaTypes = @('text','image','audio','video','document','link','mixed')

$posts = @(Get-ChildItem -LiteralPath (Join-Path $repo '_posts') -Filter '*.md' -File)
foreach ($post in $posts) {
  $text = Get-Content -LiteralPath $post.FullName -Raw -Encoding UTF8
  if (-not $text.StartsWith('---')) {
    throw "Missing front matter: $($post.Name)"
  }

  foreach ($field in @('title','kind','lang','domain','nature','media_type')) {
    if ($text -notmatch "(?m)^${field}:\s*.+$") {
      throw ('Missing required front-matter field "{0}" in {1}' -f $field, $post.Name)
    }
  }

  if ($text -match '(?m)^lang:\s*(\S+)') {
    $value = $Matches[1].Trim()
    if ($langs -notcontains $value) {
      throw "Unsupported lang '$value' in $($post.Name)"
    }
  }
  if ($text -match '(?m)^kind:\s*(\S+)') {
    $value = $Matches[1].Trim()
    if ($kinds -notcontains $value) {
      throw "Unsupported kind '$value' in $($post.Name)"
    }
  }
  if ($text -match '(?m)^domain:\s*(\S+)') {
    $value = $Matches[1].Trim()
    if ($domains -notcontains $value) {
      throw "Unsupported domain '$value' in $($post.Name). Add it to taxonomy/check tooling before publishing."
    }
  }
  if ($text -match '(?m)^nature:\s*(\S+)') {
    $value = $Matches[1].Trim()
    if ($natures -notcontains $value) {
      throw "Unsupported nature '$value' in $($post.Name)."
    }
  }
  if ($text -match '(?m)^media_type:\s*(\S+)') {
    $value = $Matches[1].Trim()
    if ($mediaTypes -notcontains $value) {
      throw "Unsupported media_type '$value' in $($post.Name)."
    }
  }
}


foreach ($jsonPath in @('north.version.json','north.ownership.json','_data/profile.json')) {
  try {
    $null = Get-Content -LiteralPath (Join-Path $repo $jsonPath) -Raw -Encoding UTF8 | ConvertFrom-Json
  }
  catch {
    throw "Invalid JSON file: $jsonPath"
  }
}

if (Test-Path -LiteralPath (Join-Path $repo '.north-workspace.json')) {
  Write-Warning 'This is a NORTH upgrade/sample workspace. Publishing is intentionally disabled here.'
}

Write-Host 'NORTH checks passed.' -ForegroundColor Green
Write-Host "Published entries: $($posts.Count)" -ForegroundColor DarkGray
Write-Host ("Local media: {0:N1} MB across {1} files" -f ($mediaBytes / 1MB), $mediaFiles.Count) -ForegroundColor DarkGray
Write-Host "Publishable files checked: $($allFiles.Count)" -ForegroundColor DarkGray
