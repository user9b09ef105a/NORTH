(() => {
  const I18N = {
    en: {
      "skip":"Skip to content","nav.primary":"Primary navigation","nav.home":"home","nav.menu":"Open navigation menu","nav.close":"Close navigation menu","nav.library":"library","nav.topics":"topics","nav.projects":"projects","nav.archive":"archive","nav.about":"about","lang.label":"Language","theme.label":"Theme",
      "home.eyebrow":"KNOWLEDGE & WORK","home.sigilCaption":"strategy · navigate · build · execute","home.title":"Find what matters.<br>Keep what matters.","home.copy":"A bilingual place for articles, projects, research, notes, media, and documentation.","home.library":"Explore the library","home.projects":"Selected projects","home.discoverEyebrow":"DISCOVER","home.discover":"Navigate knowledge by structure, not noise.","home.newest":"Newest first","home.newestCopy":"Today, week, month, year, or custom date range.","home.domain":"By domain & nature","home.domainCopy":"Software, AI, systems, research, guides, case studies, and more.","home.type":"By content & media","home.typeCopy":"Articles, projects, notes, images, audio, video, documents, references.","home.search":"Search everything","home.searchCopy":"Search title, summary, tags, domain, nature, and media.","home.featured":"Featured","home.latest":"Latest","home.viewAll":"View all →",
      "footer.mark":"public knowledge / static by design",
      "library.eyebrow":"KNOWLEDGE LIBRARY","library.title":"Search, filter, sort, and move through everything.","library.copy":"Filter by domain, nature, content, media, language, and time.","library.searchLabel":"Search","library.searchPlaceholder":"Search title, summary, tags, domain, nature…","library.results":"results","library.of":"of","library.facetedHint":"Facet counts adapt to your current search and other filters.","library.executive":"Summary","library.featured":"Featured","library.noSummary":"Open this entry for the full context, decisions, and supporting material.","library.tagsCount":"tags","library.openEntry":"Open entry",
      "filter.domain":"Domain","filter.nature":"Nature","filter.kind":"Content type","filter.media":"Media","filter.time":"Time","filter.sort":"Sort","filter.all":"All","filter.from":"From","filter.to":"To","filter.reset":"Reset filters","filter.filters":"Filters","filter.active":"active","filter.activeFilters":"Active filters","filter.view":"Result view","filter.grid":"Grid view","filter.list":"List view","filter.copyView":"Copy filtered link","filter.copiedView":"Link copied",
      "time.quick":"Quick time filters","time.all":"All time","time.today":"Today","time.yesterday":"Yesterday","time.thisWeek":"This week","time.7d":"Last 7 days","time.30d":"Last 30 days","time.thisMonth":"This month","time.lastMonth":"Last month","time.thisYear":"This year","time.365d":"Last 365 days","time.lastYear":"Last calendar year","time.custom":"Custom range",
      "sort.newest":"Newest first","sort.oldest":"Oldest first","sort.titleAsc":"Title A–Z","sort.titleDesc":"Title Z–A",
      "topics.eyebrow":"KNOWLEDGE MAP","topics.title":"Domains, nature, and tags.","topics.copy":"Use structured taxonomy for the big picture and tags for the fine detail.","topics.tags":"Tags",
      "projects.eyebrow":"SELECTED WORK","projects.title":"Projects, builds, and case studies.","projects.copy":"Public work with context, decisions, implementation, evidence, and outcomes.",
      "archive.eyebrow":"TIMELINE","archive.title":"Everything by time.","archive.copy":"A chronological record. Use the knowledge library for deeper time, domain, nature, and media filtering.","archive.placeholder":"Filter title, type, domain, nature, or tag…","archive.last30":"Last 30 days","archive.thisYear":"This year","archive.entries":"entries","archive.entry":"entry",
      "notes.title":"Notes, signals, and media.","search.redirectTitle":"Search lives in the knowledge library.","search.redirectCopy":"The library combines full-text search with domain, nature, content, media, time, and sorting filters.","search.openLibrary":"Open knowledge library",
      "post.minRead":"min read","post.updated":"updated","post.alsoAvailable":"Also available:","post.source":"Source / reference:","post.actions":"Article actions","post.share":"Share","post.copyLink":"Copy link","post.copied":"Copied","post.linkCopied":"Link copied","post.library":"Library",
      "empty.language":"No entries in this language yet.","empty.published":"No published entries yet.","empty.projects":"No public projects yet.","empty.notes":"No short-form entries yet.","empty.match":"No matching entries.",
      "kind.post":"article","kind.project":"project","kind.note":"note","kind.signal":"signal","kind.image":"image","kind.audio":"audio","kind.video":"video","kind.document":"document","kind.tweet":"reference",
      "domain.software":"Software Engineering","domain.architecture":"Architecture","domain.ai":"AI / ML","domain.systems":"Systems / Infrastructure","domain.research":"Research","domain.product":"Product / Platform","domain.design":"Design / UX","domain.business":"Business / Strategy","domain.career":"Career / Work","domain.knowledge":"Knowledge / Learning","domain.general":"General",
      "nature.analysis":"Analysis","nature.guide":"Guide / How-to","nature.research":"Research","nature.case-study":"Case Study","nature.build-log":"Build Log","nature.reference":"Reference","nature.opinion":"Perspective","nature.learning":"Learning Note","nature.journal":"Journal / Log","nature.announcement":"Announcement",
      "media.text":"Text","media.image":"Image","media.audio":"Audio","media.video":"Video","media.document":"Document","media.link":"External Link","media.mixed":"Mixed Media"
    },
    fa: {
      "skip":"رفتن به محتوا","nav.primary":"ناوبری اصلی","nav.home":"خانه","nav.menu":"باز کردن منوی ناوبری","nav.close":"بستن منوی ناوبری","nav.library":"کتابخانه","nav.topics":"موضوعات","nav.projects":"پروژه‌ها","nav.archive":"آرشیو","nav.about":"درباره","lang.label":"زبان","theme.label":"پوسته",
      "home.eyebrow":"دانش و کار","home.sigilCaption":"راهبرد · جهت‌یابی · ساخت · اجرا","home.title":"آنچه مهم است پیدا کن.<br>آنچه ارزش دارد نگه دار.","home.copy":"فضایی دو‌زبانه برای مقاله‌ها، پروژه‌ها، پژوهش، یادداشت‌ها، رسانه و مستندات.","home.library":"ورود به کتابخانه","home.projects":"پروژه‌های منتخب","home.discoverEyebrow":"کاوش","home.discover":"دانش را با ساختار پیدا کن، نه با شلوغی.","home.newest":"جدیدترین‌ها","home.newestCopy":"امروز، هفته، ماه، سال یا بازه زمانی دلخواه.","home.domain":"بر اساس حوزه و ماهیت","home.domainCopy":"نرم‌افزار، هوش مصنوعی، سیستم، پژوهش، راهنما، مطالعه موردی و بیشتر.","home.type":"بر اساس محتوا و رسانه","home.typeCopy":"مقاله، پروژه، یادداشت، تصویر، صوت، ویدئو، سند و مرجع.","home.search":"جستجوی همه‌چیز","home.searchCopy":"جستجو در عنوان، خلاصه، برچسب، حوزه، ماهیت و رسانه.","home.featured":"منتخب","home.latest":"جدیدترین","home.viewAll":"مشاهده همه ←",
      "footer.mark":"دانش عمومی / ایستا از پایه",
      "library.eyebrow":"کتابخانه دانش","library.title":"جستجو، فیلتر، مرتب‌سازی و حرکت در همه محتوا.","library.copy":"بر اساس حوزه، ماهیت، محتوا، رسانه، زبان و زمان فیلتر کنید.","library.searchLabel":"جستجو","library.searchPlaceholder":"جستجو در عنوان، خلاصه، برچسب، حوزه، ماهیت…","library.results":"نتیجه","library.of":"از","library.facetedHint":"تعداد هر فیلتر با جستجو و فیلترهای فعال دیگر به‌صورت پویا هماهنگ می‌شود.","library.executive":"خلاصه","library.featured":"منتخب","library.noSummary":"برای مشاهده زمینه کامل، تصمیم‌ها و محتوای مرتبط این مورد را باز کنید.","library.tagsCount":"برچسب","library.openEntry":"باز کردن محتوا",
      "filter.domain":"حوزه","filter.nature":"ماهیت","filter.kind":"نوع محتوا","filter.media":"رسانه","filter.time":"زمان","filter.sort":"مرتب‌سازی","filter.all":"همه","filter.from":"از","filter.to":"تا","filter.reset":"حذف فیلترها","filter.filters":"فیلترها","filter.active":"فعال","filter.activeFilters":"فیلترهای فعال","filter.view":"نمای نتایج","filter.grid":"نمای شبکه‌ای","filter.list":"نمای فهرستی","filter.copyView":"کپی لینک فیلترشده","filter.copiedView":"لینک کپی شد",
      "time.quick":"فیلتر سریع زمان","time.all":"همه زمان‌ها","time.today":"امروز","time.yesterday":"دیروز","time.thisWeek":"این هفته","time.7d":"۷ روز اخیر","time.30d":"۳۰ روز اخیر","time.thisMonth":"این ماه","time.lastMonth":"ماه قبل","time.thisYear":"امسال","time.365d":"۳۶۵ روز اخیر","time.lastYear":"سال تقویمی قبل","time.custom":"بازه دلخواه",
      "sort.newest":"جدیدترین اول","sort.oldest":"قدیمی‌ترین اول","sort.titleAsc":"عنوان A–Z","sort.titleDesc":"عنوان Z–A",
      "topics.eyebrow":"نقشه دانش","topics.title":"حوزه‌ها، ماهیت و برچسب‌ها.","topics.copy":"برای نمای کلی از طبقه‌بندی ساختاریافته و برای جزئیات از برچسب‌ها استفاده کنید.","topics.tags":"برچسب‌ها",
      "projects.eyebrow":"کارهای منتخب","projects.title":"پروژه‌ها، ساخت‌ها و مطالعات موردی.","projects.copy":"کارهای عمومی همراه با زمینه، تصمیم‌ها، پیاده‌سازی، شواهد و نتیجه.",
      "archive.eyebrow":"خط زمانی","archive.title":"همه‌چیز بر اساس زمان.","archive.copy":"یک سابقه زمانی کامل. برای فیلتر عمیق‌تر زمان، حوزه، ماهیت و رسانه از کتابخانه دانش استفاده کنید.","archive.placeholder":"فیلتر عنوان، نوع، حوزه، ماهیت یا برچسب…","archive.last30":"۳۰ روز اخیر","archive.thisYear":"امسال","archive.entries":"مورد","archive.entry":"مورد",
      "notes.title":"یادداشت‌ها، سیگنال‌ها و رسانه.","search.redirectTitle":"جستجو داخل کتابخانه دانش قرار دارد.","search.redirectCopy":"کتابخانه جستجوی متن را با فیلتر حوزه، ماهیت، محتوا، رسانه، زمان و مرتب‌سازی ترکیب می‌کند.","search.openLibrary":"باز کردن کتابخانه دانش",
      "post.minRead":"دقیقه مطالعه","post.updated":"به‌روزرسانی","post.alsoAvailable":"نسخه دیگر:","post.source":"منبع / مرجع:","post.actions":"عملیات محتوا","post.share":"اشتراک","post.copyLink":"کپی لینک","post.copied":"کپی شد","post.linkCopied":"لینک کپی شد","post.library":"کتابخانه",
      "empty.language":"هنوز محتوایی به این زبان منتشر نشده است.","empty.published":"هنوز محتوایی منتشر نشده است.","empty.projects":"هنوز پروژه عمومی منتشر نشده است.","empty.notes":"هنوز محتوای کوتاهی منتشر نشده است.","empty.match":"موردی پیدا نشد.",
      "kind.post":"مقاله","kind.project":"پروژه","kind.note":"یادداشت","kind.signal":"سیگنال","kind.image":"تصویر","kind.audio":"صوت","kind.video":"ویدئو","kind.document":"سند","kind.tweet":"مرجع",
      "domain.software":"مهندسی نرم‌افزار","domain.architecture":"معماری","domain.ai":"هوش مصنوعی / یادگیری ماشین","domain.systems":"سیستم‌ها / زیرساخت","domain.research":"پژوهش","domain.product":"محصول / پلتفرم","domain.design":"طراحی / تجربه کاربری","domain.business":"کسب‌وکار / استراتژی","domain.career":"مسیر حرفه‌ای / کار","domain.knowledge":"دانش / یادگیری","domain.general":"عمومی",
      "nature.analysis":"تحلیل","nature.guide":"راهنما / آموزش","nature.research":"پژوهش","nature.case-study":"مطالعه موردی","nature.build-log":"گزارش ساخت","nature.reference":"مرجع","nature.opinion":"دیدگاه","nature.learning":"یادداشت یادگیری","nature.journal":"ژورنال / ثبت","nature.announcement":"اعلام / خبر",
      "media.text":"متن","media.image":"تصویر","media.audio":"صوت","media.video":"ویدئو","media.document":"سند","media.link":"لینک خارجی","media.mixed":"چندرسانه‌ای"
    }
  };

  const normalize=(v)=>(v||"").toString().normalize("NFKC").replace(/ي/g,"ی").replace(/ك/g,"ک").replace(/[‌‍]/g," ").toLocaleLowerCase().replace(/\s+/g," ").trim();
  const html=document.documentElement;
  const pageLang=document.body?.dataset.pageLang||"";
  let activeLang=localStorage.getItem("north-language")||pageLang||html.dataset.activeLang||"en";
  if(!I18N[activeLang]) activeLang="en";
  let activeTheme=localStorage.getItem("north-theme")||html.dataset.theme||"ocean";
  if(activeTheme==="dark")activeTheme="ocean";
  if(!["ocean","light"].includes(activeTheme))activeTheme="ocean";
  const t=(key)=>I18N[activeLang]?.[key]??I18N.en[key]??key;

  const translateFacetLabels=()=>{
    document.querySelectorAll("[data-kind-label]").forEach(el=>{const k=`kind.${el.dataset.kindLabel}`;if(I18N[activeLang][k])el.textContent=t(k)});
    document.querySelectorAll("[data-domain-label]").forEach(el=>{const k=`domain.${el.dataset.domainLabel}`;if(I18N[activeLang][k])el.textContent=t(k)});
    document.querySelectorAll("[data-nature-label]").forEach(el=>{const k=`nature.${el.dataset.natureLabel}`;if(I18N[activeLang][k])el.textContent=t(k)});
    document.querySelectorAll("[data-media-label]").forEach(el=>{const k=`media.${el.dataset.mediaLabel}`;if(I18N[activeLang][k])el.textContent=t(k)});
    document.querySelectorAll("option[data-label-en]").forEach(opt=>{opt.textContent=activeLang==="fa"?opt.dataset.labelFa:opt.dataset.labelEn});
  };

  const applyTheme=(theme,persist=true)=>{
    if(!["ocean","light"].includes(theme))return;
    activeTheme=theme;html.dataset.theme=theme;if(persist)localStorage.setItem("north-theme",theme);
    document.querySelectorAll("[data-theme-switch]").forEach(btn=>{const on=btn.dataset.themeSwitch===theme;btn.classList.toggle("active",on);btn.setAttribute("aria-pressed",String(on))});
    const colors={ocean:"#02070b",light:"#b8c8c5"};document.querySelector('meta[name="theme-color"]')?.setAttribute("content",colors[theme]);
  };

  const updateLanguageLists=()=>{
    document.querySelectorAll("[data-lang-list]").forEach(list=>{const entries=[...list.querySelectorAll(":scope > [data-lang-entry]")];let visible=0;entries.forEach(entry=>{const show=(entry.dataset.langEntry||"en")===activeLang;entry.hidden=!show;if(show)visible++});const empty=list.parentElement?.querySelector(":scope > [data-lang-empty]");if(empty)empty.hidden=visible!==0});
  };

  const applyLanguage=(lang,persist=true)=>{
    if(!I18N[lang])return;const languageChanged=activeLang!==lang;activeLang=lang;if(persist)localStorage.setItem("north-language",lang);html.lang=lang;html.dir=lang==="fa"?"rtl":"ltr";html.dataset.activeLang=lang;
    document.querySelectorAll("[data-i18n]").forEach(el=>{const v=I18N[lang][el.dataset.i18n];if(v!=null)el.textContent=v});
    document.querySelectorAll("[data-i18n-html]").forEach(el=>{const v=I18N[lang][el.dataset.i18nHtml];if(v!=null)el.innerHTML=v});
    document.querySelectorAll("[data-i18n-placeholder]").forEach(el=>{const v=I18N[lang][el.dataset.i18nPlaceholder];if(v!=null)el.placeholder=v});
    document.querySelectorAll("[data-i18n-aria]").forEach(el=>{const v=I18N[lang][el.dataset.i18nAria];if(v!=null)el.setAttribute("aria-label",v)});
    document.querySelectorAll("[data-i18n-title]").forEach(el=>{const v=I18N[lang][el.dataset.i18nTitle];if(v!=null)el.setAttribute("title",v)});
    document.querySelectorAll("[data-localized-en]").forEach(el=>{const v=el.dataset[lang==="fa"?"localizedFa":"localizedEn"];if(v)el.textContent=v});
    document.querySelectorAll("[data-lang-copy]").forEach(el=>{el.hidden=el.dataset.langCopy!==lang});
    document.querySelectorAll("[data-language-switch]").forEach(btn=>{const on=btn.dataset.languageSwitch===lang;btn.classList.toggle("active",on);btn.setAttribute("aria-pressed",String(on))});
    if(languageChanged){document.body.classList.remove("north-language-transition");void document.body.offsetWidth;document.body.classList.add("north-language-transition");setTimeout(()=>document.body.classList.remove("north-language-transition"),360)}translateFacetLabels();document.querySelectorAll("[data-taxonomy-count]").forEach(el=>{const n=Number(el.dataset[lang==="fa"?"countFa":"countEn"]||0);el.textContent=String(n);if(el.closest(".taxonomy-card"))el.closest(".taxonomy-card").hidden=n===0});updateLanguageLists();updateArchive();applyLibraryFilters(false);document.dispatchEvent(new CustomEvent("north:language",{detail:{lang}}));
  };

  document.querySelectorAll("[data-theme-switch]").forEach(btn=>btn.addEventListener("click",()=>applyTheme(btn.dataset.themeSwitch)));
  document.querySelectorAll("[data-language-switch]").forEach(button=>button.addEventListener("click",()=>{const lang=button.dataset.languageSwitch;const translation=button.dataset.translationUrl;if(translation&&document.body.dataset.pageLang&&document.body.dataset.pageLang!==lang){localStorage.setItem("north-language",lang);window.location.href=translation;return}applyLanguage(lang)}));


  // Adaptive mobile navigation: standard top app bar + accessible menu sheet.
  // The signature desktop rail remains CSS-controlled and is never forced onto
  // viewports where it would reduce usable content space.
  const mobileMenuLayer=document.querySelector('[data-mobile-menu-layer]');
  const mobileMenuToggle=document.querySelector('[data-mobile-menu-toggle]');
  const mobileMenuPanel=document.querySelector('.mobile-menu-panel');
  let mobileMenuPreviousFocus=null;
  const mobileMenuFocusable=()=>mobileMenuPanel?[...mobileMenuPanel.querySelectorAll('a[href],button:not([disabled]),input:not([disabled]),select:not([disabled]),textarea:not([disabled]),[tabindex]:not([tabindex="-1"])')]:[];
  const setMobileMenu=(open,restoreFocus=true)=>{
    if(!mobileMenuLayer||!mobileMenuToggle||!mobileMenuPanel)return;
    if(open){
      mobileMenuPreviousFocus=document.activeElement;
      mobileMenuLayer.classList.add('is-open');
      mobileMenuLayer.setAttribute('aria-hidden','false');
      mobileMenuToggle.setAttribute('aria-expanded','true');
      document.body.classList.add('mobile-menu-open');
      mobileMenuPanel.inert=false;
      requestAnimationFrame(()=>mobileMenuFocusable()[0]?.focus());
    }else{
      mobileMenuLayer.classList.remove('is-open');
      mobileMenuLayer.setAttribute('aria-hidden','true');
      mobileMenuToggle.setAttribute('aria-expanded','false');
      document.body.classList.remove('mobile-menu-open');
      mobileMenuPanel.inert=true;
      if(restoreFocus&&mobileMenuPreviousFocus instanceof HTMLElement)mobileMenuPreviousFocus.focus({preventScroll:true});
    }
  };
  if(mobileMenuLayer&&mobileMenuToggle&&mobileMenuPanel){
    mobileMenuPanel.inert=true;
    mobileMenuToggle.addEventListener('click',()=>setMobileMenu(mobileMenuToggle.getAttribute('aria-expanded')!=='true'));
    mobileMenuLayer.querySelectorAll('[data-mobile-menu-close]').forEach(control=>control.addEventListener('click',()=>setMobileMenu(false)));
    mobileMenuPanel.querySelectorAll('a[href]').forEach(link=>link.addEventListener('click',()=>setMobileMenu(false,false)));
    document.addEventListener('keydown',event=>{
      if(!mobileMenuLayer.classList.contains('is-open'))return;
      if(event.key==='Escape'){event.preventDefault();setMobileMenu(false);return;}
      if(event.key!=='Tab')return;
      const focusable=mobileMenuFocusable();if(!focusable.length)return;
      const first=focusable[0],last=focusable[focusable.length-1];
      if(event.shiftKey&&document.activeElement===first){event.preventDefault();last.focus();}
      else if(!event.shiftKey&&document.activeElement===last){event.preventDefault();first.focus();}
    });
    const desktopMenuQuery=window.matchMedia('(min-width: 720px)');
    const closeOnModeChange=event=>{if(event.matches)setMobileMenu(false,false)};
    desktopMenuQuery.addEventListener?.('change',closeOnModeChange);
    window.addEventListener('pageshow',()=>setMobileMenu(false,false),{once:true});
  }

  const archiveInput=document.querySelector("[data-archive-filter]");
  function updateArchive(){if(!archiveInput)return;const items=[...document.querySelectorAll("[data-archive-item]")];const count=document.querySelector("[data-archive-count]");const empty=document.querySelector("[data-archive-empty]");const query=normalize(archiveInput.value);let visible=0;items.forEach(item=>{const lang=(item.dataset.langEntry||"en")===activeLang;const q=!query||normalize(item.dataset.search).includes(query);item.hidden=!(lang&&q);if(lang&&q)visible++});if(count)count.textContent=`${visible} ${visible===1?t("archive.entry"):t("archive.entries")}`;if(empty)empty.hidden=visible!==0}
  if(archiveInput)archiveInput.addEventListener("input",updateArchive);

  const libraryPanel=document.querySelector("[data-library-panel]");
  const libraryResults=document.querySelector("[data-library-results]");
  const libraryItems=libraryResults?[...libraryResults.querySelectorAll("[data-library-item]")]:[];
  const libraryRecords=libraryItems.map(el=>({el,lang:el.dataset.langEntry||"en",domain:el.dataset.domain||"",nature:el.dataset.nature||"",kind:el.dataset.kind||"",media:el.dataset.media||"",ts:Date.parse(el.dataset.date)||0,title:el.dataset.title||"",search:normalize(el.dataset.search)}));
  const libQuery=libraryPanel?.querySelector("[data-library-query]");
  const getControl=(name)=>libraryPanel?.querySelector(`[data-filter="${name}"]`);
  const dayStart=(d)=>new Date(d.getFullYear(),d.getMonth(),d.getDate());
  const parseDateOnly=(v,end=false)=>{if(!v)return null;const [y,m,d]=v.split("-").map(Number);return end?new Date(y,m-1,d,23,59,59,999):new Date(y,m-1,d)};
  const timeWindow=(mode,from,to)=>{
    if(mode==="all")return null;const now=new Date(),today=dayStart(now),inf=Number.POSITIVE_INFINITY;
    if(mode==="today")return[today.getTime(),inf];
    if(mode==="yesterday")return[new Date(now.getFullYear(),now.getMonth(),now.getDate()-1).getTime(),today.getTime()-1];
    if(mode==="this-week"){const start=dayStart(now),offset=(start.getDay()+6)%7;start.setDate(start.getDate()-offset);return[start.getTime(),inf]}
    if(mode==="7d")return[now.getTime()-7*864e5,inf];
    if(mode==="30d")return[now.getTime()-30*864e5,inf];
    if(mode==="365d")return[now.getTime()-365*864e5,inf];
    if(mode==="this-month")return[new Date(now.getFullYear(),now.getMonth(),1).getTime(),inf];
    if(mode==="last-month")return[new Date(now.getFullYear(),now.getMonth()-1,1).getTime(),new Date(now.getFullYear(),now.getMonth(),1).getTime()-1];
    if(mode==="this-year")return[new Date(now.getFullYear(),0,1).getTime(),inf];
    if(mode==="last-year")return[new Date(now.getFullYear()-1,0,1).getTime(),new Date(now.getFullYear(),0,1).getTime()-1];
    if(mode==="custom"){const f=parseDateOnly(from),t2=parseDateOnly(to,true);return[f?f.getTime():Number.NEGATIVE_INFINITY,t2?t2.getTime():inf]}
    return null;
  };

  const readLibraryState=()=>({
    q:normalize(libQuery?.value),domain:getControl("domain")?.value||"",nature:getControl("nature")?.value||"",kind:getControl("kind")?.value||"",media:getControl("media")?.value||"",time:getControl("time")?.value||"all",sort:getControl("sort")?.value||"newest",from:getControl("from")?.value||"",to:getControl("to")?.value||"",view:libraryResults?.dataset.view||"grid"
  });
  const itemMatches=(record,state,exclude="")=>{
    if(record.lang!==activeLang)return false;
    const terms=state._terms||(state._terms=state.q.split(/\s+/).filter(Boolean));
    if(terms.length&&!terms.every(term=>record.search.includes(term)))return false;
    if(exclude!=="domain"&&state.domain&&record.domain!==state.domain)return false;
    if(exclude!=="nature"&&state.nature&&record.nature!==state.nature)return false;
    if(exclude!=="kind"&&state.kind&&record.kind!==state.kind)return false;
    if(exclude!=="media"&&state.media&&record.media!==state.media)return false;
    if(exclude!=="time"&&state._timeWindow){const[min,max]=state._timeWindow;if(record.ts<min||record.ts>max)return false;}
    return true;
  };
  const facetLabel=(name,value)=>{
    if(!value)return t("filter.all");
    const prefix=name==="kind"?"kind":name==="media"?"media":name;
    return t(`${prefix}.${value}`);
  };
  const timeLabel=(value)=>t(`time.${value}`);

  function updateFacetCounts(state){
    for(const facet of ["domain","nature","kind","media"]){
      const select=getControl(facet);if(!select)continue;
      const counts=Object.create(null);let total=0;
      for(const record of libraryRecords){if(!itemMatches(record,state,facet))continue;total++;counts[record[facet]]=(counts[record[facet]]||0)+1}
      for(const option of select.options){
        if(option.value===""){option.textContent=`${t("filter.all")} · ${total}`;option.disabled=false;continue}
        const count=counts[option.value]||0;
        const base=activeLang==="fa"?(option.dataset.labelFa||option.textContent):(option.dataset.labelEn||option.textContent);
        option.textContent=`${base} · ${count}`;option.disabled=count===0&&select.value!==option.value;
      }
    }
  }

  function updateTimePresets(state){
    libraryPanel?.querySelectorAll("[data-time-preset]").forEach(btn=>{
      const on=btn.dataset.timePreset===state.time;btn.classList.toggle("active",on);btn.setAttribute("aria-pressed",String(on));
    });
  }

  function updateActiveFilters(state){
    const wrap=libraryPanel?.querySelector("[data-active-filters]");
    const chips=libraryPanel?.querySelector("[data-active-filter-chips]");
    const countEl=libraryPanel?.querySelector("[data-active-filter-count]");
    if(!wrap||!chips)return;
    const active=[];
    if(state.q)active.push({key:"q",label:`${t("library.searchLabel")}: ${libQuery.value.trim()}`});
    for(const key of ["domain","nature","kind","media"]){if(state[key])active.push({key,label:`${t(`filter.${key}`)}: ${facetLabel(key,state[key])}`})}
    if(state.time!=="all")active.push({key:"time",label:`${t("filter.time")}: ${timeLabel(state.time)}`});
    if(state.time==="custom"&&state.from)active.push({key:"from",label:`${t("filter.from")}: ${state.from}`});
    if(state.time==="custom"&&state.to)active.push({key:"to",label:`${t("filter.to")}: ${state.to}`});
    chips.replaceChildren(...active.map(entry=>{
      const b=document.createElement("button");b.type="button";b.className="filter-chip";b.dataset.clearFilter=entry.key;
      const label=document.createElement("span");label.textContent=entry.label;
      const close=document.createElement("b");close.setAttribute("aria-hidden","true");close.textContent="×";
      b.append(label,close);return b;
    }));
    wrap.hidden=active.length===0;if(countEl)countEl.textContent=String(active.length);
  }

  function syncLibraryURL(){
    if(!libraryPanel)return;const state=readLibraryState(),p=new URLSearchParams();
    const rawQ=libQuery?.value.trim();if(rawQ)p.set("q",rawQ);
    for(const name of ["domain","nature","kind","media"]){if(state[name])p.set(name,state[name])}
    if(state.time!=="all")p.set("time",state.time);if(state.sort!=="newest")p.set("sort",state.sort);if(state.from)p.set("from",state.from);if(state.to)p.set("to",state.to);if(state.view!=="grid")p.set("view",state.view);
    history.replaceState(null,"",`${location.pathname}${p.toString()?`?${p}`:""}${location.hash||""}`);
  }

  function setLibraryView(view,sync=true){
    if(!libraryResults)return;const next=view==="list"?"list":"grid";libraryResults.dataset.view=next;
    document.querySelectorAll("[data-library-view]").forEach(btn=>{const on=btn.dataset.libraryView===next;btn.classList.toggle("active",on);btn.setAttribute("aria-pressed",String(on))});
    if(sync)syncLibraryURL();
  }

  function applyLibraryFilters(sync=true){
    if(!libraryPanel||!libraryResults)return;const state=readLibraryState();state._terms=state.q.split(/\s+/).filter(Boolean);state._timeWindow=timeWindow(state.time,state.from,state.to);
    const custom=libraryPanel.querySelector("[data-custom-date]");if(custom)custom.hidden=state.time!=="custom";
    const visible=libraryRecords.filter(record=>itemMatches(record,state));
    const cmp=(a,b)=>{if(state.sort==="newest")return b.ts-a.ts;if(state.sort==="oldest")return a.ts-b.ts;const titleCmp=a.title.localeCompare(b.title,activeLang==="fa"?"fa":"en",{sensitivity:"base"});return state.sort==="title-desc"?-titleCmp:titleCmp};
    visible.sort(cmp);const visibleSet=new Set(visible);const fragment=document.createDocumentFragment();
    for(const record of visible){record.el.hidden=false;fragment.append(record.el)}
    for(const record of libraryRecords){if(visibleSet.has(record))continue;record.el.hidden=true;fragment.append(record.el)}
    libraryResults.append(fragment);
    let langTotal=0;for(const record of libraryRecords)if(record.lang===activeLang)langTotal++;
    const count=libraryPanel.querySelector("[data-library-count]"),total=libraryPanel.querySelector("[data-library-total]");if(count)count.textContent=String(visible.length);if(total)total.textContent=String(langTotal);
    const empty=document.querySelector("[data-library-empty]");if(empty)empty.hidden=visible.length!==0;
    updateFacetCounts(state);updateTimePresets(state);updateActiveFilters(state);if(sync)syncLibraryURL();
  }

  if(libraryPanel){
    const params=new URLSearchParams(location.search);if(libQuery)libQuery.value=params.get("q")||"";
    for(const name of ["domain","nature","kind","media","time","sort","from","to"]){const el=getControl(name),v=params.get(name);if(el&&v)el.value=v}
    setLibraryView(params.get("view")||"grid",false);
    let searchTimer=0;libraryPanel.querySelectorAll("input,select").forEach(el=>{if(el.matches('input[type="search"]')){el.addEventListener("input",()=>{clearTimeout(searchTimer);searchTimer=setTimeout(()=>applyLibraryFilters(),55)},{passive:true})}else{el.addEventListener("change",()=>applyLibraryFilters())}});
    libraryPanel.querySelectorAll("[data-time-preset]").forEach(btn=>btn.addEventListener("click",()=>{const time=getControl("time");if(time)time.value=btn.dataset.timePreset;if(btn.dataset.timePreset!=="custom"){if(getControl("from"))getControl("from").value="";if(getControl("to"))getControl("to").value=""}applyLibraryFilters()}));
    libraryPanel.querySelectorAll("[data-library-view]").forEach(btn=>btn.addEventListener("click",()=>setLibraryView(btn.dataset.libraryView)));
    libraryPanel.querySelector("[data-active-filter-chips]")?.addEventListener("click",event=>{const button=event.target.closest("[data-clear-filter]");if(!button)return;const key=button.dataset.clearFilter;if(key==="q"&&libQuery)libQuery.value="";else if(getControl(key)){getControl(key).value=key==="time"?"all":"";if(key==="time"){if(getControl("from"))getControl("from").value="";if(getControl("to"))getControl("to").value=""}}applyLibraryFilters()});
    libraryPanel.querySelector("[data-library-reset]")?.addEventListener("click",()=>{if(libQuery)libQuery.value="";for(const name of ["domain","nature","kind","media","from","to"])if(getControl(name))getControl(name).value="";if(getControl("time"))getControl("time").value="all";if(getControl("sort"))getControl("sort").value="newest";setLibraryView("grid",false);applyLibraryFilters()});
    libraryPanel.querySelector("[data-library-copy]")?.addEventListener("click",async event=>{syncLibraryURL();const button=event.currentTarget;try{await navigator.clipboard.writeText(location.href);const old=t("filter.copyView");button.textContent=t("filter.copiedView");setTimeout(()=>button.textContent=old,1400)}catch{window.prompt(t("filter.copyView"),location.href)}});
    document.addEventListener("keydown",event=>{if(event.key==="/"&&!event.ctrlKey&&!event.metaKey&&!event.altKey&&!/input|textarea|select/i.test(document.activeElement?.tagName||"")){event.preventDefault();libQuery?.focus()}});
  }

  for(const button of document.querySelectorAll("[data-copy-url]"))button.addEventListener("click",async()=>{try{await navigator.clipboard.writeText(button.dataset.copyUrl);button.textContent=t("post.copied");setTimeout(()=>button.textContent=t("post.copyLink"),1500)}catch{window.prompt(t("post.copyLink"),button.dataset.copyUrl)}});
  for(const button of document.querySelectorAll("[data-share-url]"))button.addEventListener("click",async()=>{const data={title:button.dataset.shareTitle,url:button.dataset.shareUrl};if(navigator.share){try{await navigator.share(data)}catch(e){if(e.name!=="AbortError")console.error(e)}}else{try{await navigator.clipboard.writeText(data.url);button.textContent=t("post.linkCopied")}catch{window.prompt(t("post.copyLink"),data.url)}}});
  for(const pre of document.querySelectorAll(".prose pre")){const button=document.createElement("button");button.className="code-copy";button.type="button";button.textContent="copy";button.addEventListener("click",async()=>{const code=pre.querySelector("code")?.innerText||pre.innerText;try{await navigator.clipboard.writeText(code);button.textContent="copied";setTimeout(()=>button.textContent="copy",1300)}catch{}});pre.append(button)}

  applyTheme(activeTheme,false);if(localStorage.getItem("north-theme")==="dark")localStorage.setItem("north-theme","ocean");applyLanguage(activeLang,false);
  if(libraryPanel)applyLibraryFilters(false);
})();
