# NORTH

A bilingual, Markdown-first site for publishing projects, articles, notes, research, documentation, and media.

[English](#english) · [فارسی](#فارسی)

---

## English

### Setup

Requirements: **Git**, **GitHub CLI (`gh`)**, and a GitHub account.

After extracting the source, open PowerShell in the project folder:

```powershell
gh auth status

powershell -ExecutionPolicy Bypass -File .\scripts\setup-github.ps1 `
  -Owner "user9b09ef105a" `
  -Repo "NORTH"
```

Ruby/Jekyll is only needed for local preview.

### Create content

```powershell
.\scripts\new-content.ps1 `
  -Type post `
  -Lang en `
  -Domain general `
  -Nature analysis `
  -Title "My first post" `
  -Open
```

You can also import an existing Markdown file:

```powershell
.\scripts\new-content.ps1 `
  -Type post `
  -Lang en `
  -Domain general `
  -Nature guide `
  -Title "Example" `
  -BodyFile "D:\Writing\example.md" `
  -Open
```

Use `-Media` to attach images, audio, video, documents, or supported URLs.

### Publish

```powershell
.\scripts\publish.ps1 `
  -Message "content: publish update"
```

### Check or preview

```powershell
.\scripts\check.ps1
.\scripts\preview.ps1
```

### Content locations

```text
_posts/              published content
_drafts/             local drafts
assets/media/        published local media
_data/profile.json   profile/about data
_data/taxonomy.yml   domains and taxonomy
```

More detail:

- [Publishing](docs/PUBLISHING.md)
- [Data lifecycle](docs/DATA_LIFECYCLE.md)
- [Contributing](CONTRIBUTING.md)

---

## فارسی

NORTH یک سایت دوزبانه و مبتنی بر Markdown برای انتشار پروژه‌ها، مقاله‌ها، یادداشت‌ها، پژوهش، مستندات و رسانه است.

### راه‌اندازی

نیازمندی‌ها: **Git**، ابزار **GitHub CLI (`gh`)** و یک حساب GitHub.

بعد از Extract کردن سورس، PowerShell را داخل پوشه پروژه باز کنید:

```powershell
gh auth status

powershell -ExecutionPolicy Bypass -File .\scripts\setup-github.ps1 `
  -Owner "user9b09ef105a" `
  -Repo "NORTH"
```

Ruby/Jekyll فقط برای پیش‌نمایش محلی لازم است.

### ساخت محتوا

```powershell
.\scripts\new-content.ps1 `
  -Type post `
  -Lang fa `
  -Domain general `
  -Nature analysis `
  -Title "اولین یادداشت" `
  -Slug "first-note-fa" `
  -Open
```

برای استفاده از یک فایل Markdown موجود:

```powershell
.\scripts\new-content.ps1 `
  -Type post `
  -Lang fa `
  -Domain general `
  -Nature guide `
  -Title "نمونه" `
  -Slug "example-fa" `
  -BodyFile "D:\Writing\example-fa.md" `
  -Open
```

برای تصویر، صوت، ویدئو، سند یا لینک می‌توان از `-Media` استفاده کرد.

### انتشار

```powershell
.\scripts\publish.ps1 `
  -Message "content: publish update"
```

### بررسی یا پیش‌نمایش

```powershell
.\scripts\check.ps1
.\scripts\preview.ps1
```

### محل محتوا

```text
_posts/              محتوای منتشرشده
_drafts/             پیش‌نویس‌های محلی
assets/media/        رسانه‌های محلی منتشرشده
_data/profile.json   اطلاعات پروفایل و About
_data/taxonomy.yml   حوزه‌ها و ساختار دسته‌بندی
```

راهنمای بیشتر:

- [انتشار](docs/PUBLISHING.md)
- [چرخه عمر داده](docs/DATA_LIFECYCLE.md)
- [مشارکت](CONTRIBUTING.md)

---

Licensed under the [Apache License 2.0](LICENSE).
