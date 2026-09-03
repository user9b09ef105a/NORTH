param([string]$Destination = '')
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'data-common.ps1')
$repo = Get-NorthRepoRoot
Ensure-NorthLocalWorkspace -Repo $repo
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
if ([string]::IsNullOrWhiteSpace($Destination)) {
  $Destination = Join-Path (Split-Path -Parent $repo) "north-upgrade-$stamp"
}
$destinationFull = [IO.Path]::GetFullPath($Destination)
[void](New-NorthDataPack -Repo $repo -Destination (Join-Path $repo ".north\backups\NORTH_Data_PreUpgrade_$stamp.zip") -Purpose 'pre-upgrade')
New-NorthCleanSourceTree -Repo $repo -DestinationRoot $destinationFull
$marker = [ordered]@{
  schema = 'north-upgrade-workspace/v1'
  created_utc = [DateTime]::UtcNow.ToString('o')
  origin_repo = [IO.Path]::GetFullPath($repo)
  origin_version = Get-NorthVersion -Repo $repo
}
[IO.File]::WriteAllText((Join-Path $destinationFull '.north-workspace.json'), ($marker | ConvertTo-Json -Depth 4), (New-Object Text.UTF8Encoding($false)))
Write-Host "Upgrade workspace created: $destinationFull" -ForegroundColor Green
Write-Host 'It contains source + sample data only. Your live real data remains untouched.' -ForegroundColor DarkGray
