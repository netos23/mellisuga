import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:mellisuga_content/mellisuga_content.dart';

import 'assets.dart';
import 'html.dart';
import 'illustrations.dart';
import 'seo.dart';
import 'site_config.dart';

/// The frame every page is rendered into: head, header, footer.
///
/// Two rules hold everywhere in here. Every URL comes from [SiteConfig], so
/// the site works at the root of a domain and at a project subpath without a
/// build flag changing the templates. And every asset is same-origin — no
/// font CDN, no analytics, no embedded anything — because the privacy policy
/// on this same site promises exactly that.
class PageLayout extends StatelessComponent {
  const PageLayout({
    required this.config,
    required this.page,
    required this.children,
    this.bodyClass,
  });

  final SiteConfig config;

  /// Everything the `<head>` needs to say about this page.
  final PageMeta page;

  /// The page's own sections, dropped inside `<main>`.
  final List<Component> children;

  final String? bodyClass;

  @override
  Component build(BuildContext context) {
    final locale = config.locale;
    return html(
      attributes: {
        'lang': locale.code,
        if (locale.rtl) 'dir': 'rtl',
        'prefix': 'og: https://ogp.me/ns#',
      },
      [
        head(_head()),
        body(classes: bodyClass, [
          a(classes: 'skip-link', href: '#main', [Component.text(config.strings.skipLink)]),
          SiteHeader(config: config),
          main_(id: 'main', children),
          SiteFooter(config: config),
          script(src: config.asset('site.js'), defer: true),
        ]),
      ],
    );
  }

  List<Component> _head() {
    final structuredData = <Map<String, Object?>>[
      ...page.structuredData,
      ?StructuredData.breadcrumbs(config, page.breadcrumbs),
    ];

    return [
      meta(charset: 'utf-8'),
      meta(name: 'viewport', content: 'width=device-width, initial-scale=1, viewport-fit=cover'),
      _title(page.title),
      meta(name: 'description', content: page.description),
      _link(rel: 'canonical', href: config.canonical(page.path)),
      meta(
        name: 'robots',
        content: page.noIndex ? 'noindex, follow' : 'index, follow, max-image-preview:large',
      ),
      meta(name: 'author', content: Brand.copyrightHolder),
      meta(
        name: 'theme-color',
        content: BrandColors.seedHex,
        attributes: const {'media': '(prefers-color-scheme: light)'},
      ),
      meta(
        name: 'theme-color',
        content: BrandColors.surfaceDarkHex,
        attributes: const {'media': '(prefers-color-scheme: dark)'},
      ),
      meta(name: 'color-scheme', content: 'light dark'),
      ..._hreflangLinks(),

      meta(attributes: const {'property': 'og:type'}, content: 'website'),
      meta(attributes: const {'property': 'og:site_name'}, content: Brand.name),
      meta(attributes: const {'property': 'og:title'}, content: page.title),
      meta(attributes: const {'property': 'og:description'}, content: page.description),
      meta(attributes: const {'property': 'og:url'}, content: config.canonical(page.path)),
      meta(attributes: const {'property': 'og:image'}, content: config.assetCanonical('icon.svg')),
      meta(attributes: const {'property': 'og:locale'}, content: config.locale.code),
      meta(name: 'twitter:card', content: 'summary'),
      meta(name: 'twitter:title', content: page.title),
      meta(name: 'twitter:description', content: page.description),

      _link(rel: 'icon', href: config.asset('icon.svg'), type: 'image/svg+xml'),
      _link(rel: 'stylesheet', href: config.asset('styles.css')),

      script(content: Assets.themeBootstrap),
      for (final block in structuredData) jsonLdScript(block),
    ];
  }

  /// `hreflang` alternates, so a search engine offers a French visitor the
  /// French copy of the page they already found in English.
  List<Component> _hreflangLinks() => [
    for (final locale in AppLocale.values)
      _link(
        rel: 'alternate',
        href: config.withLocale(locale).canonical(page.path),
        attributes: {'hreflang': locale.code},
      ),
    // `x-default` points at English, the locale search engines see when they
    // cannot tell which language a visitor wants.
    _link(
      rel: 'alternate',
      href: config.withLocale(AppLocale.en).canonical(page.path),
      attributes: const {'hreflang': 'x-default'},
    ),
  ];
}

/// The sticky bar at the top of every page.
class SiteHeader extends StatelessComponent {
  const SiteHeader({required this.config});

  final SiteConfig config;

  @override
  Component build(BuildContext context) {
    final strings = config.strings;
    return header(
      classes: 'site-header',
      attributes: const {'data-header': ''},
      [
        div(classes: 'wrap site-header__inner', [
          a(classes: 'brand', href: config.url(''), [
            Illustrations.mark(id: 'header-bird'),
            span(classes: 'brand__name', [Component.text(Brand.name)]),
          ]),
          button(
            classes: 'nav-toggle',
            type: ButtonType.button,
            attributes: const {
              'aria-expanded': 'false',
              'aria-controls': 'site-nav',
              'data-nav-toggle': '',
            },
            [
              span(
                classes: 'nav-toggle__bars',
                attributes: const {'aria-hidden': 'true'},
                const [],
              ),
              span(classes: 'visually-hidden', [Component.text(strings.menuLabel)]),
            ],
          ),
          nav(
            classes: 'site-nav',
            id: 'site-nav',
            attributes: const {'aria-label': 'Primary'},
            [
              a(href: '${config.url('')}#tools', [Component.text(strings.navTools)]),
              a(href: '${config.url('')}#how', [Component.text(strings.navHow)]),
              a(href: '${config.url('')}#sizes', [Component.text(strings.navSizes)]),
              a(href: '${config.url('')}#faq', [Component.text(strings.navFaq)]),
              externalLink(href: Brand.repositoryUrl, [Component.text(strings.navSource)]),
              LanguageSwitcher(config: config),
              a(classes: 'button button--primary button--small', href: config.appUrl, [
                Component.text(strings.navOpenApp),
              ]),
            ],
          ),
          button(
            classes: 'theme-toggle',
            type: ButtonType.button,
            attributes: {'data-theme-toggle': '', 'aria-label': strings.themeToggleAria},
            [
              svg(
                viewBox: '0 0 24 24',
                attributes: const {'aria-hidden': 'true', 'focusable': 'false'},
                [
                  circle(classes: 'theme-toggle__sun', cx: '12', cy: '12', r: '5', const []),
                  Component.element(
                    tag: 'g',
                    classes: 'theme-toggle__rays',
                    children: [
                      path(
                        d:
                            'M12 1v3M12 20v3M1 12h3M20 12h3M4.2 4.2l2.1 2.1M17.7 17.7l2.1 2.1'
                            'M19.8 4.2l-2.1 2.1M6.3 17.7l-2.1 2.1',
                        const [],
                      ),
                    ],
                  ),
                  path(
                    classes: 'theme-toggle__moon',
                    d: 'M20 14.5A8.5 8.5 0 0 1 9.5 4a8.5 8.5 0 1 0 10.5 10.5Z',
                    const [],
                  ),
                ],
              ),
            ],
          ),
        ]),
      ],
    );
  }
}

/// A no-JavaScript language menu: every locale is a plain link to the same
/// page under that locale's prefix, so it works with the stylesheet alone.
class LanguageSwitcher extends StatelessComponent {
  const LanguageSwitcher({required this.config});

  final SiteConfig config;

  @override
  Component build(BuildContext context) => details(classes: 'lang-switch', [
    summary([Component.text('${config.strings.languagePickerLabel}: ${config.locale.nativeName}')]),
    ul([
      for (final locale in AppLocale.values)
        li([
          a(
            href: config.withLocale(locale).url(''),
            attributes: locale == config.locale ? const {'aria-current': 'true'} : null,
            [Component.text(locale.nativeName)],
          ),
        ]),
    ]),
  ]);
}

/// The foot of every page: the mark, the product, legal and project links, and
/// the two lines of small print.
class SiteFooter extends StatelessComponent {
  const SiteFooter({required this.config});

  final SiteConfig config;

  @override
  Component build(BuildContext context) {
    final strings = config.strings;
    return footer(classes: 'site-footer', [
      div(classes: 'wrap site-footer__inner', [
        div(classes: 'site-footer__brand', [
          a(classes: 'brand', href: config.url(''), [
            Illustrations.mark(id: 'footer-bird', flying: false),
            span(classes: 'brand__name', [Component.text(Brand.name)]),
          ]),
          p(classes: 'site-footer__note', [Component.text(config.locale.brandNameOriginIn())]),
        ]),
        _links(
          label: 'Product',
          heading: strings.footerProduct,
          items: [
            a(href: config.appUrl, [Component.text(strings.navOpenApp)]),
            a(href: config.url(ToolCatalog.flagship.path), [
              Component.text(ToolCatalog.flagship.titleIn(config.locale)),
            ]),
            a(href: '${config.url('')}#tools', [Component.text(strings.footerAllTools)]),
            externalLink(href: '${Brand.repositoryUrl}/releases', [
              Component.text(strings.footerDownloads),
            ]),
          ],
        ),
        _links(
          label: 'Legal',
          heading: strings.footerLegal,
          items: [
            for (final document in LegalContent.documents)
              a(href: config.url(document.path), [Component.text(document.title)]),
            externalLink(href: Brand.licenseUrl, [Component.text(Brand.licenseName)]),
          ],
        ),
        _links(
          label: 'Project',
          heading: strings.footerProject,
          items: [
            externalLink(href: Brand.repositoryUrl, [Component.text(strings.footerSourceCode)]),
            externalLink(href: Brand.issuesUrl, [Component.text(strings.footerReportProblem)]),
            externalLink(href: Brand.authorUrl, [Component.text(Brand.copyrightHolder)]),
          ],
        ),
      ]),
      div(classes: 'wrap site-footer__legal', [
        p([
          Component.text(
            '${Brand.copyright} · ${strings.footerReleasedUnder} ${Brand.licenseName}.',
          ),
        ]),
        p([Component.text(strings.footerNoAnalyticsLine)]),
      ]),
    ]);
  }

  Component _links({
    required String label,
    required String heading,
    required List<Component> items,
  }) => nav(
    classes: 'site-footer__links',
    attributes: {'aria-label': label},
    [
      h2([Component.text(heading)]),
      ul([
        for (final item in items) li([item]),
      ]),
    ],
  );
}

/// An anchor to somewhere that is not this site.
///
/// Always `rel="noopener"`, and always an anchor: the site never *fetches*
/// anything from a third party, and the test suite fails the build if it ever
/// starts to.
Component externalLink(List<Component> children, {required String href, String? classes}) =>
    a(classes: classes, href: href, attributes: const {'rel': 'noopener'}, children);

Component _link({
  required String rel,
  required String href,
  String? type,
  Map<String, String>? attributes,
}) => Component.element(
  tag: 'link',
  attributes: {'rel': rel, 'href': href, 'type': ?type, ...?attributes},
);

/// Jaspr has no `<title>` component of its own — its `Document` builds one
/// from a string — so this page's one goes through [Component.element].
Component _title(String text) => Component.element(tag: 'title', children: [Component.text(text)]);
