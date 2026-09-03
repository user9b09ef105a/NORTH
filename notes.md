---
layout: default
title: Notes
title_fa: یادداشت‌ها
permalink: /notes/
---
<section class="library-page wide-shell"><header class="library-header"><p class="eyebrow">SHORT FORM</p><h1 data-i18n="notes.title">Notes, signals, and media.</h1></header><div class="library-results" data-lang-list>{% for post in site.posts %}{% if post.kind == 'note' or post.kind == 'signal' or post.kind == 'image' or post.kind == 'audio' or post.kind == 'video' or post.kind == 'document' or post.kind == 'tweet' %}{% include library-card.html post=post %}{% endif %}{% endfor %}</div><p class="empty" data-lang-empty hidden data-i18n="empty.notes">No short-form entries yet.</p></section>
