---
layout: page
title: About
title_fa: درباره
permalink: /about/
nav_key: about
eyebrow: ABOUT
eyebrow_fa: درباره
summary: A bilingual knowledge and work journal for projects, articles, research, notes, media, and documentation.
summary_fa: یک ژورنال دو‌زبانه برای پروژه‌ها، مقاله‌ها، پژوهش، یادداشت‌ها، رسانه و مستندات.
---
{% assign profile = site.data.profile %}
<div data-lang-copy="en">
  {{ profile.about_en | default: site.description | markdownify }}
</div>

<div data-lang-copy="fa" dir="rtl">
  {{ profile.about_fa | default: site.description_fa | markdownify }}
</div>
