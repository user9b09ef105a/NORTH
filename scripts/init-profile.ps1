param(
  [string]$Repo = '',
  [switch]$Force
)
$ErrorActionPreference = 'Stop'
$repo = if ([string]::IsNullOrWhiteSpace($Repo)) { Split-Path -Parent $PSScriptRoot } else { [IO.Path]::GetFullPath($Repo) }
$profilePath = Join-Path $repo '_data\profile.json'
if ((Test-Path -LiteralPath $profilePath -PathType Leaf) -and -not $Force) {
  Write-Host "Profile already exists: $profilePath" -ForegroundColor Yellow
  exit 0
}
$configPath = Join-Path $repo '_config.yml'
$aboutPath = Join-Path $repo 'about.md'
$configLines = if (Test-Path -LiteralPath $configPath) { @(Get-Content -LiteralPath $configPath -Encoding UTF8) } else { @() }
$about = if (Test-Path -LiteralPath $aboutPath) { Get-Content -LiteralPath $aboutPath -Raw -Encoding UTF8 } else { '' }

function Clean-YamlScalar {
  param([string]$Value)
  if ($null -eq $Value) { return '' }
  $v = $Value.Trim()
  if ($v.Length -ge 2) {
    if (($v.StartsWith('"') -and $v.EndsWith('"')) -or ($v.StartsWith("'") -and $v.EndsWith("'"))) {
      $v = $v.Substring(1, $v.Length - 2)
    }
  }
  return $v
}

function Get-TopScalar {
  param([string]$Name, [string]$Default)
  foreach ($line in $configLines) {
    if ($line -match ('^' + [regex]::Escape($Name) + ':\s*(.*)$')) {
      return (Clean-YamlScalar $Matches[1])
    }
  }
  return $Default
}

function Get-BlockScalar {
  param([string]$Parent, [string]$Child, [string]$Default)
  $inside = $false
  foreach ($line in $configLines) {
    if ($line -match ('^' + [regex]::Escape($Parent) + ':\s*$')) {
      $inside = $true
      continue
    }
    if ($inside -and $line -match '^\S') { break }
    if ($inside -and $line -match ('^\s{2}' + [regex]::Escape($Child) + ':\s*(.*)$')) {
      return (Clean-YamlScalar $Matches[1])
    }
  }
  return $Default
}

$name = Get-BlockScalar 'author' 'name' 'north'
$descriptionEn = Get-TopScalar 'description' 'A bilingual public knowledge system.'
$descriptionFa = Get-TopScalar 'description_fa' ''
$statementEn = Get-TopScalar 'statement' 'Find what matters. Keep what matters.'
$statementFa = Get-TopScalar 'statement_fa' ''
$github = Get-BlockScalar 'links' 'github' ''
$linkedin = Get-BlockScalar 'links' 'linkedin' ''
$x = Get-BlockScalar 'links' 'x' ''
$aboutEn = $descriptionEn
$aboutFa = $descriptionFa
$m = [regex]::Match($about, '(?s)<div\s+data-lang-copy="en"[^>]*>(.*?)</div>')
if ($m.Success) { $aboutEn = $m.Groups[1].Value.Trim() }
$m = [regex]::Match($about, '(?s)<div\s+data-lang-copy="fa"[^>]*>(.*?)</div>')
if ($m.Success) { $aboutFa = $m.Groups[1].Value.Trim() }
$profile = [ordered]@{
  name = $name
  description_en = $descriptionEn
  description_fa = $descriptionFa
  statement_en = $statementEn
  statement_fa = $statementFa
  links = [ordered]@{
    github = $github
    linkedin = $linkedin
    x = $x
  }
  about_en = $aboutEn
  about_fa = $aboutFa
}
New-Item -ItemType Directory -Path (Split-Path -Parent $profilePath) -Force | Out-Null
[IO.File]::WriteAllText($profilePath, ($profile | ConvertTo-Json -Depth 6), (New-Object Text.UTF8Encoding($false)))
Write-Host "Profile initialized: $profilePath" -ForegroundColor Green
Write-Host 'From now on this file is data-owned and preserved by source-only upgrades.' -ForegroundColor DarkGray
