/* NORTH v6.7 — idle-loaded responsive intelligence / motion layer */
(() => {
  const html = document.documentElement;
  const body = document.body;
  const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
  const coarsePointer = window.matchMedia('(pointer: coarse)');
  const lowPower = (navigator.hardwareConcurrency || 4) <= 2 || (navigator.deviceMemory || 4) <= 2;
  html.dataset.input = coarsePointer.matches ? 'coarse' : 'fine';
  coarsePointer.addEventListener?.('change', event => { html.dataset.input = event.matches ? 'coarse' : 'fine'; });

  // Pointer-aware ambient focus. CSS consumes these coordinates even if canvas is disabled.
  let pointerX = window.innerWidth * .72;
  let pointerY = window.innerHeight * .18;
  const updatePointerVars = (x, y) => {
    const px = Math.max(0, Math.min(100, (x / Math.max(1, window.innerWidth)) * 100));
    const py = Math.max(0, Math.min(100, (y / Math.max(1, window.innerHeight)) * 100));
    body.style.setProperty('--north-pointer-x', `${px.toFixed(2)}%`);
    body.style.setProperty('--north-pointer-y', `${py.toFixed(2)}%`);
  };
  updatePointerVars(pointerX, pointerY);
  if (!coarsePointer.matches) {
    window.addEventListener('pointermove', event => {
      pointerX = event.clientX;
      pointerY = event.clientY;
      updatePointerVars(pointerX, pointerY);
    }, { passive: true });
  }

  // Scroll intelligence: direction, progress, and a restrained mobile dock response.
  const progress = document.createElement('div');
  progress.className = 'north-scroll-progress';
  progress.setAttribute('aria-hidden', 'true');
  body.append(progress);
  let lastScrollY = window.scrollY;
  let scrollQueued = false;
  const updateScrollState = () => {
    scrollQueued = false;
    const y = Math.max(0, window.scrollY);
    const max = Math.max(1, document.documentElement.scrollHeight - window.innerHeight);
    const ratio = Math.max(0, Math.min(1, y / max));
    body.style.setProperty('--north-scroll-progress', ratio.toFixed(4));
    body.classList.toggle('north-has-scrolled', y > 48);
    if (Math.abs(y - lastScrollY) > 5) body.dataset.scrollDirection = y > lastScrollY ? 'down' : 'up';
    lastScrollY = y;
  };
  window.addEventListener('scroll', () => {
    if (!scrollQueued) {
      scrollQueued = true;
      requestAnimationFrame(updateScrollState);
    }
  }, { passive: true });
  updateScrollState();

  // Subtle magnetic command-rail behavior for precise pointers only.
  if (!coarsePointer.matches && !reducedMotion.matches) {
    document.querySelectorAll('.dock-action,.dock-switch button').forEach(control => {
      control.addEventListener('pointermove', event => {
        const rect = control.getBoundingClientRect();
        const x = Math.max(-3.5, Math.min(3.5, (event.clientX - (rect.left + rect.width / 2)) * .13));
        const y = Math.max(-3.5, Math.min(3.5, (event.clientY - (rect.top + rect.height / 2)) * .13));
        control.style.setProperty('--mag-x', `${x.toFixed(2)}px`);
        control.style.setProperty('--mag-y', `${y.toFixed(2)}px`);
      });
      control.addEventListener('pointerleave', () => {
        control.style.setProperty('--mag-x', '0px');
        control.style.setProperty('--mag-y', '0px');
      });
    });
  }

  // Strategic sigil: a restrained pointer-aware 3D depth layer. CSS owns the
  // animation; this idle-loaded enhancement only biases its viewing angle.
  const strategicSigil = document.querySelector('[data-north-sigil]');
  if (strategicSigil && !coarsePointer.matches && !reducedMotion.matches) {
    strategicSigil.addEventListener('pointermove', event => {
      const rect = strategicSigil.getBoundingClientRect();
      const nx = ((event.clientX - rect.left) / Math.max(1, rect.width) - .5);
      const ny = ((event.clientY - rect.top) / Math.max(1, rect.height) - .5);
      strategicSigil.style.setProperty('--sigil-ry', `${(nx * 12).toFixed(2)}deg`);
      strategicSigil.style.setProperty('--sigil-rx', `${(-ny * 10).toFixed(2)}deg`);
    });
    strategicSigil.addEventListener('pointerleave', () => {
      strategicSigil.style.setProperty('--sigil-rx', '-6deg');
      strategicSigil.style.setProperty('--sigil-ry', '8deg');
    });
  }

  // Hero art follows the pointer by only a few pixels: conceptual depth, not a 3D gimmick.
  const heroArt = document.querySelector('.north-hero-art');
  if (heroArt && !coarsePointer.matches && !reducedMotion.matches) {
    heroArt.addEventListener('pointermove', event => {
      const rect = heroArt.getBoundingClientRect();
      const x = ((event.clientX - rect.left) / rect.width - .5) * 7;
      const y = ((event.clientY - rect.top) / rect.height - .5) * 7;
      heroArt.style.setProperty('--hero-x', `${x.toFixed(2)}px`);
      heroArt.style.setProperty('--hero-y', `${y.toFixed(2)}px`);
    });
    heroArt.addEventListener('pointerleave', () => {
      heroArt.style.setProperty('--hero-x', '0px');
      heroArt.style.setProperty('--hero-y', '0px');
    });
  }

  // Content choreography: reveal meaningful blocks only once, using IntersectionObserver.
  const revealSelector = [
    '.north-hero-copy > *', '.north-hero-art', '.discover-card', '.post-row',
    '.library-header > *', '.library-workbench', '.library-card', '.taxonomy-page > *',
    '.archive-row', '.article-header > *', '.translation-note', '.cover-media',
    '.prose > *', '.article-actions'
  ].join(',');
  const revealNodes = [...document.querySelectorAll(revealSelector)].filter((node, index, list) => list.indexOf(node) === index);
  if (!reducedMotion.matches && 'IntersectionObserver' in window) {
    body.classList.add('north-motion-ready');
    revealNodes.forEach((node, index) => {
      node.classList.add('reveal-node');
      node.style.setProperty('--reveal-delay', `${Math.min(index % 5, 4) * 34}ms`);
    });
    const revealObserver = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (!entry.isIntersecting) return;
        entry.target.classList.add('is-revealed');
        revealObserver.unobserve(entry.target);
      });
    }, { rootMargin: '0px 0px -7% 0px', threshold: .055 });
    revealNodes.forEach(node => revealObserver.observe(node));
  } else {
    revealNodes.forEach(node => node.classList.add('is-revealed'));
  }

  // Theme changes receive a tiny state transition without hijacking existing theme logic.
  const themeObserver = new MutationObserver(records => {
    if (!records.some(record => record.attributeName === 'data-theme')) return;
    body.classList.remove('north-theme-transition');
    // Force a style flush so repeated theme changes still retrigger the class.
    void body.offsetWidth;
    body.classList.add('north-theme-transition');
    window.setTimeout(() => body.classList.remove('north-theme-transition'), 360);
  });
  themeObserver.observe(html, { attributes: true, attributeFilter: ['data-theme'] });

  // Faceted Library motion/feedback. The core filter engine stays authoritative.
  const libraryPanel = document.querySelector('[data-library-panel]');
  const libraryResults = document.querySelector('[data-library-results]');
  if (libraryPanel && libraryResults) {
    const resultCount = libraryPanel.querySelector('[data-library-count]');
    let resultAnimationFrame = 0;
    let previousCount = resultCount?.textContent || '';
    const animateVisibleResults = () => {
      cancelAnimationFrame(resultAnimationFrame);
      resultAnimationFrame = requestAnimationFrame(() => {
        const visible = [...libraryResults.querySelectorAll('[data-library-item]:not([hidden])')].slice(0, 18);
        visible.forEach((item, index) => {
          item.classList.remove('is-filter-enter');
          item.style.setProperty('--result-delay', `${Math.min(index, 10) * 18}ms`);
          void item.offsetWidth;
          item.classList.add('is-filter-enter');
        });
        if (resultCount && resultCount.textContent !== previousCount) {
          previousCount = resultCount.textContent;
          resultCount.classList.remove('is-count-pulse');
          void resultCount.offsetWidth;
          resultCount.classList.add('is-count-pulse');
        }
      });
    };
    const libraryObserver = new MutationObserver(animateVisibleResults);
    libraryObserver.observe(libraryResults, { childList: true, subtree: false, attributes: true, attributeFilter: ['hidden'] });
    libraryPanel.querySelectorAll('input,select,[data-time-preset],[data-library-reset],[data-library-view]').forEach(control => {
      const eventName = control.matches('input[type="search"]') ? 'input' : 'change';
      const feedback = () => {
        libraryPanel.dataset.searching = 'true';
        window.clearTimeout(libraryPanel._northSearchTimer);
        libraryPanel._northSearchTimer = window.setTimeout(() => { libraryPanel.dataset.searching = 'false'; }, 260);
        window.setTimeout(animateVisibleResults, 0);
      };
      control.addEventListener(eventName, feedback, { passive: true });
      if (control.matches('button')) control.addEventListener('click', feedback, { passive: true });
    });
    animateVisibleResults();
  }

  // Ambient intelligence field. Adaptive, paused in background, disabled for reduced-motion/low-power.
  if (!reducedMotion.matches && !lowPower && window.innerWidth >= 620) {
    const canvas = document.createElement('canvas');
    canvas.className = 'north-intelligence-canvas';
    canvas.setAttribute('aria-hidden', 'true');
    body.prepend(canvas);
    const ctx = canvas.getContext('2d', { alpha: true });
    let width = 0, height = 0, dpr = 1, nodes = [], running = true, frame = 0;

    const accentColor = () => getComputedStyle(html).getPropertyValue('--accent').trim() || '#63ffe1';
    const nodeCount = () => {
      const area = (width * height) / 150000;
      const base = window.innerWidth < 900 ? 8 : 12;
      return Math.max(base, Math.min(24, Math.round(area * .75 + base)));
    };
    const seedNodes = () => {
      nodes = Array.from({ length: nodeCount() }, () => ({
        x: Math.random() * width,
        y: Math.random() * height,
        vx: (Math.random() - .5) * .09,
        vy: (Math.random() - .5) * .09,
        r: .65 + Math.random() * 1.15,
        phase: Math.random() * Math.PI * 2
      }));
    };
    const resizeCanvas = () => {
      width = window.innerWidth;
      height = window.innerHeight;
      dpr = Math.min(window.devicePixelRatio || 1, 1.6);
      canvas.width = Math.max(1, Math.floor(width * dpr));
      canvas.height = Math.max(1, Math.floor(height * dpr));
      canvas.style.width = `${width}px`;
      canvas.style.height = `${height}px`;
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
      seedNodes();
    };
    let lastPaint = 0;
    const draw = time => {
      if (!running) return;
      frame = requestAnimationFrame(draw);
      if (time - lastPaint < 32) return;
      lastPaint = time;
      ctx.clearRect(0, 0, width, height);
      const color = accentColor();
      const pointerActive = html.dataset.input === 'fine';
      for (const node of nodes) {
        if (pointerActive) {
          const dx = pointerX - node.x, dy = pointerY - node.y;
          const dist2 = dx * dx + dy * dy;
          if (dist2 < 90000 && dist2 > 500) {
            const force = .0024 * (1 - Math.sqrt(dist2) / 300);
            node.vx += dx * force * .002;
            node.vy += dy * force * .002;
          }
        }
        node.vx *= .995; node.vy *= .995;
        node.x += node.vx; node.y += node.vy;
        if (node.x < -20) node.x = width + 20; else if (node.x > width + 20) node.x = -20;
        if (node.y < -20) node.y = height + 20; else if (node.y > height + 20) node.y = -20;
      }
      const maxLink = window.innerWidth < 900 ? 105 : 135;
      for (let i = 0; i < nodes.length; i++) {
        const a = nodes[i];
        for (let j = i + 1; j < nodes.length; j++) {
          const b = nodes[j], dx = a.x - b.x, dy = a.y - b.y, dist = Math.hypot(dx, dy);
          if (dist >= maxLink) continue;
          ctx.globalAlpha = (1 - dist / maxLink) * .075;
          ctx.strokeStyle = color;
          ctx.lineWidth = .55;
          ctx.beginPath();ctx.moveTo(a.x, a.y);ctx.lineTo(b.x, b.y);ctx.stroke();
        }
        const breathe = .72 + Math.sin(time * .00055 + a.phase) * .24;
        ctx.globalAlpha = .16 * breathe;
        ctx.fillStyle = color;
        ctx.beginPath();ctx.arc(a.x, a.y, a.r, 0, Math.PI * 2);ctx.fill();
      }
      ctx.globalAlpha = 1;
    };
    let resizeTimer = 0;
    window.addEventListener('resize', () => {
      window.clearTimeout(resizeTimer);
      resizeTimer = window.setTimeout(resizeCanvas, 140);
    }, { passive: true });
    document.addEventListener('visibilitychange', () => {
      running = !document.hidden;
      if (running && !frame) frame = requestAnimationFrame(draw);
      if (!running && frame) { cancelAnimationFrame(frame); frame = 0; }
    });
    reducedMotion.addEventListener?.('change', event => {
      if (event.matches) { running = false; if (frame) cancelAnimationFrame(frame); canvas.remove(); }
    });
    resizeCanvas();
    frame = requestAnimationFrame(draw);
  }
})();
