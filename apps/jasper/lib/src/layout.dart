import 'package:mellisuga_content/mellisuga_content.dart';

import 'html.dart';
import 'illustrations.dart';
import 'seo.dart';
import 'site_config.dart';

/// The frame every page is rendered into: head, header, footer.
///
/// Two rules hold everywhere in here. Every URL comes from [SiteConfig], so the
/// site works at the root of a domain and at a project subpath without a build
/// flag changing the templates. And every asset is same-origin — no font CDN,
/// no analytics, no embedded anything — because the privacy policy on this same
/// site promises exactly that.
String renderPage({
  required SiteConfig config,
  required PageMeta meta,
  required String body,
  String? bodyClass,
}) {
  final structuredData = <Map<String, Object?>>[
    ...meta.structuredData,
    ?StructuredData.breadcrumbs(config, meta.breadcrumbs),
  ];

  return '''
<!DOCTYPE html>
<html lang="en" prefix="og: https://ogp.me/ns#">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<title>${escapeHtml(meta.title)}</title>
<meta name="description" content="${escapeHtml(meta.description)}">
<link rel="canonical" href="${escapeHtml(config.canonical(meta.path))}">
${meta.noIndex ? '<meta name="robots" content="noindex, follow">' : '<meta name="robots" content="index, follow, max-image-preview:large">'}
<meta name="author" content="${escapeHtml(Brand.copyrightHolder)}">
<meta name="theme-color" content="${BrandColors.seedHex}" media="(prefers-color-scheme: light)">
<meta name="theme-color" content="${BrandColors.surfaceDarkHex}" media="(prefers-color-scheme: dark)">
<meta name="color-scheme" content="light dark">

<meta property="og:type" content="website">
<meta property="og:site_name" content="${escapeHtml(Brand.name)}">
<meta property="og:title" content="${escapeHtml(meta.title)}">
<meta property="og:description" content="${escapeHtml(meta.description)}">
<meta property="og:url" content="${escapeHtml(config.canonical(meta.path))}">
<meta property="og:image" content="${escapeHtml(config.canonical('icon.svg'))}">
<meta property="og:locale" content="en">
<meta name="twitter:card" content="summary">
<meta name="twitter:title" content="${escapeHtml(meta.title)}">
<meta name="twitter:description" content="${escapeHtml(meta.description)}">

<link rel="icon" href="${config.url('icon.svg')}" type="image/svg+xml">
<link rel="stylesheet" href="${config.url('styles.css')}">

<script>
  // Applied before the first paint so a dark-theme visitor never sees a white
  // flash. Everything else the page does is progressive enhancement; this one
  // has to be inline.
  (function () {
    // Marks the document as scripted, so the stylesheet only hides the
    // reveal-on-scroll sections when something is there to reveal them.
    document.documentElement.classList.add('js');
    try {
      var stored = localStorage.getItem('mellisuga-theme');
      if (stored === 'light' || stored === 'dark') {
        document.documentElement.dataset.theme = stored;
      }
    } catch (error) {
      /* Storage disabled: the media query still gets it right. */
    }
  })();
</script>
${indent(lines(structuredData.map(jsonLdScript)))}
</head>
<body${bodyClass == null ? '' : ' class="$bodyClass"'}>
<a class="skip-link" href="#main">Skip to content</a>
${_header(config)}
<main id="main">
$body
</main>
${_footer(config)}
<script src="${config.url('site.js')}" defer></script>
</body>
</html>
''';
}

String _header(SiteConfig config) =>
    '''
<header class="site-header" data-header>
  <div class="wrap site-header__inner">
    <a class="brand" href="${config.url('')}">
      ${indent(Illustrations.mark(id: 'header-bird'), 3).trimLeft()}
      <span class="brand__name">${escapeHtml(Brand.name)}</span>
    </a>

    <button class="nav-toggle" type="button" aria-expanded="false" aria-controls="site-nav" data-nav-toggle>
      <span class="nav-toggle__bars" aria-hidden="true"></span>
      <span class="visually-hidden">Menu</span>
    </button>

    <nav class="site-nav" id="site-nav" aria-label="Primary">
      <a href="${config.url('')}#tools">Tools</a>
      <a href="${config.url('')}#how">How it works</a>
      <a href="${config.url('')}#sizes">Sizes</a>
      <a href="${config.url('')}#faq">FAQ</a>
      <a href="${Brand.repositoryUrl}" rel="noopener">Source</a>
      <a class="button button--primary button--small" href="${config.appUrl}">Open the app</a>
    </nav>

    <button class="theme-toggle" type="button" data-theme-toggle aria-label="Switch between light and dark theme">
      <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
        <circle class="theme-toggle__sun" cx="12" cy="12" r="5" />
        <g class="theme-toggle__rays">
          <path d="M12 1v3M12 20v3M1 12h3M20 12h3M4.2 4.2l2.1 2.1M17.7 17.7l2.1 2.1M19.8 4.2l-2.1 2.1M6.3 17.7l-2.1 2.1" />
        </g>
        <path class="theme-toggle__moon" d="M20 14.5A8.5 8.5 0 0 1 9.5 4a8.5 8.5 0 1 0 10.5 10.5Z" />
      </svg>
    </button>
  </div>
</header>''';

String _footer(SiteConfig config) =>
    '''
<footer class="site-footer">
  <div class="wrap site-footer__inner">
    <div class="site-footer__brand">
      <a class="brand" href="${config.url('')}">
        ${indent(Illustrations.mark(id: 'footer-bird', flying: false), 4).trimLeft()}
        <span class="brand__name">${escapeHtml(Brand.name)}</span>
      </a>
      <p class="site-footer__note">${escapeHtml(Brand.nameOrigin)}</p>
    </div>

    <nav class="site-footer__links" aria-label="Product">
      <h2>Product</h2>
      <ul>
        <li><a href="${config.appUrl}">Open the app</a></li>
        <li><a href="${config.url(ToolCatalog.flagship.path)}">${escapeHtml(ToolCatalog.flagship.title)}</a></li>
        <li><a href="${config.url('')}#tools">All tools</a></li>
        <li><a href="${Brand.repositoryUrl}/releases" rel="noopener">Downloads</a></li>
      </ul>
    </nav>

    <nav class="site-footer__links" aria-label="Legal">
      <h2>Legal</h2>
      <ul>
${LegalContent.documents.map((document) => '        <li><a href="${config.url(document.path)}">${escapeHtml(document.title)}</a></li>').join('\n')}
        <li><a href="${Brand.licenseUrl}" rel="noopener">${escapeHtml(Brand.licenseName)}</a></li>
      </ul>
    </nav>

    <nav class="site-footer__links" aria-label="Project">
      <h2>Project</h2>
      <ul>
        <li><a href="${Brand.repositoryUrl}" rel="noopener">Source code</a></li>
        <li><a href="${Brand.issuesUrl}" rel="noopener">Report a problem</a></li>
        <li><a href="${Brand.authorUrl}" rel="noopener">${escapeHtml(Brand.copyrightHolder)}</a></li>
      </ul>
    </nav>
  </div>

  <div class="wrap site-footer__legal">
    <p>${escapeHtml(Brand.copyright)} · Released under the ${escapeHtml(Brand.licenseName)}.</p>
    <p>No cookies. No analytics. No accounts.</p>
  </div>
</footer>''';
