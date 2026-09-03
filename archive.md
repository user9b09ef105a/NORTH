---
layout: default
title: Archive
title_fa: آرشیو
permalink: /archive/
nav_key: archive
---
<section class="archive-page shell">
  <header class="library-header"><p class="eyebrow" data-i18n="archive.eyebrow">TIMELINE</p><h1 data-i18n="archive.title">Everything by time.</h1><p data-i18n="archive.copy">A chronological record. Use the knowledge library for deeper time, domain, nature, and media filtering.</p></header>
  <div class="archive-toolbar"><input type="search" data-archive-filter data-i18n-placeholder="archive.placeholder" placeholder="Filter title, type, domain, nature, or tag…"><a class="quiet-button" href="{{ '/library/' | relative_url }}?time=30d" data-i18n="archive.last30">Last 30 days</a><a class="quiet-button" href="{{ '/library/' | relative_url }}?time=this-year" data-i18n="archive.thisYear">This year</a></div>
  <p class="archive-count"><strong data-archive-count>0</strong></p>
  <div class="archive-list">
    {% for post in site.posts %}<article class="archive-row" data-archive-item data-lang-entry="{{ post.lang | default: site.default_lang }}" data-search="{{ post.title | append: ' ' | append: post.tags | append: ' ' | append: post.kind | append: ' ' | append: post.domain | append: ' ' | append: post.nature | normalize_whitespace | escape }}" dir="{% if post.lang == 'fa' %}rtl{% else %}ltr{% endif %}"><time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: '%Y.%m.%d' }}</time><div><div class="facet-line"><span data-domain-label="{{ post.domain | default: 'general' }}">{{ post.domain | default: 'general' }}</span><span data-kind-label="{{ post.kind | default: 'post' }}">{{ post.kind | default: 'post' }}</span></div><a href="{{ post.url | relative_url }}">{{ post.title | escape }}</a></div></article>{% endfor %}
  </div>
  <p class="empty" data-archive-empty hidden data-i18n="empty.match">No matching entries.</p>
</section>
