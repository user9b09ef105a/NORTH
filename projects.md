---
layout: default
title: Projects
title_fa: پروژه‌ها
permalink: /projects/
nav_key: projects
---
<section class="library-page wide-shell">
  <header class="library-header"><p class="eyebrow" data-i18n="projects.eyebrow">SELECTED WORK</p><h1 data-i18n="projects.title">Projects, builds, and case studies.</h1><p data-i18n="projects.copy">Public work with context, decisions, implementation, evidence, and outcomes.</p></header>
  <div class="library-results project-results" data-lang-list>{% assign project_posts = site.posts | where: 'kind', 'project' %}{% for post in project_posts %}{% include library-card.html post=post %}{% endfor %}</div>
  <p class="empty" data-lang-empty hidden data-i18n="empty.projects">No public projects yet.</p>
</section>
