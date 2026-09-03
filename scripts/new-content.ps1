param(
  [Parameter(Mandatory = $true)]
  [ValidateSet('post','project','note','signal','image','audio','video','document','tweet')]
  [string]$Type,

  [Parameter(Mandatory = $true)]
  [string]$Title,

  [ValidateSet('en','fa')]
  [string]$Lang = 'en',

  [ValidateSet('software','architecture','ai','systems','research','product','design','business','career','knowledge','general')]
  [string]$Domain = 'general',

  [ValidateSet('analysis','guide','research','case-study','build-log','reference','opinion','learning','journal','announcement')]
  [string]$Nature = 'analysis',

  [ValidateSet('text','image','audio','video','document','link','mixed')]
  [string]$MediaType = '',

  [string]$Slug = '',
  [string]$TranslationKey = '',
  [string[]]$Tags = @(),
  [string[]]$Media = @(),
  [string]$Summary = '',
  [string]$Body = '',
  [string]$BodyFile = '',
  [switch]$Featured,
  [switch]$Draft,
  [switch]$Open,
  [switch]$Publish,
  [string]$PublishMessage = ''
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$date = Get-Date

function Escape-YamlDoubleQuoted {
  param([AllowNull()][string]$Value)
  if ($null -eq $Value) { return '' }
  return $Value.Replace('\', '\\').Replace('"', '\"')
}

function Escape-HtmlAttribute {
  param([AllowNull()][string]$Value)
  if ($null -eq $Value) { return '' }
  return $Value.Replace('&', '&amp;').Replace('"', '&quot;').Replace('<', '&lt;').Replace('>', '&gt;')
}

function Test-ExternalUrl {
  param([string]$Value)
  return $Value -match '^(?i:https?:)?//'
}

function Normalize-LocalMediaPath {
  param([string]$Value)
  $normalized = $Value.Trim().Replace('\', '/')
  if (-not $normalized.StartsWith('/')) {
    $normalized = '/' + $normalized
  }
  return $normalized
}

function Copy-MediaIntoRepo {
  param(
    [string]$SourcePath,
    [int]$Index
  )

  $resolved = Resolve-Path -LiteralPath $SourcePath
  $source = Get-Item -LiteralPath $resolved -Force
  if ($source.PSIsContainer) {
    throw "Media must be a file: $SourcePath"
  }

  $sizeMB = $source.Length / 1MB
  if ($sizeMB -gt 50) {
    throw ("Local media is {0:N1} MB. NORTH caps a local publishable file at 50 MB. Use an external media URL for large audio/video/downloads." -f $sizeMB)
  }
  if ($sizeMB -gt 10) {
    Write-Warning ("Media is {0:N1} MB. It is allowed, but external hosting is recommended for frequent or large media." -f $sizeMB)
  }

  $monthFolder = Join-Path $repo ("assets/media/{0}/{1}" -f $date.ToString('yyyy'), $date.ToString('MM'))
  New-Item -ItemType Directory -Force -Path $monthFolder | Out-Null

  $ext = $source.Extension.ToLowerInvariant()
  $suffix = if ($Index -le 1) { '' } else { '-{0:D2}' -f $Index }
  $destName = "$Slug$suffix$ext"
  $dest = Join-Path $monthFolder $destName
  if (Test-Path -LiteralPath $dest) {
    throw "Media destination already exists: $dest"
  }

  Copy-Item -LiteralPath $source.FullName -Destination $dest
  return "/assets/media/{0}/{1}/{2}" -f $date.ToString('yyyy'), $date.ToString('MM'), $destName
}

function Convert-YouTubeUrlToEmbed {
  param([string]$Url)

  $id = $null
  if ($Url -match '(?i)youtu\.be/([A-Za-z0-9_-]{6,})') {
    $id = $Matches[1]
  }
  elseif ($Url -match '(?i)[?&]v=([A-Za-z0-9_-]{6,})') {
    $id = $Matches[1]
  }
  elseif ($Url -match '(?i)youtube\.com/(?:shorts|embed)/([A-Za-z0-9_-]{6,})') {
    $id = $Matches[1]
  }

  if ($id) {
    return "https://www.youtube-nocookie.com/embed/$id"
  }
  return $null
}

function Get-MediaKind {
  param(
    [string]$Value,
    [string]$FallbackType
  )

  if (Convert-YouTubeUrlToEmbed $Value) { return 'video' }

  $pathOnly = ($Value -split '[?#]')[0]
  $ext = [IO.Path]::GetExtension($pathOnly).ToLowerInvariant()

  if (@('.png','.jpg','.jpeg','.webp','.gif','.avif','.svg') -contains $ext) { return 'image' }
  if (@('.mp3','.wav','.ogg','.m4a','.aac','.flac','.opus') -contains $ext) { return 'audio' }
  if (@('.mp4','.webm','.mov','.m4v','.ogv') -contains $ext) { return 'video' }
  if (@('.pdf','.doc','.docx','.xls','.xlsx','.ppt','.pptx','.odt','.ods','.odp','.txt','.md','.csv') -contains $ext) { return 'document' }

  if (@('image','audio','video','document') -contains $FallbackType) { return $FallbackType }
  if ($FallbackType -eq 'tweet') { return 'link' }
  return 'link'
}

function Read-BodyFromFile {
  param([string]$Path)

  $resolved = Resolve-Path -LiteralPath $Path
  $item = Get-Item -LiteralPath $resolved -Force
  if ($item.PSIsContainer) { throw "BodyFile must be a file: $Path" }

  $raw = Get-Content -LiteralPath $item.FullName -Raw -Encoding UTF8
  $match = [regex]::Match($raw, '(?s)^---\r?\n.*?\r?\n---\r?\n?(.*)$')
  if ($match.Success) {
    return $match.Groups[1].Value.Trim()
  }
  return $raw.Trim()
}

$mediaArgsPresent = @($Media | ForEach-Object { if ($_ -ne $null) { $_.Trim() } } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }).Count -gt 0

if ($Draft -and $Publish) {
  throw 'A local draft cannot be auto-published. Create the draft first, then use publish-draft.ps1 when it is ready.'
}
if (-not [string]::IsNullOrWhiteSpace($Body) -and -not [string]::IsNullOrWhiteSpace($BodyFile)) {
  throw 'Use either -Body or -BodyFile, not both.'
}
if ($Publish -and [string]::IsNullOrWhiteSpace($Body) -and [string]::IsNullOrWhiteSpace($BodyFile) -and (-not $mediaArgsPresent)) {
  throw 'Auto-publish requires completed text via -Body/-BodyFile or at least one media item so NORTH does not publish an empty placeholder entry.'
}

# Generate a safe ASCII slug when none is supplied.
if ([string]::IsNullOrWhiteSpace($Slug)) {
  $Slug = $Title.ToLowerInvariant() -replace '[^a-z0-9]+', '-' -replace '^-|-$', ''
}
if ([string]::IsNullOrWhiteSpace($Slug)) {
  $Slug = "{0}-{1}" -f $Lang, $date.ToString('yyyyMMdd-HHmmss')
}
$Slug = $Slug.ToLowerInvariant() -replace '[^a-z0-9-]+', '-' -replace '-+', '-' -replace '^-|-$', ''
if ([string]::IsNullOrWhiteSpace($Slug)) {
  throw 'Slug could not be generated. Use -Slug with ASCII letters/numbers.'
}

# Helpful defaults for specialized content kinds.
if (($Type -eq 'project') -and ($Nature -eq 'analysis')) { $Nature = 'case-study' }
if (($Type -eq 'note') -and ($Nature -eq 'analysis')) { $Nature = 'learning' }
if (($Type -eq 'signal') -and ($Nature -eq 'analysis')) { $Nature = 'reference' }

$mediaItems = @($Media | ForEach-Object { if ($_ -ne $null) { $_.Trim() } } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
$detectedKinds = @()
$fallbackMediaKind = if (@('image','audio','video','document') -contains $MediaType) { $MediaType } else { $Type }
foreach ($item in $mediaItems) {
  $isExternal = Test-ExternalUrl $item
  $isFile = Test-Path -LiteralPath $item -PathType Leaf
  if (-not $isExternal -and -not $isFile) {
    throw "Media must be an existing local file or an http(s) URL: $item"
  }
  $detectedKinds += Get-MediaKind -Value $item -FallbackType $fallbackMediaKind
}

if ([string]::IsNullOrWhiteSpace($MediaType)) {
  if ($mediaItems.Count -gt 0) {
    $MediaType = switch ($Type) {
      'image'    { 'image' }
      'audio'    { 'audio' }
      'video'    { 'video' }
      'document' { 'document' }
      'tweet'    { 'link' }
      default    { 'mixed' }
    }
  }
  else {
    $MediaType = switch ($Type) {
      'image'    { 'image' }
      'audio'    { 'audio' }
      'video'    { 'video' }
      'document' { 'document' }
      'tweet'    { 'link' }
      default    { 'text' }
    }
  }
}

$folder = if ($Draft) { '_drafts' } else { '_posts' }
$name = if ($Draft) {
  "$Slug.md"
} else {
  "{0}-{1}.md" -f $date.ToString('yyyy-MM-dd'), $Slug
}
$file = Join-Path (Join-Path $repo $folder) $name

if (Test-Path -LiteralPath $file) {
  throw "Already exists: $file"
}

$cleanTags = @()
foreach ($tagArg in $Tags) {
  foreach ($tag in ($tagArg -split ',')) {
    $trimmed = $tag.Trim()
    if ($trimmed) {
      $cleanTags += $trimmed
    }
  }
}

$tagLine = if ($cleanTags.Count -gt 0) {
  '[' + (($cleanTags | ForEach-Object { '"' + (Escape-YamlDoubleQuoted $_) + '"' }) -join ', ') + ']'
} else {
  '[]'
}

$bodyContent = if ($mediaItems.Count -gt 0) { '' } else { 'Write here.' }
if (-not [string]::IsNullOrWhiteSpace($BodyFile)) {
  $bodyContent = Read-BodyFromFile $BodyFile
}
elseif (-not [string]::IsNullOrWhiteSpace($Body)) {
  $bodyContent = $Body.Trim()
}
if ([string]::IsNullOrWhiteSpace($bodyContent) -and $mediaItems.Count -eq 0) { $bodyContent = 'Write here.' }

$mediaBlocks = @()
$imageFrontMatter = ''
$sourceFrontMatter = ''
$htmlTitle = Escape-HtmlAttribute $Title
$copiedMediaCount = 0

for ($i = 0; $i -lt $mediaItems.Count; $i++) {
  $item = $mediaItems[$i]
  $kind = $detectedKinds[$i]
  $isExternal = Test-ExternalUrl $item
  $isFile = Test-Path -LiteralPath $item -PathType Leaf

  if ($Draft -and $isFile) {
    Write-Warning "Local media is not copied for local-only drafts: $item. Add/copy it when publishing the final entry."
    continue
  }

  $siteMedia = $item
  if ($isFile) {
    $copiedMediaCount++
    $siteMedia = Copy-MediaIntoRepo -SourcePath $item -Index $copiedMediaCount
  }

  $local = if ($isFile) { Normalize-LocalMediaPath $siteMedia } else { '' }
  $pathOnly = ($siteMedia -split '[?#]')[0]
  $extension = [IO.Path]::GetExtension($pathOnly).ToLowerInvariant()

  switch ($kind) {
    'image' {
      if ($isFile -and [string]::IsNullOrWhiteSpace($imageFrontMatter)) {
        $imageFrontMatter = "image: `"$(Escape-YamlDoubleQuoted $local)`"`nimage_alt: `"$(Escape-YamlDoubleQuoted $Title)`"`n"
        # The first local image becomes the native NORTH cover image and is
        # already rendered by the post layout, so do not duplicate it inline.
      }
      elseif ($isFile) {
        $mediaBlocks += "<img src=`"{{ '$local' | relative_url }}`" alt=`"$htmlTitle`" loading=`"lazy`" decoding=`"async`">"
      }
      else {
        $mediaBlocks += "<img src=`"$siteMedia`" alt=`"$htmlTitle`" loading=`"lazy`" decoding=`"async`">"
      }
    }

    'audio' {
      if ($isFile) {
        $mediaBlocks += "<audio controls preload=`"metadata`" src=`"{{ '$local' | relative_url }}`"></audio>"
      }
      else {
        $mediaBlocks += "<audio controls preload=`"metadata`" src=`"$siteMedia`"></audio>"
      }
    }

    'video' {
      if ($isExternal) {
        $youtubeEmbed = Convert-YouTubeUrlToEmbed $siteMedia
        if ($youtubeEmbed) {
          $mediaBlocks += "<div class=`"video-embed`"><iframe src=`"$youtubeEmbed`" title=`"$htmlTitle`" loading=`"lazy`" allow=`"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share`" allowfullscreen></iframe></div>"
        }
        else {
          $mediaBlocks += "<video controls playsinline preload=`"metadata`" src=`"$siteMedia`"></video>"
        }
      }
      else {
        $mediaBlocks += "<video controls playsinline preload=`"metadata`" src=`"{{ '$local' | relative_url }}`"></video>"
      }
    }

    'document' {
      if ($isExternal) {
        $mediaBlocks += "[Open document]($siteMedia)"
      }
      elseif ($extension -eq '.pdf') {
        $mediaBlocks += "<iframe class=`"document-embed`" src=`"{{ '$local' | relative_url }}`" title=`"$htmlTitle`"></iframe>`n`n[Download document]({{ '$local' | relative_url }})"
      }
      else {
        $mediaBlocks += "[Download document]({{ '$local' | relative_url }})"
      }
    }

    default {
      $mediaBlocks += "[Open reference]($siteMedia)"
    }
  }

  if (($Type -eq 'tweet') -and [string]::IsNullOrWhiteSpace($sourceFrontMatter)) {
    $sourceFrontMatter = "source_url: `"$(Escape-YamlDoubleQuoted $siteMedia)`"`n"
  }
}

$mediaBlock = ''
if ($mediaBlocks.Count -gt 0) {
  $mediaBlock = "`n`n" + ($mediaBlocks -join "`n`n")
}

$escapedTitle = Escape-YamlDoubleQuoted $Title
$escapedSummary = Escape-YamlDoubleQuoted $Summary
$featuredLine = if ($Featured) { 'featured: true' } else { 'featured: false' }
$dateLine = if ($Draft) { '' } else { "date: $($date.ToString('yyyy-MM-dd HH:mm:ss zzz'))`n" }
$translationLine = if ($TranslationKey) {
  "translation_key: `"$(Escape-YamlDoubleQuoted $TranslationKey)`"`n"
} else {
  ''
}

$front = @"
---
layout: post
title: "$escapedTitle"
${dateLine}kind: $Type
lang: $Lang
domain: $Domain
nature: $Nature
media_type: $MediaType
${translationLine}tags: $tagLine
summary: "$escapedSummary"
$featuredLine
${imageFrontMatter}${sourceFrontMatter}---

$bodyContent$mediaBlock
"@

Set-Content -LiteralPath $file -Value $front -Encoding UTF8
Write-Host "Created $file" -ForegroundColor Green
Write-Host "Language: $Lang | Domain: $Domain | Nature: $Nature | Type: $Type | Media: $MediaType" -ForegroundColor DarkGray

if ($TranslationKey) {
  Write-Host "Translation key: $TranslationKey" -ForegroundColor DarkGray
}
if ($Draft) {
  Write-Host 'This draft is local-only because _drafts/ is ignored by Git.' -ForegroundColor DarkGray
}
if ($copiedMediaCount -gt 0 -and (-not $Draft)) {
  Write-Host ("Copied {0} local media file(s) into assets/media/YYYY/MM." -f $copiedMediaCount) -ForegroundColor DarkGray
}
if ($mediaItems.Count -gt 1) {
  Write-Host ("Mixed-media attachments: {0}" -f $mediaItems.Count) -ForegroundColor DarkGray
}

if ($Open) {
  $code = Get-Command code -ErrorAction SilentlyContinue
  if ($code) {
    code $file
  }
  else {
    Write-Warning "VS Code CLI ('code') is not available in PATH. Open this file manually: $file"
  }
}

if ($Publish) {
  if ([string]::IsNullOrWhiteSpace($PublishMessage)) {
    $PublishMessage = "content: publish $Title"
  }
  Write-Host 'Starting protected NORTH publication workflow...' -ForegroundColor Cyan
  & (Join-Path $PSScriptRoot 'publish.ps1') -Message $PublishMessage
}
