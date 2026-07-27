import 'package:mellisuga_content/mellisuga_content.dart';

import '../html.dart';
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
RenderedPage buildToolPage(SiteConfig config, ToolInfo tool) {
  final related = ToolCatalog.inCategory(
    tool.category,
  ).where((other) => other.id != tool.id).toList(growable: false);

  final meta = PageMeta(
    path: tool.path,
    title: '${tool.title} — ${Brand.name}',
    description: tool.metaDescription,
    priority: tool.status.isAvailable ? 0.9 : 0.4,
    breadcrumbs: [
      const Crumb(name: 'Home', path: ''),
      const Crumb(name: 'Tools', path: 'tools/'),
      Crumb(name: tool.title, path: tool.path),
    ],
    structuredData: [
      StructuredData.tool(config, tool),
      if (tool.faqs.isNotEmpty) StructuredData.faqPage(tool.faqs),
    ],
  );

  final body = lines([
    pageHead(
      config: config,
      title: tool.title,
      summary: tool.summary,
      eyebrow: '${tool.category.label} · ${tool.status.label}',
      crumbs: [(name: 'Home', path: ''), (name: 'Tools', path: 'tools/')],
    ),
    _overview(config, tool),
    if (tool.faqs.isNotEmpty)
      faqSection(tool.faqs, heading: 'About ${_lowerFirst(tool.title)}', id: 'tool-faq'),
    if (related.isNotEmpty) _related(config, related),
    openAppBanner(
      config,
      note: tool.status.isAvailable
          ? 'This tool is ready. It opens in the tab you are already looking at.'
          : 'This one is not built yet — the app has the finished tools in it.',
    ),
  ]);

  return RenderedPage(
    meta: meta,
    html: renderPage(config: config, meta: meta, body: body, bodyClass: 'page-tool'),
  );
}

String _overview(SiteConfig config, ToolInfo tool) {
  final illustration = tool.status.isAvailable
      ? Illustrations.heroSheet()
      : Illustrations.valueProp('packing');

  return '''
<section class="section">
  <div class="wrap tool-detail">
    <div class="tool-detail__text">
${tool.overview.map((paragraph) => '      <p>${escapeHtml(paragraph)}</p>').join('\n')}
      <h2>What it does</h2>
      <ul class="ticks">
${tool.highlights.map((highlight) => '        <li>${escapeHtml(highlight)}</li>').join('\n')}
      </ul>
${tool.status.isAvailable ? _availableActions(config) : _roadmapNote()}
    </div>
    <div class="tool-detail__art" data-reveal>
${indent(illustration, 3)}
    </div>
  </div>
</section>''';
}

String _availableActions(SiteConfig config) =>
    '''
      <p class="hero__actions">
        <a class="button button--primary" href="${config.appUrl}">Open the app</a>
        <a class="button button--ghost" href="${config.url('')}#how">See how it works</a>
      </p>''';

String _roadmapNote() =>
    '''
      <div class="note">
        <h2>Not built yet</h2>
        <p>This tool is on the roadmap and has a page in the app describing what
        it will do. If you need it, say so on the
        <a href="${Brand.issuesUrl}" rel="noopener">issue tracker</a> — that is
        how the order gets decided.</p>
      </div>''';

String _related(SiteConfig config, List<ToolInfo> related) =>
    '''
<section class="section section--tint">
  <div class="wrap">
    <h2 class="section__title">More in the same box</h2>
    <div class="grid grid--cards">
${related.map((tool) => toolCard(config, tool)).join('\n')}
    </div>
  </div>
</section>''';

String _lowerFirst(String value) =>
    value.isEmpty ? value : value[0].toLowerCase() + value.substring(1);
