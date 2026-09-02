import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:mellisuga_content/mellisuga_content.dart';

import '../layout.dart';
import '../seo.dart';
import '../site_config.dart';
import 'partials.dart';

/// A page per legal document, rendered from the same text the app shows on its
/// own screens. Neither copy can drift, because there is only one.
///
/// The document's own body text is not translated — see [LegalNotices] — so
/// every locale shows the same English sections; only the page's chrome
/// (breadcrumb, table of contents, footer) follows [SiteConfig.locale].
SitePage buildLegalPage(SiteConfig config, LegalDocument document) {
  final strings = config.strings;
  final meta = PageMeta(
    path: document.path,
    title: '${document.title} — ${Brand.name}',
    description: document.summary,
    priority: 0.3,
    changeFrequency: 'yearly',
    breadcrumbs: [
      Crumb(name: strings.crumbHome, path: ''),
      Crumb(name: document.title, path: document.path),
    ],
    structuredData: [StructuredData.legalPage(config, document)],
  );

  return SitePage(
    meta: meta,
    component: PageLayout(
      config: config,
      page: meta,
      bodyClass: 'page-legal',
      children: [
        pageHead(
          config: config,
          title: document.title,
          summary: document.summary,
          eyebrow: strings.legalLastUpdated(document.lastUpdated),
          crumbs: [(name: strings.crumbHome, path: '')],
          // Matches the column the document itself is set in.
          narrow: true,
        ),
        _document(config, document),
        openAppBanner(config, note: strings.legalBannerNote),
      ],
    ),
  );
}

Component _document(SiteConfig config, LegalDocument document) {
  final strings = config.strings;
  final englishOnlyNotice = LegalNotices.englishOnlyNotice(config.locale);
  final otherDocuments = LegalContent.documents
      .where((other) => other.id != document.id)
      .toList(growable: false);

  return section(classes: 'section', [
    div(classes: 'wrap wrap--narrow prose', [
      if (englishOnlyNotice != null)
        div(classes: 'note', [
          p([Component.text(englishOnlyNotice)]),
        ]),
      nav(
        classes: 'toc',
        attributes: const {'aria-label': 'On this page'},
        [
          h2([Component.text(strings.legalOnThisPage)]),
          ol([
            for (final section in document.sections)
              li([
                a(href: '#${section.anchor}', [Component.text(section.heading)]),
              ]),
          ]),
        ],
      ),
      for (final section in document.sections) ..._section(section),
      if (document.id == 'licences') ..._components(),
      p(classes: 'prose__foot', [
        Component.text('${strings.legalProseFootBefore} '),
        strong([Component.text(strings.legalProseFootAppLink)]),
        Component.text('${strings.legalProseFootMiddle} '),
        externalLink(href: Brand.repositoryUrl, [Component.text(strings.legalProseFootRepoLink)]),
        Component.text('. ${strings.legalOtherDocuments} '),
        for (final (index, other) in otherDocuments.indexed) ...[
          if (index > 0) Component.text(' · '),
          a(href: config.url(other.path), [Component.text(other.title)]),
        ],
      ]),
    ]),
  ]);
}

List<Component> _section(LegalSection section) => [
  h2(id: section.anchor, [Component.text(section.heading)]),
  for (final paragraph in section.paragraphs) p([Component.text(paragraph)]),
  if (section.bullets.isNotEmpty)
    ul([
      for (final bullet in section.bullets) li([Component.text(bullet)]),
    ]),
];

/// The bundled-component tables, appended to the licences page.
List<Component> _components() => [
  h2(id: 'components', [const Component.text('The list')]),
  for (final group in ComponentGroup.values) ...[
    h3([Component.text(group.label)]),
    div(classes: 'table-scroll', [
      table([
        thead([
          tr([
            th(scope: 'col', [const Component.text('Component')]),
            th(scope: 'col', [const Component.text('Licence')]),
            th(scope: 'col', [const Component.text('Used for')]),
          ]),
        ]),
        tbody([for (final component in ThirdPartyNotices.inGroup(group)) _componentRow(component)]),
      ]),
    ]),
  ],
];

Component _componentRow(ThirdPartyComponent component) {
  final url = component.url;
  return tr([
    td([
      if (url == null)
        Component.text(component.name)
      else
        externalLink(href: url, [Component.text(component.name)]),
    ]),
    td([Component.text(component.licence)]),
    td([Component.text(component.purpose)]),
  ]);
}
