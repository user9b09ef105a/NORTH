$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$posts = @(Get-ChildItem -LiteralPath (Join-Path $repo '_posts') -Filter '*.md' -File)

function Get-FrontMatterValue {
  param(
    [string]$Text,
    [string]$Name
  )
  if ($Text -match "(?m)^${Name}:\s*[`"']?([^`"'\r\n]+)") {
    return $Matches[1].Trim()
  }
  return ''
}

$rows = @()
foreach ($post in $posts) {
  $text = Get-Content -LiteralPath $post.FullName -Raw -Encoding UTF8
  $date = Get-FrontMatterValue -Text $text -Name 'date'
  $rows += [pscustomobject]@{
    File   = $post.Name
    Lang   = Get-FrontMatterValue -Text $text -Name 'lang'
    Domain = Get-FrontMatterValue -Text $text -Name 'domain'
    Nature = Get-FrontMatterValue -Text $text -Name 'nature'
    Kind   = Get-FrontMatterValue -Text $text -Name 'kind'
    Media  = Get-FrontMatterValue -Text $text -Name 'media_type'
    Date   = $date
  }
}

Write-Host 'NORTH content report' -ForegroundColor Cyan
Write-Host ("Total published: {0}" -f $rows.Count)

foreach ($field in @('Lang','Domain','Nature','Kind','Media')) {
  Write-Host "`n$field" -ForegroundColor DarkCyan
  $rows |
    Group-Object $field |
    Sort-Object Count -Descending |
    Select-Object Count, Name |
    Format-Table -AutoSize
}

Write-Host "`nBy year" -ForegroundColor DarkCyan
$rows |
  ForEach-Object {
    if ($_.Date -match '^(\d{4})') {
      [pscustomobject]@{ Year = $Matches[1] }
    }
  } |
  Group-Object Year |
  Sort-Object Name -Descending |
  Select-Object Count, Name |
  Format-Table -AutoSize

Write-Host "`nBy month" -ForegroundColor DarkCyan
$rows |
  ForEach-Object {
    if ($_.Date -match '^(\d{4}-\d{2})') {
      [pscustomobject]@{ Month = $Matches[1] }
    }
  } |
  Group-Object Month |
  Sort-Object Name -Descending |
  Select-Object Count, Name |
  Format-Table -AutoSize
