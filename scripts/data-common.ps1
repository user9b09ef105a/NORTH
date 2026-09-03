$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Get-NorthRepoRoot {
  return (Split-Path -Parent $PSScriptRoot)
}

function Get-NorthVersion {
  param([string]$Repo)
  $versionFile = Join-Path $Repo 'north.version.json'
  if (-not (Test-Path -LiteralPath $versionFile -PathType Leaf)) { return 'unknown' }
  try {
    $obj = Get-Content -LiteralPath $versionFile -Raw | ConvertFrom-Json
    return [string]$obj.version
  }
  catch { return 'unknown' }
}

function Ensure-NorthLocalWorkspace {
  param([string]$Repo)
  foreach ($name in @('.north', '.north\backups', '.north\exports', '.north\tmp', '.north\source-backups')) {
    $path = Join-Path $Repo $name
    if (-not (Test-Path -LiteralPath $path)) {
      New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
  }
}

function Copy-NorthTree {
  param(
    [Parameter(Mandatory=$true)][string]$Source,
    [Parameter(Mandatory=$true)][string]$Destination,
    [string[]]$ExcludeNames = @()
  )
  if (-not (Test-Path -LiteralPath $Source)) { return }
  if (-not (Test-Path -LiteralPath $Destination)) {
    New-Item -ItemType Directory -Path $Destination -Force | Out-Null
  }
  Get-ChildItem -LiteralPath $Source -Force | ForEach-Object {
    if ($ExcludeNames -notcontains $_.Name) {
      $dest = Join-Path $Destination $_.Name
      if ($_.PSIsContainer) {
        Copy-Item -LiteralPath $_.FullName -Destination $dest -Recurse -Force
      }
      else {
        Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
      }
    }
  }
}

function Get-NorthRelativePath {
  param([string]$Root, [string]$FullName)
  $rootFull = [IO.Path]::GetFullPath($Root).TrimEnd([char[]]'\/') + [IO.Path]::DirectorySeparatorChar
  $fileFull = [IO.Path]::GetFullPath($FullName)
  if (-not $fileFull.StartsWith($rootFull, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Path is outside root: $FullName"
  }
  return $fileFull.Substring($rootFull.Length).Replace('\','/')
}

function Get-NorthDataStats {
  param([string]$Repo)
  $posts = @(Get-ChildItem -LiteralPath (Join-Path $Repo '_posts') -Filter '*.md' -File -ErrorAction SilentlyContinue)
  $drafts = @(Get-ChildItem -LiteralPath (Join-Path $Repo '_drafts') -Filter '*.md' -File -ErrorAction SilentlyContinue)
  $media = @(Get-ChildItem -LiteralPath (Join-Path $Repo 'assets\media') -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne 'north-social-card.jpg' })
  $mediaBytes = ($media | Measure-Object Length -Sum).Sum
  if ($null -eq $mediaBytes) { $mediaBytes = 0 }
  return [ordered]@{
    posts = $posts.Count
    drafts = $drafts.Count
    media_files = $media.Count
    media_bytes = [int64]$mediaBytes
    profile_present = (Test-Path -LiteralPath (Join-Path $Repo '_data\profile.json') -PathType Leaf)
  }
}

function Copy-NorthDataToFolder {
  param(
    [Parameter(Mandatory=$true)][string]$Repo,
    [Parameter(Mandatory=$true)][string]$DataRoot,
    [switch]$ExcludeDrafts,
    [switch]$ExcludeProfile
  )
  New-Item -ItemType Directory -Path $DataRoot -Force | Out-Null
  Copy-NorthTree -Source (Join-Path $Repo '_posts') -Destination (Join-Path $DataRoot '_posts')
  if (-not $ExcludeDrafts) {
    Copy-NorthTree -Source (Join-Path $Repo '_drafts') -Destination (Join-Path $DataRoot '_drafts')
  }
  Copy-NorthTree -Source (Join-Path $Repo 'assets\media') -Destination (Join-Path $DataRoot 'assets\media') -ExcludeNames @('north-social-card.jpg')
  if (-not $ExcludeProfile) {
    $profile = Join-Path $Repo '_data\profile.json'
    if (Test-Path -LiteralPath $profile -PathType Leaf) {
      $profileDest = Join-Path $DataRoot '_data\profile.json'
      New-Item -ItemType Directory -Path (Split-Path -Parent $profileDest) -Force | Out-Null
      Copy-Item -LiteralPath $profile -Destination $profileDest -Force
    }
  }
}

function Write-NorthChecksums {
  param([string]$PackRoot)
  $lines = @()
  $files = @(Get-ChildItem -LiteralPath $PackRoot -Recurse -File | Where-Object { $_.Name -ne 'checksums.sha256' } | Sort-Object FullName)
  foreach ($file in $files) {
    $relative = Get-NorthRelativePath -Root $PackRoot -FullName $file.FullName
    $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    $lines += "$hash *$relative"
  }
  [IO.File]::WriteAllLines((Join-Path $PackRoot 'checksums.sha256'), $lines, (New-Object Text.UTF8Encoding($false)))
}

function New-NorthDataPack {
  param(
    [Parameter(Mandatory=$true)][string]$Repo,
    [Parameter(Mandatory=$true)][string]$Destination,
    [switch]$ExcludeDrafts,
    [switch]$ExcludeProfile,
    [string]$Purpose = 'export'
  )
  Ensure-NorthLocalWorkspace -Repo $Repo
  $destinationFull = [IO.Path]::GetFullPath($Destination)
  $destinationDir = Split-Path -Parent $destinationFull
  if (-not (Test-Path -LiteralPath $destinationDir)) {
    New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
  }
  $tempRoot = Join-Path $Repo ('.north\tmp\pack-' + [guid]::NewGuid().ToString('N'))
  $packRoot = Join-Path $tempRoot 'north-data-pack-v1'
  New-Item -ItemType Directory -Path $packRoot -Force | Out-Null
  try {
    $dataRoot = Join-Path $packRoot 'data'
    Copy-NorthDataToFolder -Repo $Repo -DataRoot $dataRoot -ExcludeDrafts:$ExcludeDrafts -ExcludeProfile:$ExcludeProfile
    $stats = Get-NorthDataStats -Repo $Repo
    $manifest = [ordered]@{
      schema = 'north-data-pack/v1'
      created_utc = [DateTime]::UtcNow.ToString('o')
      purpose = $Purpose
      north_version = (Get-NorthVersion -Repo $Repo)
      includes = [ordered]@{
        posts = $true
        drafts = (-not $ExcludeDrafts)
        media = $true
        profile = (-not $ExcludeProfile)
      }
      stats = $stats
    }
    $json = $manifest | ConvertTo-Json -Depth 8
    [IO.File]::WriteAllText((Join-Path $packRoot 'manifest.json'), $json, (New-Object Text.UTF8Encoding($false)))
    Write-NorthChecksums -PackRoot $packRoot
    if (Test-Path -LiteralPath $destinationFull) { Remove-Item -LiteralPath $destinationFull -Force }
    [IO.Compression.ZipFile]::CreateFromDirectory($packRoot, $destinationFull, [IO.Compression.CompressionLevel]::Optimal, $true)
    return $destinationFull
  }
  finally {
    if (Test-Path -LiteralPath $tempRoot) { Remove-Item -LiteralPath $tempRoot -Recurse -Force }
  }
}

function Expand-NorthZipSafe {
  param([string]$ZipPath, [string]$Destination)
  if (-not (Test-Path -LiteralPath $ZipPath -PathType Leaf)) { throw "Pack not found: $ZipPath" }
  if (Test-Path -LiteralPath $Destination) { Remove-Item -LiteralPath $Destination -Recurse -Force }
  New-Item -ItemType Directory -Path $Destination -Force | Out-Null
  $destFull = [IO.Path]::GetFullPath($Destination).TrimEnd([char[]]'\/') + [IO.Path]::DirectorySeparatorChar
  $archive = [IO.Compression.ZipFile]::OpenRead([IO.Path]::GetFullPath($ZipPath))
  try {
    foreach ($entry in $archive.Entries) {
      $candidate = Join-Path $Destination $entry.FullName
      $target = [IO.Path]::GetFullPath($candidate)
      if (-not $target.StartsWith($destFull, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Unsafe path in ZIP: $($entry.FullName)"
      }
      if ([string]::IsNullOrEmpty($entry.Name)) {
        New-Item -ItemType Directory -Path $target -Force | Out-Null
        continue
      }
      $parent = Split-Path -Parent $target
      if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
      $input = $entry.Open()
      $output = [IO.File]::Open($target, [IO.FileMode]::Create, [IO.FileAccess]::Write, [IO.FileShare]::None)
      try { $input.CopyTo($output) }
      finally { $output.Dispose(); $input.Dispose() }
    }
  }
  finally { $archive.Dispose() }
}

function Test-NorthDataPackFolder {
  param([string]$PackRoot)
  $manifestPath = Join-Path $PackRoot 'manifest.json'
  $checksumsPath = Join-Path $PackRoot 'checksums.sha256'
  if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) { throw 'Data pack is missing manifest.json.' }
  if (-not (Test-Path -LiteralPath $checksumsPath -PathType Leaf)) { throw 'Data pack is missing checksums.sha256.' }
  $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
  if ([string]$manifest.schema -ne 'north-data-pack/v1') { throw "Unsupported data pack schema: $($manifest.schema)" }
  $lines = @(Get-Content -LiteralPath $checksumsPath | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
  $listed = @{}
  $packFull = [IO.Path]::GetFullPath($PackRoot).TrimEnd([char[]]'\/') + [IO.Path]::DirectorySeparatorChar
  foreach ($line in $lines) {
    if ($line -notmatch '^([A-Fa-f0-9]{64})\s+\*(.+)$') { throw "Invalid checksum line: $line" }
    $expected = $Matches[1].ToLowerInvariant()
    $relative = $Matches[2]
    $full = [IO.Path]::GetFullPath((Join-Path $PackRoot $relative))
    if (-not $full.StartsWith($packFull, [StringComparison]::OrdinalIgnoreCase)) { throw "Unsafe checksum path: $relative" }
    if (-not (Test-Path -LiteralPath $full -PathType Leaf)) { throw "Data pack file missing: $relative" }
    $actual = (Get-FileHash -LiteralPath $full -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -ne $expected) { throw "Checksum mismatch: $relative" }
    $listed[$relative.Replace('\','/').ToLowerInvariant()] = $true
  }
  $actualFiles = @(Get-ChildItem -LiteralPath $PackRoot -Recurse -File | Where-Object { $_.Name -ne 'checksums.sha256' })
  foreach ($file in $actualFiles) {
    $relative = (Get-NorthRelativePath -Root $PackRoot -FullName $file.FullName).ToLowerInvariant()
    if (-not $listed.ContainsKey($relative)) { throw "Unverified extra file in data pack: $relative" }
  }
  return $manifest
}

function Clear-NorthLiveData {
  param([string]$Repo, [switch]$PreserveDrafts, [switch]$PreserveProfile)
  $posts = Join-Path $Repo '_posts'
  if (Test-Path -LiteralPath $posts) { Remove-Item -LiteralPath $posts -Recurse -Force }
  New-Item -ItemType Directory -Path $posts -Force | Out-Null

  if (-not $PreserveDrafts) {
    $drafts = Join-Path $Repo '_drafts'
    if (Test-Path -LiteralPath $drafts) { Remove-Item -LiteralPath $drafts -Recurse -Force }
    New-Item -ItemType Directory -Path $drafts -Force | Out-Null
    New-Item -ItemType File -Path (Join-Path $drafts '.gitkeep') -Force | Out-Null
  }

  $media = Join-Path $Repo 'assets\media'
  if (Test-Path -LiteralPath $media) { Remove-Item -LiteralPath $media -Recurse -Force }
  New-Item -ItemType Directory -Path $media -Force | Out-Null
  New-Item -ItemType File -Path (Join-Path $media '.gitkeep') -Force | Out-Null

  if (-not $PreserveProfile) {
    $profile = Join-Path $Repo '_data\profile.json'
    if (Test-Path -LiteralPath $profile) { Remove-Item -LiteralPath $profile -Force }
  }
}

function Import-NorthDataPackInternal {
  param(
    [Parameter(Mandatory=$true)][string]$Repo,
    [Parameter(Mandatory=$true)][string]$Pack,
    [switch]$NoSafetyBackup
  )
  Ensure-NorthLocalWorkspace -Repo $Repo
  $temp = Join-Path $Repo ('.north\tmp\import-' + [guid]::NewGuid().ToString('N'))
  try {
    Expand-NorthZipSafe -ZipPath $Pack -Destination $temp
    $packRoot = Join-Path $temp 'north-data-pack-v1'
    if (-not (Test-Path -LiteralPath $packRoot)) {
      $dirs = @(Get-ChildItem -LiteralPath $temp -Directory)
      if ($dirs.Count -eq 1) { $packRoot = $dirs[0].FullName }
    }
    $manifest = Test-NorthDataPackFolder -PackRoot $packRoot
    if (-not $NoSafetyBackup) {
      $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
      $backup = Join-Path $Repo ".north\backups\NORTH_Data_PreImport_$stamp.zip"
      [void](New-NorthDataPack -Repo $Repo -Destination $backup -Purpose 'pre-import-safety')
      Write-Host "Safety backup: $backup" -ForegroundColor DarkGray
    }

    $includeDrafts = [bool]$manifest.includes.drafts
    $includeProfile = [bool]$manifest.includes.profile
    Clear-NorthLiveData -Repo $Repo -PreserveDrafts:(-not $includeDrafts) -PreserveProfile:(-not $includeProfile)
    $dataRoot = Join-Path $packRoot 'data'
    Copy-NorthTree -Source (Join-Path $dataRoot '_posts') -Destination (Join-Path $Repo '_posts')
    if ($includeDrafts) { Copy-NorthTree -Source (Join-Path $dataRoot '_drafts') -Destination (Join-Path $Repo '_drafts') }
    Copy-NorthTree -Source (Join-Path $dataRoot 'assets\media') -Destination (Join-Path $Repo 'assets\media')
    if ($includeProfile) {
      $sourceProfile = Join-Path $dataRoot '_data\profile.json'
      if (Test-Path -LiteralPath $sourceProfile -PathType Leaf) {
        Copy-Item -LiteralPath $sourceProfile -Destination (Join-Path $Repo '_data\profile.json') -Force
      }
    }
    return $manifest
  }
  finally {
    if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
  }
}

function Read-NorthOwnership {
  param([string]$Root)
  $path = Join-Path $Root 'north.ownership.json'
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing source ownership manifest: $path" }
  $obj = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
  if ([string]$obj.schema -ne 'north-source-ownership/v1') { throw 'Unsupported NORTH source ownership schema.' }
  return $obj
}

function Copy-NorthSourceOwnedTree {
  param([string]$SourceRoot, [string]$DestinationRoot)
  $ownership = Read-NorthOwnership -Root $SourceRoot
  foreach ($dir in $ownership.source_dirs) {
    $src = Join-Path $SourceRoot ([string]$dir)
    if (-not (Test-Path -LiteralPath $src)) { continue }
    $dst = Join-Path $DestinationRoot ([string]$dir)
    if (Test-Path -LiteralPath $dst) { Remove-Item -LiteralPath $dst -Recurse -Force }
    New-Item -ItemType Directory -Path (Split-Path -Parent $dst) -Force | Out-Null
    Copy-Item -LiteralPath $src -Destination $dst -Recurse -Force
  }
  foreach ($file in $ownership.source_files) {
    $src = Join-Path $SourceRoot ([string]$file)
    if (-not (Test-Path -LiteralPath $src -PathType Leaf)) { continue }
    $dst = Join-Path $DestinationRoot ([string]$file)
    $parent = Split-Path -Parent $dst
    if ($parent -and -not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    Copy-Item -LiteralPath $src -Destination $dst -Force
  }
}

function New-NorthCleanSourceTree {
  param([string]$Repo, [string]$DestinationRoot)
  if (Test-Path -LiteralPath $DestinationRoot) { Remove-Item -LiteralPath $DestinationRoot -Recurse -Force }
  New-Item -ItemType Directory -Path $DestinationRoot -Force | Out-Null
  Copy-NorthSourceOwnedTree -SourceRoot $Repo -DestinationRoot $DestinationRoot

  $sample = Join-Path $Repo '_sample-data'
  $samplePosts = Join-Path $sample 'posts'
  $sampleMedia = Join-Path $sample 'media'
  $sampleProfile = Join-Path $sample 'profile.json'
  New-Item -ItemType Directory -Path (Join-Path $DestinationRoot '_posts') -Force | Out-Null
  New-Item -ItemType Directory -Path (Join-Path $DestinationRoot '_drafts') -Force | Out-Null
  New-Item -ItemType File -Path (Join-Path $DestinationRoot '_drafts\.gitkeep') -Force | Out-Null
  New-Item -ItemType Directory -Path (Join-Path $DestinationRoot 'assets\media') -Force | Out-Null
  New-Item -ItemType File -Path (Join-Path $DestinationRoot 'assets\media\.gitkeep') -Force | Out-Null
  Copy-NorthTree -Source $samplePosts -Destination (Join-Path $DestinationRoot '_posts')
  Copy-NorthTree -Source $sampleMedia -Destination (Join-Path $DestinationRoot 'assets\media')
  if (Test-Path -LiteralPath $sampleProfile -PathType Leaf) {
    New-Item -ItemType Directory -Path (Join-Path $DestinationRoot '_data') -Force | Out-Null
    Copy-Item -LiteralPath $sampleProfile -Destination (Join-Path $DestinationRoot '_data\profile.json') -Force
  }
}
