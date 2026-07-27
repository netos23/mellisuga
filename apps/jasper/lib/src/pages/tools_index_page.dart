import 'package:mellisuga_content/mellisuga_content.dart';

import '../html.dart';
import '../layout.dart';
import '../seo.dart';
import '../site_config.dart';
import 'partials.dart';

/// The index every tool page's breadcrumb points at.
///
/// It exists so the trail is real: a breadcrumb to a page that does not exist
/// is worse than no breadcrumb, and a flat list of everything is genuinely the
/// fastest way to find a tool.
RenderedPage buildToolsIndexPage(SiteConfig config) {
  final meta = PageMeta(
    path: 'tools/',
    title: 'Photo and PDF tools that run on your device — ${Brand.name}',
    description:
        'Every ${Brand.name} tool: compose photos for print, merge and split '
        'PDFs, convert images, watermark and more — all client-side, nothing '
        'uploaded.',
    priority: 0.8,
    breadcrumbs: [
      const Crumb(name: 'Home', path: ''),
      const Crumb(name: 'Tools', path: 'tools/'),
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
              'name': ToolCatalog.tools[index].title,
              'url': config.canonical(ToolCatalog.tools[index].path),
            },
        ],
      },
    ],
  );

  final groups = ToolCategory.values
      .map(
        (category) =>
            '''
    <div class="tool-group">
      <h2 class="tool-group__title">${escapeHtml(category.label)}</h2>
      <p class="tool-group__blurb">${escapeHtml(category.blurb)}</p>
      <div class="grid grid--cards">
${ToolCatalog.inCategory(category).map((tool) => toolCard(config, tool)).join('\n')}
      </div>
    </div>''',
      )
      .join('\n');

  final body = lines([
    pageHead(
      config: config,
      title: 'Tools',
      summary:
          '${ToolCatalog.available.length} finished, '
          '${ToolCatalog.roadmap.length} on the way. Every one of them does its '
          'work on your own device.',
      crumbs: [(name: 'Home', path: '')],
    ),
    '<section class="section">\n  <div class="wrap">\n$groups\n  </div>\n</section>',
    openAppBanner(config),
  ]);

  return RenderedPage(
    meta: meta,
    html: renderPage(config: config, meta: meta, body: body, bodyClass: 'page-tools'),
  );
}
