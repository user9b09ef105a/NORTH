param(
  [Parameter(Mandatory=$true)]
  [string]$Draft,
  [switch]$Open
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$draftDir = Join-Path $repo '_drafts'
$postDir = Join-Path $repo '_posts'

$draftName = $Draft
if (-not [IO.Path]::GetExtension($draftName)) { $draftName += '.md' }
$source = if ([IO.Path]::IsPathRooted($draftName)) { $draftName } else { Join-Path $draftDir $draftName }
if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Draft not found: $source" }

$content = Get-Content -LiteralPath $source -Raw
$match = [regex]::Match($content, '(?s)^---\r?\n(.*?)\r?\n---\r?\n?(.*)$')
if (-not $match.Success) { throw 'Draft is missing valid YAML front matter.' }

$frontMatter = $match.Groups[1].Value.TrimEnd()
$body = $match.Groups[2].Value
if ($frontMatter -notmatch '(?m)^title:\s*.+$') { throw 'Draft is missing title.' }
if ($frontMatter -notmatch '(?m)^kind:\s*.+$') { throw 'Draft is missing kind.' }
if ($frontMatter -notmatch '(?m)^lang:\s*(en|fa)\s*$') { throw 'Draft is missing a supported lang: en or fa.' }

$now = Get-Date
$dateValue = $now.ToString('yyyy-MM-dd HH:mm:ss zzz')
if ($frontMatter -match '(?m)^date:\s*.*$') {
  $frontMatter = [regex]::Replace($frontMatter, '(?m)^date:\s*.*$', "date: $dateValue", 1)
} else {
  $frontMatter += "`ndate: $dateValue"
}

$slug = [IO.Path]::GetFileNameWithoutExtension($source).ToLowerInvariant() -replace '[^a-z0-9]+','-' -replace '^-|-$',''
if ([string]::IsNullOrWhiteSpace($slug)) { throw 'Could not derive a safe slug from the draft filename.' }
$destination = Join-Path $postDir ("{0}-{1}.md" -f $now.ToString('yyyy-MM-dd'), $slug)
if (Test-Path -LiteralPath $destination) { throw "Published destination already exists: $destination" }

$published = "---`n$frontMatter`n---`n`n$body"
Set-Content -LiteralPath $destination -Value $published -Encoding UTF8
Remove-Item -LiteralPath $source

Write-Host "Published draft to $destination" -ForegroundColor Green
Write-Host 'Run NORTH: Publish when ready. The protected workflow will check, branch, open a PR, wait for Quality, merge, and verify deployment.' -ForegroundColor DarkGray
if ($Open) { code $destination }
