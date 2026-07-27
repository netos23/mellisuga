/// The site's stylesheet and its one script, kept as strings so the generator
/// is a single self-contained program with nothing to locate on disk at build
/// time.
///
/// Both are written by hand. There is no framework, no build step beyond this
/// one, and nothing loaded from a third party — the privacy policy on this site
/// promises that every byte comes from the same origin, and the cheapest way to
/// keep that promise is to have no dependencies to break it.
abstract final class Assets {
  static const String styles = _styles;
  static const String script = _script;
}

const String _styles = r'''
/* ---------------------------------------------------------------------------
   Mellisuga landing — hand-written, no framework, no external requests.
   Order: tokens, reset, layout, components, illustrations, motion, print.
   --------------------------------------------------------------------------- */

/* Tokens ------------------------------------------------------------------ */

:root {
  color-scheme: light dark;

  --brand: #0E9F8E;
  --brand-strong: #0A7367;
  --brand-soft: rgba(14, 159, 142, 0.12);
  --accent: #E0457B;
  --accent-soft: rgba(224, 69, 123, 0.12);

  --bg: #FAFDFC;
  --surface: #FFFFFF;
  --surface-2: #F0F6F4;
  --text: #10201D;
  --muted: #4A5B58;
  --line: #DDE7E4;
  --shadow: 0 1px 2px rgba(16, 32, 29, 0.05), 0 12px 32px -18px rgba(16, 32, 29, 0.45);

  --radius: 14px;
  --radius-lg: 22px;
  --wrap: 1120px;
  --gap: clamp(1.25rem, 3vw, 2.25rem);
  --section-space: clamp(3.5rem, 8vw, 6.5rem);

  --font: system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  --title: clamp(1.9rem, 1.2rem + 2.6vw, 3.25rem);
  --h2: clamp(1.5rem, 1.1rem + 1.5vw, 2.25rem);
  --h3: clamp(1.12rem, 1rem + 0.5vw, 1.35rem);
  --body: clamp(1rem, 0.97rem + 0.16vw, 1.09rem);
}

/*
  Dark tokens are declared twice on purpose: once for visitors whose system
  asks for dark and who have not overridden it, and once for the explicit
  choice stored by the theme toggle. CSS has no way to say "these two selectors
  share a block" across a media query.
*/
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    --bg: #101413;
    --surface: #161B1A;
    --surface-2: #1C2322;
    --text: #E8F1EE;
    --muted: #9BB0AC;
    --line: #26302E;
    --brand: #35C4B1;
    --brand-strong: #6FE0CF;
    --brand-soft: rgba(53, 196, 177, 0.16);
    --accent: #FF6F9F;
    --accent-soft: rgba(255, 111, 159, 0.16);
    --shadow: 0 1px 2px rgba(0, 0, 0, 0.4), 0 18px 40px -22px rgba(0, 0, 0, 0.8);
  }
}

:root[data-theme="dark"] {
  --bg: #101413;
  --surface: #161B1A;
  --surface-2: #1C2322;
  --text: #E8F1EE;
  --muted: #9BB0AC;
  --line: #26302E;
  --brand: #35C4B1;
  --brand-strong: #6FE0CF;
  --brand-soft: rgba(53, 196, 177, 0.16);
  --accent: #FF6F9F;
  --accent-soft: rgba(255, 111, 159, 0.16);
  --shadow: 0 1px 2px rgba(0, 0, 0, 0.4), 0 18px 40px -22px rgba(0, 0, 0, 0.8);
}

/* Reset ------------------------------------------------------------------- */

*, *::before, *::after { box-sizing: border-box; }

html { scroll-behavior: smooth; scroll-padding-top: 5.5rem; }

body {
  margin: 0;
  background: var(--bg);
  color: var(--text);
  font-family: var(--font);
  font-size: var(--body);
  line-height: 1.6;
  -webkit-font-smoothing: antialiased;
  text-rendering: optimizeLegibility;
  overflow-x: hidden;
}

h1, h2, h3, h4 { line-height: 1.15; letter-spacing: -0.02em; margin: 0 0 0.5em; }
h1 { font-size: var(--title); font-weight: 800; }
h2 { font-size: var(--h2); font-weight: 750; }
h3, h4 { font-size: var(--h3); font-weight: 700; }
p { margin: 0 0 1rem; }
img, svg { max-width: 100%; }

a { color: var(--brand-strong); text-decoration-thickness: 1px; text-underline-offset: 2px; }
a:hover { color: var(--accent); }

:focus-visible {
  outline: 2px solid var(--accent);
  outline-offset: 3px;
  border-radius: 4px;
}

ul, ol { margin: 0 0 1rem; padding-left: 1.25rem; }

.visually-hidden {
  position: absolute;
  width: 1px; height: 1px;
  margin: -1px; padding: 0;
  overflow: hidden;
  clip-path: inset(50%);
  white-space: nowrap;
}

.skip-link {
  position: absolute;
  left: 50%;
  top: 0.5rem;
  translate: -50% -200%;
  z-index: 60;
  background: var(--surface);
  border: 1px solid var(--line);
  border-radius: 999px;
  padding: 0.6rem 1.1rem;
  box-shadow: var(--shadow);
}
.skip-link:focus { translate: -50% 0; }

/* Layout ------------------------------------------------------------------ */

.wrap {
  width: min(100% - 2.5rem, var(--wrap));
  margin-inline: auto;
}
.wrap--narrow { --wrap: 46rem; }

.section { padding-block: var(--section-space); }
.section--tint { background: var(--surface-2); }
.section__title { max-width: 22ch; }
.section__lead, .lead {
  color: var(--muted);
  font-size: clamp(1.05rem, 1rem + 0.4vw, 1.25rem);
  max-width: 62ch;
}
.section__foot { color: var(--muted); margin-top: 1.5rem; max-width: 70ch; }

.grid { display: grid; gap: var(--gap); }
.grid--two { grid-template-columns: repeat(auto-fit, minmax(min(100%, 20rem), 1fr)); }
.grid--three { grid-template-columns: repeat(auto-fit, minmax(min(100%, 17rem), 1fr)); }
.grid--cards { grid-template-columns: repeat(auto-fill, minmax(min(100%, 16rem), 1fr)); }

/* Header ------------------------------------------------------------------ */

.site-header {
  position: sticky;
  top: 0;
  z-index: 50;
  background: color-mix(in srgb, var(--bg) 88%, transparent);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid transparent;
  transition: border-color 200ms ease, box-shadow 200ms ease;
}
.site-header.is-stuck { border-bottom-color: var(--line); box-shadow: var(--shadow); }

.site-header__inner {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  min-height: 4.25rem;
}

.brand {
  display: inline-flex;
  align-items: center;
  gap: 0.6rem;
  color: var(--text);
  text-decoration: none;
  font-weight: 800;
  letter-spacing: -0.03em;
}
.brand .mark { width: 2rem; height: 2rem; flex: none; }
.brand__name { font-size: 1.15rem; }

.site-nav {
  margin-left: auto;
  display: flex;
  align-items: center;
  gap: clamp(0.75rem, 1.6vw, 1.6rem);
}
.site-nav a {
  color: var(--muted);
  text-decoration: none;
  font-weight: 600;
  font-size: 0.97rem;
}
.site-nav a:hover { color: var(--text); }
.site-nav .button--primary { color: #fff; }

.nav-toggle, .theme-toggle {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 2.5rem;
  height: 2.5rem;
  border: 1px solid var(--line);
  border-radius: 10px;
  background: var(--surface);
  color: var(--text);
  cursor: pointer;
}
.theme-toggle svg { width: 1.15rem; height: 1.15rem; fill: none; stroke: currentColor; stroke-width: 1.8; stroke-linecap: round; }
.theme-toggle__moon { display: none; }
.theme-toggle__sun { fill: var(--brand-soft); }
/* The script always stamps data-theme, so one pair of rules swaps the icon. */
:root[data-theme="dark"] .theme-toggle__sun,
:root[data-theme="dark"] .theme-toggle__rays { display: none; }
:root[data-theme="dark"] .theme-toggle__moon { display: block; fill: var(--brand-soft); }

.nav-toggle { margin-left: auto; display: none; position: relative; }
.nav-toggle__bars { position: relative; }
.nav-toggle__bars, .nav-toggle__bars::before, .nav-toggle__bars::after {
  display: block;
  width: 1.05rem;
  height: 2px;
  background: currentColor;
  border-radius: 2px;
  transition: transform 220ms ease, opacity 160ms ease;
}
.nav-toggle__bars::before, .nav-toggle__bars::after { content: ""; position: absolute; }
.nav-toggle__bars::before { transform: translateY(-6px); }
.nav-toggle__bars::after { transform: translateY(6px); }
.nav-toggle[aria-expanded="true"] .nav-toggle__bars { background: transparent; }
.nav-toggle[aria-expanded="true"] .nav-toggle__bars::before { transform: rotate(45deg); }
.nav-toggle[aria-expanded="true"] .nav-toggle__bars::after { transform: rotate(-45deg); }

@media (max-width: 56rem) {
  .nav-toggle { display: inline-flex; order: 2; }
  .theme-toggle { order: 3; }
  .site-nav {
    order: 4;
    width: 100%;
    margin-left: 0;
    flex-direction: column;
    align-items: stretch;
    gap: 0;
    display: none;
    padding-bottom: 0.75rem;
  }
  .site-nav.is-open { display: flex; }
  .site-nav a {
    padding: 0.85rem 0.25rem;
    border-top: 1px solid var(--line);
    font-size: 1.02rem;
  }
  .site-nav .button { margin-top: 0.75rem; text-align: center; border-top: 0; }
  .site-header__inner { flex-wrap: wrap; }
}

/* Buttons ----------------------------------------------------------------- */

.button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.85rem 1.4rem;
  border-radius: 999px;
  font-weight: 700;
  text-decoration: none;
  border: 1px solid transparent;
  transition: transform 160ms ease, box-shadow 200ms ease, background-color 200ms ease;
}
.button--primary {
  background: linear-gradient(135deg, var(--brand) 0%, var(--brand-strong) 100%);
  color: #fff;
  box-shadow: 0 10px 24px -14px var(--brand);
}
.button--primary:hover { color: #fff; transform: translateY(-2px); }
.button--ghost { border-color: var(--line); color: var(--text); background: var(--surface); }
.button--ghost:hover { border-color: var(--brand); color: var(--brand-strong); }
.button--small { padding: 0.55rem 1rem; font-size: 0.92rem; }

/* Hero -------------------------------------------------------------------- */

.hero {
  padding-block: clamp(2.5rem, 6vw, 5rem) var(--section-space);
  background:
    radial-gradient(60rem 32rem at 15% -10%, var(--brand-soft), transparent 60%),
    radial-gradient(46rem 30rem at 95% 0%, var(--accent-soft), transparent 55%);
}
.hero__inner {
  display: grid;
  gap: var(--gap);
  grid-template-columns: minmax(0, 1.05fr) minmax(0, 0.95fr);
  align-items: center;
}
.hero__art { justify-self: center; width: min(100%, 23rem); }
.hero__heading-tail { color: var(--muted); font-weight: 700; }

.eyebrow {
  text-transform: uppercase;
  letter-spacing: 0.12em;
  font-size: 0.78rem;
  font-weight: 700;
  color: var(--brand-strong);
  margin-bottom: 0.75rem;
}

.hero__actions {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
  margin-block: 1.75rem 1.25rem;
}

.chips {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  list-style: none;
  padding: 0;
  margin: 0;
}
.chips li {
  border: 1px solid var(--line);
  background: var(--surface);
  border-radius: 999px;
  padding: 0.35rem 0.8rem;
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--muted);
}

@media (max-width: 60rem) {
  .hero__inner { grid-template-columns: 1fr; }
  .hero__art { order: -1; width: min(100%, 17rem); }
}

/* Cards, steps, tables ---------------------------------------------------- */

.card {
  background: var(--surface);
  border: 1px solid var(--line);
  border-radius: var(--radius);
  padding: 1.4rem;
  box-shadow: var(--shadow);
}
.card p { color: var(--muted); margin-bottom: 0; }
.card__art { width: 6.5rem; margin-bottom: 1rem; color: var(--brand); }
.card__head { display: flex; align-items: baseline; gap: 0.75rem; justify-content: space-between; }
.card__title { margin: 0 0 0.5rem; font-size: 1.05rem; }
.card__title a { text-decoration: none; color: var(--text); }
.card--tool:hover { border-color: var(--brand); transform: translateY(-2px); }
.card--tool { transition: transform 180ms ease, border-color 180ms ease; }

.badge {
  flex: none;
  font-size: 0.7rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: var(--muted);
  border: 1px solid var(--line);
  border-radius: 999px;
  padding: 0.15rem 0.55rem;
}
.badge--live { color: var(--brand-strong); border-color: var(--brand); background: var(--brand-soft); }

.tool-group { margin-top: clamp(2rem, 4vw, 3rem); }
.tool-group__title { margin-bottom: 0.25rem; }
.tool-group__blurb { color: var(--muted); margin-bottom: 1.25rem; }

.steps {
  list-style: none;
  padding: 0;
  margin: 0;
  display: grid;
  gap: var(--gap);
  grid-template-columns: repeat(auto-fit, minmax(min(100%, 17rem), 1fr));
  counter-reset: step;
}
.step {
  position: relative;
  background: var(--surface);
  border: 1px solid var(--line);
  border-radius: var(--radius);
  padding: 1.5rem;
}
.step p { color: var(--muted); margin-bottom: 0; }
.step__badge {
  position: absolute;
  top: -0.9rem;
  left: 1.5rem;
  width: 1.8rem;
  height: 1.8rem;
  display: grid;
  place-items: center;
  border-radius: 50%;
  background: var(--brand);
  color: #fff;
  font-weight: 800;
  font-size: 0.9rem;
}
.step__art { width: 3.5rem; margin-bottom: 0.75rem; color: var(--brand); }

.ticks { list-style: none; padding: 0; margin: 1.25rem 0; }
.ticks li { position: relative; padding-left: 1.75rem; margin-bottom: 0.6rem; color: var(--muted); }
.ticks li::before {
  content: "";
  position: absolute;
  left: 0;
  top: 0.45em;
  width: 0.75rem;
  height: 0.4rem;
  border-left: 2px solid var(--brand);
  border-bottom: 2px solid var(--brand);
  rotate: -45deg;
}

.spotlight {
  display: grid;
  gap: var(--gap);
  grid-template-columns: minmax(0, 1.1fr) minmax(0, 0.9fr);
  align-items: center;
}
.spotlight__art { color: var(--brand); width: min(100%, 26rem); justify-self: center; }
@media (max-width: 60rem) { .spotlight { grid-template-columns: 1fr; } }

.table-card {
  background: var(--surface);
  border: 1px solid var(--line);
  border-radius: var(--radius);
  padding: 1.4rem;
}
.table-scroll { overflow-x: auto; }
table { border-collapse: collapse; width: 100%; font-size: 0.95rem; }
th, td { text-align: left; padding: 0.6rem 0.75rem 0.6rem 0; vertical-align: top; }
tbody tr + tr th, tbody tr + tr td { border-top: 1px solid var(--line); }
th[scope="row"] { white-space: nowrap; color: var(--text); font-weight: 700; padding-right: 1.25rem; }
td { color: var(--muted); }
thead th { color: var(--muted); font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.06em; }

.platforms {
  list-style: none;
  padding: 0;
  margin: 0;
  display: grid;
  gap: 1rem;
  grid-template-columns: repeat(auto-fit, minmax(min(100%, 13rem), 1fr));
}
.platform {
  border: 1px solid var(--line);
  border-radius: var(--radius);
  padding: 1.15rem;
  background: var(--surface);
}
.platform h3 { font-size: 1rem; margin-bottom: 0.35rem; }
.platform p { color: var(--muted); font-size: 0.92rem; }
.platform a { font-weight: 700; font-size: 0.92rem; }

/* FAQ, prose, banners ----------------------------------------------------- */

.faq { border-top: 1px solid var(--line); }
.faq__item { border-bottom: 1px solid var(--line); }
.faq__item summary {
  cursor: pointer;
  padding: 1.1rem 2.5rem 1.1rem 0;
  font-weight: 700;
  position: relative;
  list-style: none;
}
.faq__item summary::-webkit-details-marker { display: none; }
.faq__item summary::after {
  content: "";
  position: absolute;
  right: 0.5rem;
  top: 1.5rem;
  width: 0.6rem;
  height: 0.6rem;
  border-right: 2px solid var(--muted);
  border-bottom: 2px solid var(--muted);
  rotate: 45deg;
  transition: rotate 200ms ease;
}
.faq__item[open] summary::after { rotate: -135deg; }
.faq__item p { color: var(--muted); margin: 0 0 1.25rem; max-width: 70ch; }

.page-head {
  padding-block: clamp(2rem, 5vw, 3.5rem) 0;
  background:
    radial-gradient(50rem 26rem at 10% -20%, var(--brand-soft), transparent 60%);
}
.crumbs ol { list-style: none; display: flex; flex-wrap: wrap; gap: 0.4rem; padding: 0; margin: 0 0 1rem; font-size: 0.87rem; color: var(--muted); }
.crumbs li + li::before { content: "/"; margin-right: 0.4rem; color: var(--line); }
.crumbs a { color: var(--muted); text-decoration: none; }
.crumbs a:hover { color: var(--brand-strong); }

.prose h2 { margin-top: 2.5rem; }
.prose h3 { margin-top: 2rem; }
.prose p, .prose li { color: var(--muted); max-width: 70ch; }
.prose__foot { margin-top: 3rem; padding-top: 1.5rem; border-top: 1px solid var(--line); font-size: 0.92rem; }

.toc {
  background: var(--surface-2);
  border: 1px solid var(--line);
  border-radius: var(--radius);
  padding: 1.25rem 1.5rem;
}
.toc h2 { font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.1em; color: var(--muted); margin: 0 0 0.5rem; }
.toc ol { margin: 0; columns: 2; column-gap: 2rem; font-size: 0.94rem; }
@media (max-width: 40rem) { .toc ol { columns: 1; } }

.note {
  border-left: 3px solid var(--accent);
  background: var(--accent-soft);
  border-radius: 0 var(--radius) var(--radius) 0;
  padding: 1.1rem 1.25rem;
}
.note h2 { margin-top: 0; font-size: 1.05rem; }
.note p { margin-bottom: 0; }

.banner__inner {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: space-between;
  gap: 1.25rem;
  background: var(--surface);
  border: 1px solid var(--line);
  border-radius: var(--radius-lg);
  padding: clamp(1.5rem, 3vw, 2.25rem);
  box-shadow: var(--shadow);
}
.banner__text { margin: 0; font-weight: 650; max-width: 46ch; }

.tool-detail { display: grid; gap: var(--gap); grid-template-columns: minmax(0, 1.15fr) minmax(0, 0.85fr); align-items: start; }
.tool-detail__text p { color: var(--muted); max-width: 68ch; }
.tool-detail__art { width: min(100%, 20rem); justify-self: center; color: var(--brand); position: sticky; top: 6rem; }
@media (max-width: 60rem) {
  .tool-detail { grid-template-columns: 1fr; }
  .tool-detail__art { position: static; order: -1; width: min(100%, 15rem); }
}

.closing__inner { display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: var(--gap); }
.closing__art { width: 8rem; color: var(--brand); }

.not-found__inner { text-align: center; }
.not-found__art { width: 7rem; margin: 0 auto 1.5rem; }
.not-found .hero__actions { justify-content: center; }
.not-found__links { color: var(--muted); font-size: 0.95rem; }

/* Footer ------------------------------------------------------------------ */

.site-footer {
  background: var(--surface-2);
  border-top: 1px solid var(--line);
  padding-block: clamp(2.5rem, 5vw, 4rem) 1.5rem;
  margin-top: var(--section-space);
}
.site-footer__inner {
  display: grid;
  gap: var(--gap);
  grid-template-columns: minmax(0, 1.4fr) repeat(3, minmax(0, 1fr));
}
.site-footer__note { color: var(--muted); font-size: 0.92rem; max-width: 34ch; margin-top: 0.9rem; }
.site-footer__links h2 { font-size: 0.78rem; text-transform: uppercase; letter-spacing: 0.1em; color: var(--muted); }
.site-footer__links ul { list-style: none; padding: 0; margin: 0; }
.site-footer__links li { margin-bottom: 0.5rem; }
.site-footer__links a { color: var(--text); text-decoration: none; font-size: 0.95rem; }
.site-footer__links a:hover { color: var(--brand-strong); text-decoration: underline; }
.site-footer__legal {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  gap: 0.5rem;
  margin-top: 2.5rem;
  padding-top: 1.5rem;
  border-top: 1px solid var(--line);
  color: var(--muted);
  font-size: 0.87rem;
}
.site-footer__legal p { margin: 0; }
@media (max-width: 56rem) {
  .site-footer__inner { grid-template-columns: repeat(auto-fit, minmax(min(100%, 12rem), 1fr)); }
}

/* Illustrations ----------------------------------------------------------- */

.mark { width: 100%; height: auto; display: block; overflow: visible; }
.mark__shape--body { fill: var(--brand); }
.mark__shape--accent { fill: var(--accent); }
.mark__pupil { fill: var(--brand); }

.sheet { width: 100%; height: auto; display: block; }
.sheet__paper { fill: var(--surface); stroke: var(--line); stroke-width: 2; }
.sheet__margin { fill: none; stroke: var(--line); stroke-width: 1.5; stroke-dasharray: 6 7; }
.sheet__cut { fill: none; stroke: var(--brand-strong); stroke-width: 1.5; stroke-dasharray: 5 5; opacity: 0.75; }
.sheet__photo { transform-box: fill-box; transform-origin: center; }

.spot, .step__art { width: 100%; height: auto; display: block; }
.spot__stroke {
  fill: none;
  stroke: currentColor;
  stroke-width: 2.2;
  stroke-linecap: round;
  stroke-linejoin: round;
  color: var(--brand);
}
.spot__fill { fill: var(--brand-soft); }
.spot__fill--accent { fill: var(--accent-soft); stroke: var(--accent); }
.spot__dash { stroke-dasharray: 4 5; }
.spot__cloud { stroke: var(--muted); }
.spot__cross { stroke: var(--accent); stroke-width: 3; }

/* Motion ------------------------------------------------------------------ */

@keyframes rise {
  from { opacity: 0; transform: translateY(18px); }
  to { opacity: 1; transform: none; }
}
@keyframes pop {
  from { opacity: 0; transform: scale(0.82); }
  60% { opacity: 1; }
  to { opacity: 1; transform: none; }
}
@keyframes flap {
  0%, 100% { transform: rotate(0deg); }
  50% { transform: rotate(-26deg) scaleY(0.86); }
}
@keyframes hover-bird {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-7px); }
}
@keyframes drift {
  0%, 100% { transform: translateY(0) rotate(0deg); }
  50% { transform: translateY(-10px) rotate(1.5deg); }
}

.js [data-reveal] { opacity: 0; }
/*
  The opacity is restated rather than left to the animation's fill mode: a
  screenshot tool, a paused animation or a browser that rewinds finished
  animations must never be able to leave a revealed section invisible.
*/
.js [data-reveal].is-visible {
  opacity: 1;
  animation: rise 620ms cubic-bezier(0.2, 0.7, 0.3, 1) var(--delay, 0s) both;
}

.sheet__photo { animation: pop 620ms ease-out var(--delay, 0s) both; }
/*
  The pivot is expressed against the wing's own bounding box rather than the
  viewBox, so the flap works whether the mark is a standalone <svg> or a group
  nested inside a bigger drawing. 90%/79% of that box is where the wing meets
  the body.
*/
.mark--flying .mark__wing {
  transform-box: fill-box;
  transform-origin: 90% 79%;
  animation: flap 320ms ease-in-out infinite;
}
.sheet .mark { animation: hover-bird 2.6s ease-in-out infinite; }
.closing__art .mark, .not-found__art .mark { animation: drift 5s ease-in-out infinite; }

@media (prefers-reduced-motion: reduce) {
  html { scroll-behavior: auto; }
  *, *::before, *::after {
    animation-duration: 0.001ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.001ms !important;
  }
  .js [data-reveal] { opacity: 1; }
}

/* Print ------------------------------------------------------------------- */

@media print {
  .site-header, .site-footer__links, .banner, .hero__actions, .skip-link { display: none; }
  body { background: #fff; color: #000; }
  a[href^="http"]::after { content: " (" attr(href) ")"; font-size: 0.8em; }
}
''';

const String _script = r'''
/*
  Progressive enhancement only. Every link works, every FAQ opens and every
  page reads correctly with this file blocked — it adds the theme toggle, the
  mobile menu and the scroll reveals, and nothing else.
*/
(function () {
  'use strict';

  var root = document.documentElement;
  var STORAGE_KEY = 'mellisuga-theme';

  /* Theme ---------------------------------------------------------------- */

  var toggle = document.querySelector('[data-theme-toggle]');

  function prefersDark() {
    return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
  }

  function currentTheme() {
    return root.dataset.theme || (prefersDark() ? 'dark' : 'light');
  }

  function applyTheme(theme) {
    root.dataset.theme = theme;
    if (toggle) {
      toggle.setAttribute('aria-pressed', theme === 'dark' ? 'true' : 'false');
      toggle.setAttribute(
        'aria-label',
        theme === 'dark' ? 'Switch to the light theme' : 'Switch to the dark theme'
      );
    }
    try {
      localStorage.setItem(STORAGE_KEY, theme);
    } catch (error) {
      /* Storage disabled — the choice simply will not survive a reload. */
    }
  }

  if (toggle) {
    applyTheme(currentTheme());
    toggle.addEventListener('click', function () {
      applyTheme(currentTheme() === 'dark' ? 'light' : 'dark');
    });
  }

  /* Mobile navigation ---------------------------------------------------- */

  var navToggle = document.querySelector('[data-nav-toggle]');
  var nav = document.getElementById('site-nav');

  function closeNav() {
    if (!nav || !navToggle) return;
    nav.classList.remove('is-open');
    navToggle.setAttribute('aria-expanded', 'false');
  }

  if (navToggle && nav) {
    navToggle.addEventListener('click', function () {
      var open = nav.classList.toggle('is-open');
      navToggle.setAttribute('aria-expanded', open ? 'true' : 'false');
    });

    nav.addEventListener('click', function (event) {
      if (event.target.closest('a')) closeNav();
    });

    document.addEventListener('keydown', function (event) {
      if (event.key === 'Escape') closeNav();
    });
  }

  /* Sticky header shadow -------------------------------------------------- */

  var header = document.querySelector('[data-header]');
  if (header) {
    var setStuck = function () {
      header.classList.toggle('is-stuck', window.scrollY > 8);
    };
    setStuck();
    window.addEventListener('scroll', setStuck, { passive: true });
  }

  /* Reveal on scroll ------------------------------------------------------ */

  var revealables = document.querySelectorAll('[data-reveal]');
  var reduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  if (!('IntersectionObserver' in window) || reduced) {
    for (var i = 0; i < revealables.length; i++) {
      revealables[i].classList.add('is-visible');
    }
    return;
  }

  var observer = new IntersectionObserver(
    function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        entry.target.classList.add('is-visible');
        observer.unobserve(entry.target);
      });
    },
    { rootMargin: '0px 0px -12% 0px', threshold: 0.08 }
  );

  revealables.forEach(function (element) {
    observer.observe(element);
  });
})();
''';
