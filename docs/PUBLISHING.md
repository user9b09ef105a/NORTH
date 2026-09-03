# NORTH Publishing Guide

NORTH is Markdown-first and media-capable. The normal publishing authority is the protected GitHub `main` branch, so day-to-day publication happens through a temporary content branch, a pull request, the required `Quality` check, and a rebase/squash merge.

The included `scripts/publish.ps1` automates that protected workflow. It never commits directly to `main`.

## Fast daily workflow

1. Start from the repository and keep `main` synchronized:

```powershell
git switch main
git pull --ff-only origin main
```

2. Create or edit anything you want to publish. You can use Markdown manually or the helper:

```powershell
.\scripts\new-content.ps1 `
  -Type post `
  -Lang en `
  -Domain ai `
  -Nature research `
  -Title "Agent Architecture Research" `
  -Tags agents,architecture,research `
  -Summary "Research notes on modern agent architecture." `
  -Open
```

3. When the content is ready, run one command:

```powershell
.\scripts\publish.ps1 -Message "content: publish agent architecture research"
```

NORTH automatically:

```text
validate repository + GitHub CLI authentication
        ↓
fetch protected main
        ↓
create content/<timestamp>-<slug> branch when run from main
        ↓
run NORTH source/security/media checks
        ↓
stage + validate + commit changes
        ↓
push the content branch
        ↓
create or reuse a pull request
        ↓
wait for NORTH Quality Gate / Quality
        ↓
rebase-merge when green
        ↓
return to main + fast-forward synchronize
        ↓
remove the temporary local/remote publishing branch
        ↓
wait for main Quality + GitHub Pages deployment
```

If a required check fails, NORTH leaves the PR open and does **not** merge it.

## Publish an existing Markdown article

Create a NORTH entry from an existing `.md` or `.txt` body file:

```powershell
.\scripts\new-content.ps1 `
  -Type post `
  -Lang en `
  -Domain research `
  -Nature analysis `
  -Title "My Research Article" `
  -Summary "Executive summary." `
  -BodyFile "D:\Writing\article.md" `
  -Open
```

If the source Markdown contains YAML front matter, NORTH imports only its body and creates clean NORTH front matter itself.

## One-command create + protected publish

For content that is already complete in a file, `-Publish` can create the NORTH entry and immediately run the protected publishing workflow:

```powershell
.\scripts\new-content.ps1 `
  -Type post `
  -Lang en `
  -Domain software `
  -Nature guide `
  -Title "Service Architecture Guide" `
  -Summary "A practical architecture guide." `
  -BodyFile "D:\Writing\service-architecture.md" `
  -Publish `
  -PublishMessage "content: publish service architecture guide"
```

`-Publish` is intentionally refused when the body is still the default placeholder.

## Images

```powershell
.\scripts\new-content.ps1 `
  -Type image `
  -Lang en `
  -Domain design `
  -Nature journal `
  -Title "Interface Study" `
  -Media "D:\Media\interface.webp" `
  -Open
```

Local media is copied to:

```text
assets/media/YYYY/MM/
```

The first local image becomes the native NORTH cover image and Library thumbnail.

## Audio

```powershell
.\scripts\new-content.ps1 `
  -Type audio `
  -Lang en `
  -Domain knowledge `
  -Nature learning `
  -Title "Architecture Audio Note" `
  -Media "D:\Media\architecture-note.mp3" `
  -Open
```

NORTH creates a browser audio player.

## Video

Small local video:

```powershell
.\scripts\new-content.ps1 `
  -Type video `
  -Lang en `
  -Domain product `
  -Nature build-log `
  -Title "NORTH Platform Demo" `
  -Media "D:\Media\north-demo.mp4" `
  -Open
```

YouTube or another external video URL:

```powershell
.\scripts\new-content.ps1 `
  -Type video `
  -Lang en `
  -Domain product `
  -Nature build-log `
  -Title "NORTH Platform Demo" `
  -Media "https://www.youtube.com/watch?v=VIDEO_ID" `
  -Open
```

YouTube links are converted to privacy-enhanced `youtube-nocookie.com` embeds.

## Documents and PDFs

```powershell
.\scripts\new-content.ps1 `
  -Type document `
  -Lang en `
  -Domain research `
  -Nature reference `
  -Title "Architecture Report" `
  -Media "D:\Docs\architecture-report.pdf" `
  -Open
```

PDFs get an inline viewer plus download link. Other supported document formats get a download/open link.

## Mixed-media article

A normal article can carry several media types at once:

```powershell
.\scripts\new-content.ps1 `
  -Type post `
  -Lang en `
  -Domain ai `
  -Nature research `
  -Title "Multimodal Agent Study" `
  -Summary "Text, images, audio, video and a supporting report." `
  -BodyFile "D:\Writing\multimodal-study.md" `
  -Media @(
    "D:\Media\architecture.webp",
    "D:\Media\voice-note.mp3",
    "https://www.youtube.com/watch?v=VIDEO_ID",
    "D:\Docs\report.pdf"
  ) `
  -Open
```

For ordinary `post`, `project`, `note`, and `signal` entries with attached media, NORTH automatically records `media_type: mixed` unless you explicitly choose another supported media type.

## Persian content

```powershell
.\scripts\new-content.ps1 `
  -Type post `
  -Lang fa `
  -Domain software `
  -Nature guide `
  -Title "راهنمای معماری سرویس" `
  -Slug "service-architecture-guide-fa" `
  -Summary "راهنمای عملی معماری سرویس." `
  -Open
```

Use an ASCII `-Slug` when the title contains only Persian/Arabic characters and you want a human-readable URL slug.

## Draft workflow

Create a private local draft:

```powershell
.\scripts\new-content.ps1 `
  -Type post `
  -Lang en `
  -Domain research `
  -Nature analysis `
  -Title "Working Research Draft" `
  -Draft `
  -Open
```

Drafts remain under `_drafts/` and are ignored by Git.

When ready:

```powershell
.\scripts\publish-draft.ps1 -Draft "working-research-draft" -Open
```

Finish editing, then:

```powershell
.\scripts\publish.ps1 -Message "content: publish working research"
```

## Publish without automatic merge

To create the branch, commit, PR, and wait for Quality but leave the final merge manual:

```powershell
.\scripts\publish.ps1 `
  -Message "content: publish research report" `
  -NoMerge
```

## Skip post-merge deployment waiting

The default workflow waits for both the main Quality Gate and GitHub Pages deployment after the PR merge. To return immediately after merge/synchronization:

```powershell
.\scripts\publish.ps1 `
  -Message "content: publish quick note" `
  -SkipPostMergeChecks
```

## Media limits and long-term growth

NORTH deliberately keeps the Git repository healthy:

- up to 10 MB per local file: normal;
- above 10 MB: warning;
- above 50 MB: blocked by NORTH publishing checks;
- above 500 MB total local media: repository-growth warning;
- large/frequent video and audio: use external hosting and embed/reference it;
- PDFs and modest documents: suitable for local NORTH storage;
- author-owned content remains in `_posts`, `_drafts`, `assets/media`, and `_data/profile.json` and is preserved by the source-upgrade workflow.

This keeps NORTH fast as the Library grows from a few entries to a long-lived knowledge archive.

## Protected-main assumptions

The recommended single-maintainer repository rules are:

```text
Require pull request              ON
Required approvals                0
Require Code Owner review         OFF
Require Quality status            ON
Require conversation resolution   ON
Require linear history            ON
Restrict deletions                ON
Block force pushes                ON
Restrict updates                  OFF
```

`Restrict updates` should remain off in the single-maintainer setup unless a suitable bypass actor is configured; otherwise even a clean PR can be prevented from updating `main`.

When a genuinely independent trusted maintainer joins, increase required approvals to 1 and optionally require Code Owner review.
