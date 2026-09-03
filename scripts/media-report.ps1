$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$mediaRoot = Join-Path $repo 'assets/media'
$files = @(Get-ChildItem -LiteralPath $mediaRoot -Recurse -File -ErrorAction SilentlyContinue)
$bytes = ($files | Measure-Object Length -Sum).Sum
if ($null -eq $bytes) { $bytes = 0 }

Write-Host 'NORTH media report' -ForegroundColor Cyan
Write-Host ("Local media total: {0:N1} MB ({1} files)" -f ($bytes / 1MB), $files.Count)
Write-Host 'NORTH policy: warn >10 MB/file; block >50 MB/file; prefer external hosting for large/frequent audio and video.' -ForegroundColor DarkGray

if ($files.Count -gt 0) {
  $files |
    Sort-Object Length -Descending |
    Select-Object -First 20 @{Name='MB'; Expression={[math]::Round($_.Length / 1MB, 2)}}, FullName |
    Format-Table -AutoSize
}

$remaining = [math]::Max(0, 900MB - $bytes)
Write-Host ("Approximate room before NORTH's 900 MB safety target: {0:N1} MB" -f ($remaining / 1MB)) -ForegroundColor DarkGray
