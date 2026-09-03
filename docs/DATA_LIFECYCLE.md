# NORTH Data Lifecycle

NORTH separates **author-owned data** from **source-owned application files** so source upgrades can be applied without replacing real content.

## Author-owned data

These paths are preserved by source-only upgrade tools:

```text
_posts/
_drafts/
assets/media/
_data/profile.json
```

## Source-owned files

Application code, layouts, styles, scripts, workflows, taxonomy definitions, documentation, sample data, and repository configuration are source-owned. The authoritative lists live in `north.ownership.json`.

## Local workspace

NORTH uses `.north/` for generated local material such as:

- `backups/` — data backups
- `exports/` — portable data packs and clean-source ZIPs
- `tmp/` — temporary validated work
- `source-backups/` — source snapshots

Never commit `.north/`.

## Safe source upgrade workflow

1. Run `scripts/backup-data.ps1`.
2. Run `scripts/new-upgrade-workspace.ps1`.
3. Make and test source changes in the generated workspace.
4. Return to the live repository.
5. Run `scripts/apply-source-update.ps1 -Workspace <path>`.
6. Review the changes and publish them normally.

The source-update workflow copies only source-owned paths back to the live repository.

## Backup and portable data packs

Create a backup:

```powershell
.\scripts\backup-data.ps1
```

Export a portable pack:

```powershell
.\scripts\export-data.ps1 -Destination "R:\Backups\NORTH_Data.zip"
```

Verify a pack:

```powershell
.\scripts\verify-data-pack.ps1 -Pack "R:\Backups\NORTH_Data.zip"
```

Import a pack:

```powershell
.\scripts\import-data.ps1 -Pack "R:\Backups\NORTH_Data.zip"
```

Restore the latest local backup:

```powershell
.\scripts\restore-data.ps1
```

## Clean source package

To create a source package without real posts, drafts, media, profile data, Git metadata, or local backups:

```powershell
.\scripts\create-clean-source.ps1
```

The exported source uses `_sample-data/` where appropriate so the package remains suitable for development and testing.

## Recovery notes

- Do not import a pack that fails checksum validation.
- Keep an additional backup outside the repository drive for important material.
- Git history is useful, but it is not a replacement for media and draft backups.
- Large or frequently changing media is better kept on external storage and referenced from NORTH.
