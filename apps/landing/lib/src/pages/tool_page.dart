import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:mellisuga_content/mellisuga_content.dart';

import '../illustrations.dart';
import '../layout.dart';
import '../seo.dart';
import '../site_config.dart';
import 'partials.dart';

/// A page per tool.
///
/// Long-tail search is the point: somebody looking for "merge pdf without
/// uploading" should land on the page about merging PDFs, not on a home page
/// that mentions it in a card. Roadmap tools get a page too — an honest one
/// that says the tool is not built yet.
SitePage buildToolPage(SiteConfig config, ToolInfo tool) {
  final locale = config.locale;
  final strings = config.strings;
  final related = ToolCatalog.inCategory(
    tool.category,
  ).where((other) => other.id != tool.id).toList(growable: false);

  final meta = PageMeta(
    path: tool.path,
    title: '${tool.titleIn(locale)} — ${Brand.name}',
    description: tool.metaDescriptionIn(locale),
    priority: tool.status.isAvailable ? 0.9 : 0.4,
    breadcrumbs: [
      Crumb(name: strings.crumbHome, path: ''),
      Crumb(name: strings.navTools, path: 'tools/'),
      Crumb(name: tool.titleIn(locale), path: tool.path),
    ],
    structuredData: [
      StructuredData.tool(config, tool),
      if (tool.faqs.isNotEmpty) StructuredData.faqPage(config, tool.faqs),
    ],
  );

  return SitePage(
    meta: meta,
    component: PageLayout(
      config: config,
      page: meta,
      bodyClass: 'page-tool',
      children: [
        pageHead(
          config: config,
          title: tool.titleIn(locale),
          summary: tool.summaryIn(locale),
          eyebrow: '${tool.category.labelIn(locale)} · ${tool.status.labelIn(locale)}',
          crumbs: [(name: strings.crumbHome, path: ''), (name: strings.navTools, path: 'tools/')],
        ),
        _overview(config, tool),
        if (tool.faqs.isNotEmpty)
          faqSection(
            config,
            tool.faqs,
            heading: 'About ${_lowerFirst(tool.titleIn(locale))}',
            id: 'tool-faq',
          ),
        if (related.isNotEmpty) _related(config, related),
        openAppBanner(
          config,
          note: tool.status.isAvailable ? strings.toolReadyNote : strings.toolNotReadyNote,
        ),
      ],
    ),
  );
}

Component _overview(SiteConfig config, ToolInfo tool) {
  final locale = config.locale;
  final strings = config.strings;

  return section(classes: 'section', [
    div(classes: 'wrap tool-detail', [
      div(classes: 'tool-detail__text', [
        for (final paragraph in tool.overview) p([Component.text(paragraph)]),
        h2([Component.text(strings.whatItDoes)]),
        ul(classes: 'ticks', [
          for (final highlight in tool.highlightsIn(locale)) li([Component.text(highlight)]),
        ]),
        if (tool.status.isAvailable) _availableActions(config) else _roadmapNote(config),
      ]),
      div(
        classes: 'tool-detail__art',
        attributes: const {'data-reveal': ''},
        [
          if (tool.status.isAvailable)
            Illustrations.heroSheet()
          else
            Illustrations.valueProp('packing'),
        ],
      ),
    ]),
  ]);
}

Component _availableActions(SiteConfig config) {
  final strings = config.strings;
  return p(classes: 'hero__actions', [
    a(classes: 'button button--primary', href: config.appUrl, [Component.text(strings.navOpenApp)]),
    a(classes: 'button button--ghost', href: '${config.url('')}#how', [
      Component.text(strings.seeHowItWorks),
    ]),
  ]);
}

Component _roadmapNote(SiteConfig config) {
  final strings = config.strings;
  return div(classes: 'note', [
    h2([Component.text(strings.notBuiltYetHeading)]),
    p([
      Component.text('${strings.notBuiltYetBodyBefore} '),
      externalLink(href: Brand.issuesUrl, [Component.text(strings.notBuiltYetBodyLinkText)]),
      Component.text(' ${strings.notBuiltYetBodyAfter}'),
    ]),
  ]);
}

Component _related(SiteConfig config, List<ToolInfo> related) =>
    section(classes: 'section section--tint', [
      div(classes: 'wrap', [
        h2(classes: 'section__title', [Component.text(config.strings.moreInTheBox)]),
        div(classes: 'grid grid--cards', [for (final tool in related) toolCard(config, tool)]),
      ]),
    ]);

String _lowerFirst(String value) =>
    value.isEmpty ? value : value[0].toLowerCase() + value.substring(1);
