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

  final body = lines([
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
  ]);

  return RenderedPage(
    meta: meta,
    html: renderPage(config: config, meta: meta, body: body, bodyClass: 'page-tool'),
  );
}

String _overview(SiteConfig config, ToolInfo tool) {
  final locale = config.locale;
  final strings = config.strings;
  final illustration = tool.status.isAvailable
      ? Illustrations.heroSheet()
      : Illustrations.valueProp('packing');

  return '''
<section class="section">
  <div class="wrap tool-detail">
    <div class="tool-detail__text">
${tool.overview.map((paragraph) => '      <p>${escapeHtml(paragraph)}</p>').join('\n')}
      <h2>${escapeHtml(strings.whatItDoes)}</h2>
      <ul class="ticks">
${tool.highlightsIn(locale).map((highlight) => '        <li>${escapeHtml(highlight)}</li>').join('\n')}
      </ul>
${tool.status.isAvailable ? _availableActions(config) : _roadmapNote(config)}
    </div>
    <div class="tool-detail__art" data-reveal>
${indent(illustration, 3)}
    </div>
  </div>
</section>''';
}

String _availableActions(SiteConfig config) {
  final strings = config.strings;
  return '''
      <p class="hero__actions">
        <a class="button button--primary" href="${config.appUrl}">${escapeHtml(strings.navOpenApp)}</a>
        <a class="button button--ghost" href="${config.url('')}#how">${escapeHtml(strings.seeHowItWorks)}</a>
      </p>''';
}

String _roadmapNote(SiteConfig config) {
  final strings = config.strings;
  return '''
      <div class="note">
        <h2>${escapeHtml(strings.notBuiltYetHeading)}</h2>
        <p>${escapeHtml(strings.notBuiltYetBodyBefore)}
        <a href="${Brand.issuesUrl}" rel="noopener">${escapeHtml(strings.notBuiltYetBodyLinkText)}</a>
        ${escapeHtml(strings.notBuiltYetBodyAfter)}</p>
      </div>''';
}

String _related(SiteConfig config, List<ToolInfo> related) =>
    '''
<section class="section section--tint">
  <div class="wrap">
    <h2 class="section__title">${escapeHtml(config.strings.moreInTheBox)}</h2>
    <div class="grid grid--cards">
${related.map((tool) => toolCard(config, tool)).join('\n')}
    </div>
  </div>
</section>''';

String _lowerFirst(String value) =>
    value.isEmpty ? value : value[0].toLowerCase() + value.substring(1);
