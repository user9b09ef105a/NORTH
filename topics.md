---
layout: default
title: Topics
title_fa: موضوعات
permalink: /topics/
nav_key: topics
---
<section class="taxonomy-page wide-shell">
  <header class="library-header"><p class="eyebrow" data-i18n="topics.eyebrow">KNOWLEDGE MAP</p><h1 data-i18n="topics.title">Domains, nature, and tags.</h1><p data-i18n="topics.copy">Use structured taxonomy for the big picture and tags for the fine detail.</p></header>

  <section class="taxonomy-block"><div class="section-heading"><h2 data-i18n="filter.domain">Domain</h2></div><div class="taxonomy-grid">
    {% for item in site.data.taxonomy.domains %}{% assign matches = site.posts | where: 'domain', item.id %}{% assign en_matches = matches | where: 'lang', 'en' %}{% assign fa_matches = matches | where: 'lang', 'fa' %}{% if matches.size > 0 %}<a class="taxonomy-card" href="{{ '/library/' | relative_url }}?domain={{ item.id }}"><span data-localized-en="{{ item.en }}" data-localized-fa="{{ item.fa }}">{{ item.en }}</span><b data-taxonomy-count data-count-en="{{ en_matches.size }}" data-count-fa="{{ fa_matches.size }}">{{ en_matches.size }}</b></a>{% endif %}{% endfor %}
  </div></section>

  <section class="taxonomy-block"><div class="section-heading"><h2 data-i18n="filter.nature">Nature</h2></div><div class="taxonomy-grid">
    {% for item in site.data.taxonomy.natures %}{% assign matches = site.posts | where: 'nature', item.id %}{% assign en_matches = matches | where: 'lang', 'en' %}{% assign fa_matches = matches | where: 'lang', 'fa' %}{% if matches.size > 0 %}<a class="taxonomy-card" href="{{ '/library/' | relative_url }}?nature={{ item.id }}"><span data-localized-en="{{ item.en }}" data-localized-fa="{{ item.fa }}">{{ item.en }}</span><b data-taxonomy-count data-count-en="{{ en_matches.size }}" data-count-fa="{{ fa_matches.size }}">{{ en_matches.size }}</b></a>{% endif %}{% endfor %}
  </div></section>

  <section class="taxonomy-block"><div class="section-heading"><h2 data-i18n="topics.tags">Tags</h2></div><div class="topic-cloud">
    {% assign sorted_tags = site.tags | sort %}{% for tag in sorted_tags %}<a href="{{ '/library/' | relative_url }}?q={{ tag[0] | url_encode }}">#{{ tag[0] }} <span>{{ tag[1].size }}</span></a>{% endfor %}
  </div></section>
</section>
