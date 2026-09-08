import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:mellisuga_content/mellisuga_content.dart';

import '../layout.dart';
import '../seo.dart';
import '../site_config.dart';
import 'partials.dart';

/// The index every tool page's breadcrumb points at.
///
/// It exists so the trail is real: a breadcrumb to a page that does not exist
/// is worse than no breadcrumb, and a flat list of everything is genuinely the
/// fastest way to find a tool.
SitePage buildToolsIndexPage(SiteConfig config) {
  final locale = config.locale;
  final strings = config.strings;

  final meta = PageMeta(
    path: 'tools/',
    title: '${strings.toolsIndexMetaTitle} — ${Brand.name}',
    description: strings.toolsIndexMetaDescription(Brand.name),
    priority: 0.8,
    breadcrumbs: [
      Crumb(name: strings.crumbHome, path: ''),
      Crumb(name: strings.navTools, path: 'tools/'),
    ],
    structuredData: [
      <String, Object?>{
        '@context': 'https://schema.org',
        '@type': 'ItemList',
        'name': '${Brand.name} tools',
        'itemListElement': <Map<String, Object?>>[
          for (var index = 0; index < ToolCatalog.tools.length; index++)
            <String, Object?>{
              '@type': 'ListItem',
              'position': index + 1,
              'name': ToolCatalog.tools[index].titleIn(locale),
              'url': config.canonical(ToolCatalog.tools[index].path),
            },
        ],
      },
    ],
  );

  return SitePage(
    meta: meta,
    component: PageLayout(
      config: config,
      page: meta,
      bodyClass: 'page-tools',
      children: [
        pageHead(
          config: config,
          title: strings.navTools,
          summary: strings.toolsIndexSummary(
            ToolCatalog.available.length,
            ToolCatalog.roadmap.length,
          ),
          crumbs: [(name: strings.crumbHome, path: '')],
        ),
        section(classes: 'section', [
          div(classes: 'wrap', [
            for (final category in ToolCategory.values)
              div(classes: 'tool-group', [
                h2(classes: 'tool-group__title', [Component.text(category.labelIn(locale))]),
                p(classes: 'tool-group__blurb', [Component.text(category.blurbIn(locale))]),
                div(classes: 'grid grid--cards', [
                  for (final tool in ToolCatalog.inCategory(category)) toolCard(config, tool),
                ]),
              ]),
          ]),
        ]),
        openAppBanner(config),
      ],
    ),
  );
}
