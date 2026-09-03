---
layout: default
title: Library
title_fa: کتابخانه
permalink: /library/
nav_key: library
nav_title: library
---
<section class="library-page wide-shell">
  <header class="library-header">
    <p class="eyebrow" data-i18n="library.eyebrow">KNOWLEDGE LIBRARY</p>
    <h1 data-i18n="library.title">Search, filter, sort, and move through everything.</h1>
    <p data-i18n="library.copy">Filter by domain, nature, content, media, language, and time.</p>
  </header>

  <section class="library-workbench" id="filters" data-library-panel>
    <div class="library-commandbar">
      <label class="library-searchbox" for="library-query">
        <span class="search-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 4.2 4.2"/></svg></span>
        <span class="sr-only" data-i18n="library.searchLabel">Search</span>
        <input id="library-query" type="search" data-library-query data-i18n-placeholder="library.searchPlaceholder" placeholder="Search title, tags, domain, nature…" autocomplete="off" spellcheck="false">
        <kbd>/</kbd>
      </label>

      <div class="library-result-state" aria-live="polite">
        <strong data-library-count>0</strong>
        <span data-i18n="library.of">of</span>
        <span data-library-total>0</span>
        <span data-i18n="library.results">results</span>
      </div>

      <div class="library-view-switch" role="group" aria-label="Result view" data-i18n-aria="filter.view">
        <button type="button" data-library-view="grid" aria-label="Grid view" data-i18n-title="filter.grid">
          <svg viewBox="0 0 24 24" aria-hidden="true"><rect x="4" y="4" width="6" height="6" rx="1"/><rect x="14" y="4" width="6" height="6" rx="1"/><rect x="4" y="14" width="6" height="6" rx="1"/><rect x="14" y="14" width="6" height="6" rx="1"/></svg>
        </button>
        <button type="button" data-library-view="list" aria-label="List view" data-i18n-title="filter.list">
          <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M9 6h11M9 12h11M9 18h11"/><circle cx="5" cy="6" r="1"/><circle cx="5" cy="12" r="1"/><circle cx="5" cy="18" r="1"/></svg>
        </button>
      </div>
    </div>

    <div class="time-presets" aria-label="Quick time filters" data-i18n-aria="time.quick">
      <button type="button" data-time-preset="all" data-i18n="time.all">All time</button>
      <button type="button" data-time-preset="today" data-i18n="time.today">Today</button>
      <button type="button" data-time-preset="7d" data-i18n="time.7d">Last 7 days</button>
      <button type="button" data-time-preset="30d" data-i18n="time.30d">Last 30 days</button>
      <button type="button" data-time-preset="this-month" data-i18n="time.thisMonth">This month</button>
      <button type="button" data-time-preset="last-month" data-i18n="time.lastMonth">Last month</button>
      <button type="button" data-time-preset="this-year" data-i18n="time.thisYear">This year</button>
    </div>

    <details class="library-advanced" open>
      <summary>
        <span class="advanced-summary-label"><span class="filter-orb" aria-hidden="true"></span><span data-i18n="filter.filters">Filters</span></span>
        <span class="active-count"><strong data-active-filter-count>0</strong> <span data-i18n="filter.active">active</span></span>
      </summary>

      <div class="filter-grid">
        <label><span data-i18n="filter.domain">Domain</span><select data-filter="domain"><option value="" data-all-option data-i18n="filter.all">All</option>{% for item in site.data.taxonomy.domains %}<option value="{{ item.id }}" data-label-en="{{ item.en }}" data-label-fa="{{ item.fa }}">{{ item.en }}</option>{% endfor %}</select></label>
        <label><span data-i18n="filter.nature">Nature</span><select data-filter="nature"><option value="" data-all-option data-i18n="filter.all">All</option>{% for item in site.data.taxonomy.natures %}<option value="{{ item.id }}" data-label-en="{{ item.en }}" data-label-fa="{{ item.fa }}">{{ item.en }}</option>{% endfor %}</select></label>
        <label><span data-i18n="filter.kind">Content type</span><select data-filter="kind"><option value="" data-all-option data-i18n="filter.all">All</option>{% for item in site.data.taxonomy.kinds %}<option value="{{ item.id }}" data-label-en="{{ item.en }}" data-label-fa="{{ item.fa }}">{{ item.en }}</option>{% endfor %}</select></label>
        <label><span data-i18n="filter.media">Media</span><select data-filter="media"><option value="" data-all-option data-i18n="filter.all">All</option>{% for item in site.data.taxonomy.media_types %}<option value="{{ item.id }}" data-label-en="{{ item.en }}" data-label-fa="{{ item.fa }}">{{ item.en }}</option>{% endfor %}</select></label>
        <label><span data-i18n="filter.time">Time</span><select data-filter="time"><option value="all" data-i18n="time.all">All time</option><option value="today" data-i18n="time.today">Today</option><option value="yesterday" data-i18n="time.yesterday">Yesterday</option><option value="this-week" data-i18n="time.thisWeek">This week</option><option value="7d" data-i18n="time.7d">Last 7 days</option><option value="30d" data-i18n="time.30d">Last 30 days</option><option value="this-month" data-i18n="time.thisMonth">This month</option><option value="last-month" data-i18n="time.lastMonth">Last month</option><option value="this-year" data-i18n="time.thisYear">This year</option><option value="365d" data-i18n="time.365d">Last 365 days</option><option value="last-year" data-i18n="time.lastYear">Last calendar year</option><option value="custom" data-i18n="time.custom">Custom range</option></select></label>
        <label><span data-i18n="filter.sort">Sort</span><select data-filter="sort"><option value="newest" data-i18n="sort.newest">Newest first</option><option value="oldest" data-i18n="sort.oldest">Oldest first</option><option value="title-asc" data-i18n="sort.titleAsc">Title A–Z</option><option value="title-desc" data-i18n="sort.titleDesc">Title Z–A</option></select></label>
      </div>

      <div class="custom-date-row" data-custom-date hidden>
        <label><span data-i18n="filter.from">From</span><input type="date" data-filter="from"></label>
        <label><span data-i18n="filter.to">To</span><input type="date" data-filter="to"></label>
      </div>
    </details>

    <div class="active-filters" data-active-filters hidden>
      <span class="active-filters-title" data-i18n="filter.activeFilters">Active filters</span>
      <div class="active-filter-chips" data-active-filter-chips></div>
    </div>

    <div class="filter-footer">
      <div class="filter-hint"><span class="signal-dot" aria-hidden="true"></span><span data-i18n="library.facetedHint">Facet counts adapt to your current search and other filters.</span></div>
      <div class="filter-footer-actions">
        <button type="button" class="quiet-button" data-library-copy data-i18n="filter.copyView">Copy filtered link</button>
        <button type="button" class="quiet-button" data-library-reset data-i18n="filter.reset">Reset filters</button>
      </div>
    </div>
  </section>

  <div class="library-results" data-library-results data-view="grid">
    {% for post in site.posts %}{% include library-card.html post=post %}{% endfor %}
  </div>
  <p class="empty library-empty" data-library-empty hidden data-i18n="empty.match">No matching entries.</p>
</section>
