$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$scriptFiles = @(Get-ChildItem -LiteralPath (Join-Path $repo 'scripts') -Filter '*.ps1' -File)
$failed = $false

Write-Host 'NORTH PowerShell compatibility test' -ForegroundColor Cyan
foreach ($scriptFile in $scriptFiles) {
  $bytes = [System.IO.File]::ReadAllBytes($scriptFile.FullName)
  $hasUtf8Bom = (
    $bytes.Length -ge 3 -and
    $bytes[0] -eq 0xEF -and
    $bytes[1] -eq 0xBB -and
    $bytes[2] -eq 0xBF
  )
  $hasNonAscii = $false
  foreach ($byte in $bytes) {
    if ($byte -gt 0x7F) {
      $hasNonAscii = $true
      break
    }
  }

  if ($hasNonAscii -and -not $hasUtf8Bom) {
    $failed = $true
    Write-Host ("[FAIL] {0}" -f $scriptFile.Name) -ForegroundColor Red
    Write-Host '  Non-ASCII bytes found without a UTF-8 BOM. Windows PowerShell 5.1 may misread this file.' -ForegroundColor Red
    continue
  }

  $tokens = $null
  $parseErrors = $null
  [void][System.Management.Automation.Language.Parser]::ParseFile(
    $scriptFile.FullName,
    [ref]$tokens,
    [ref]$parseErrors
  )

  if ($parseErrors -and $parseErrors.Count -gt 0) {
    $failed = $true
    Write-Host ("[FAIL] {0}" -f $scriptFile.Name) -ForegroundColor Red
    foreach ($parseError in $parseErrors) {
      Write-Host (
        '  line {0}, column {1}: {2}' -f `
          $parseError.Extent.StartLineNumber,
          $parseError.Extent.StartColumnNumber,
          $parseError.Message
      ) -ForegroundColor Red
    }
  }
  else {
    Write-Host ("[OK]   {0}" -f $scriptFile.Name) -ForegroundColor Green
  }
}

if ($failed) {
  throw 'One or more NORTH PowerShell scripts failed compatibility validation.'
}

Write-Host 'All NORTH PowerShell scripts passed compatibility validation.' -ForegroundColor Green
