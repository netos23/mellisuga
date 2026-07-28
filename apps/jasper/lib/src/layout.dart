import 'package:mellisuga_content/mellisuga_content.dart';

import 'analytics.dart';
import 'html.dart';
import 'illustrations.dart';
import 'seo.dart';
import 'site_config.dart';

/// The frame every page is rendered into: head, header, footer.
///
/// Three rules hold everywhere in here. Every URL comes from [SiteConfig], so
/// the site works at the root of a domain and at a project subpath without a
/// build flag changing the templates. Every shared asset is same-origin — no
/// font CDN, nothing embedded from a third party by default. And nothing
/// reports anything to an analytics vendor unless [SiteConfig.analytics] names
/// one and the visitor has said yes on the consent banner this same frame
/// renders — see `analytics.dart`.
String renderPage({
  required SiteConfig config,
  required PageMeta meta,
  required String body,
  String? bodyClass,
}) {
  final strings = config.strings;
  final structuredData = <Map<String, Object?>>[
    ...meta.structuredData,
    ?StructuredData.breadcrumbs(config, meta.breadcrumbs),
  ];

  return '''
<!DOCTYPE html>
<html lang="${config.locale.code}"${config.locale.rtl ? ' dir="rtl"' : ''} prefix="og: https://ogp.me/ns#">
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
${indent(_hreflangLinks(config, meta), 0).trimLeft()}

<meta property="og:type" content="website">
<meta property="og:site_name" content="${escapeHtml(Brand.name)}">
<meta property="og:title" content="${escapeHtml(meta.title)}">
<meta property="og:description" content="${escapeHtml(meta.description)}">
<meta property="og:url" content="${escapeHtml(config.canonical(meta.path))}">
<meta property="og:image" content="${escapeHtml(config.assetCanonical('icon.svg'))}">
<meta property="og:locale" content="${config.locale.code}">
<meta name="twitter:card" content="summary">
<meta name="twitter:title" content="${escapeHtml(meta.title)}">
<meta name="twitter:description" content="${escapeHtml(meta.description)}">

<link rel="icon" href="${config.asset('icon.svg')}" type="image/svg+xml">
<link rel="stylesheet" href="${config.asset('styles.css')}">

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
<a class="skip-link" href="#main">${escapeHtml(strings.skipLink)}</a>
${_header(config)}
<main id="main">
$body
</main>
${_footer(config)}
<script src="${config.asset('site.js')}" defer></script>
${config.analytics.anyEnabled ? '${indent(consentBannerHtml(config), 0).trimLeft()}\n<script src="${config.asset('analytics.js')}" defer></script>' : ''}
</body>
</html>
''';
}

/// `hreflang` alternates, so a search engine offers a French visitor the
/// French copy of the page they already found in English.
String _hreflangLinks(SiteConfig config, PageMeta meta) {
  final links = AppLocale.values
      .map(
        (locale) =>
            '<link rel="alternate" hreflang="${locale.code}" '
            'href="${escapeHtml(config.withLocale(locale).canonical(meta.path))}">',
      )
      .join('\n');
  // `x-default` points at English, the locale search engines see when they
  // cannot tell which language a visitor wants.
  return '$links\n'
      '<link rel="alternate" hreflang="x-default" '
      'href="${escapeHtml(config.withLocale(AppLocale.en).canonical(meta.path))}">';
}

String _header(SiteConfig config) {
  final strings = config.strings;
  return '''
<header class="site-header" data-header>
  <div class="wrap site-header__inner">
    <a class="brand" href="${config.url('')}">
      ${indent(Illustrations.mark(id: 'header-bird'), 3).trimLeft()}
      <span class="brand__name">${escapeHtml(Brand.name)}</span>
    </a>

    <button class="nav-toggle" type="button" aria-expanded="false" aria-controls="site-nav" data-nav-toggle>
      <span class="nav-toggle__bars" aria-hidden="true"></span>
      <span class="visually-hidden">${escapeHtml(strings.menuLabel)}</span>
    </button>

    <nav class="site-nav" id="site-nav" aria-label="Primary">
      <a href="${config.url('')}#tools">${escapeHtml(strings.navTools)}</a>
      <a href="${config.url('')}#how">${escapeHtml(strings.navHow)}</a>
      <a href="${config.url('')}#sizes">${escapeHtml(strings.navSizes)}</a>
      <a href="${config.url('')}#faq">${escapeHtml(strings.navFaq)}</a>
      <a href="${Brand.repositoryUrl}" rel="noopener">${escapeHtml(strings.navSource)}</a>
      ${_languageSwitcher(config)}
      <a class="button button--primary button--small" href="${config.appUrl}">${escapeHtml(strings.navOpenApp)}</a>
    </nav>

    <button class="theme-toggle" type="button" data-theme-toggle aria-label="${escapeHtml(strings.themeToggleAria)}">
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
}

/// A no-JavaScript language menu: every locale is a plain link to the same
/// page under that locale's prefix, so it works with the stylesheet alone.
String _languageSwitcher(SiteConfig config) {
  final strings = config.strings;
  final items = AppLocale.values
      .map((locale) {
        final current = locale == config.locale;
        final href = config.withLocale(locale).url('');
        return '        <li><a href="$href"${current ? ' aria-current="true"' : ''}>${escapeHtml(locale.nativeName)}</a></li>';
      })
      .join('\n');

  return '''
<details class="lang-switch">
        <summary>${escapeHtml(strings.languagePickerLabel)}: ${escapeHtml(config.locale.nativeName)}</summary>
        <ul>
$items
        </ul>
      </details>''';
}

String _footer(SiteConfig config) {
  final strings = config.strings;
  final analyticsLine = config.analytics.anyEnabled
      ? '${escapeHtml(strings.footerAnalyticsEnabledLine)} '
            '<a href="#" data-consent-manage>${escapeHtml(strings.consentManageLink)}</a>.'
      : escapeHtml(strings.footerNoAnalyticsLine);

  return '''
<footer class="site-footer">
  <div class="wrap site-footer__inner">
    <div class="site-footer__brand">
      <a class="brand" href="${config.url('')}">
        ${indent(Illustrations.mark(id: 'footer-bird', flying: false), 4).trimLeft()}
        <span class="brand__name">${escapeHtml(Brand.name)}</span>
      </a>
      <p class="site-footer__note">${escapeHtml(config.locale.brandNameOriginIn())}</p>
    </div>

    <nav class="site-footer__links" aria-label="Product">
      <h2>${escapeHtml(strings.footerProduct)}</h2>
      <ul>
        <li><a href="${config.appUrl}">${escapeHtml(strings.navOpenApp)}</a></li>
        <li><a href="${config.url(ToolCatalog.flagship.path)}">${escapeHtml(ToolCatalog.flagship.titleIn(config.locale))}</a></li>
        <li><a href="${config.url('')}#tools">${escapeHtml(strings.footerAllTools)}</a></li>
        <li><a href="${Brand.repositoryUrl}/releases" rel="noopener">${escapeHtml(strings.footerDownloads)}</a></li>
      </ul>
    </nav>

    <nav class="site-footer__links" aria-label="Legal">
      <h2>${escapeHtml(strings.footerLegal)}</h2>
      <ul>
${LegalContent.documents.map((document) => '        <li><a href="${config.url(document.path)}">${escapeHtml(document.title)}</a></li>').join('\n')}
        <li><a href="${Brand.licenseUrl}" rel="noopener">${escapeHtml(Brand.licenseName)}</a></li>
      </ul>
    </nav>

    <nav class="site-footer__links" aria-label="Project">
      <h2>${escapeHtml(strings.footerProject)}</h2>
      <ul>
        <li><a href="${Brand.repositoryUrl}" rel="noopener">${escapeHtml(strings.footerSourceCode)}</a></li>
        <li><a href="${Brand.issuesUrl}" rel="noopener">${escapeHtml(strings.footerReportProblem)}</a></li>
        <li><a href="${Brand.authorUrl}" rel="noopener">${escapeHtml(Brand.copyrightHolder)}</a></li>
      </ul>
    </nav>
  </div>

  <div class="wrap site-footer__legal">
    <p>${escapeHtml(Brand.copyright)} · ${escapeHtml(strings.footerReleasedUnder)} ${escapeHtml(Brand.licenseName)}.</p>
    <p>$analyticsLine</p>
  </div>
</footer>''';
}
