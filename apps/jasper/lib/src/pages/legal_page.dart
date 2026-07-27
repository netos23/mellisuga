import 'package:mellisuga_content/mellisuga_content.dart';

import '../html.dart';
import '../layout.dart';
import '../seo.dart';
import '../site_config.dart';
import 'partials.dart';

/// A page per legal document, rendered from the same text the app shows on its
/// own screens. Neither copy can drift, because there is only one.
RenderedPage buildLegalPage(SiteConfig config, LegalDocument document) {
  final meta = PageMeta(
    path: document.path,
    title: '${document.title} — ${Brand.name}',
    description: document.summary,
    priority: 0.3,
    changeFrequency: 'yearly',
    breadcrumbs: [
      const Crumb(name: 'Home', path: ''),
      Crumb(name: document.title, path: document.path),
    ],
    structuredData: [StructuredData.legalPage(config, document)],
  );

  final body = lines([
    pageHead(
      config: config,
      title: document.title,
      summary: document.summary,
      eyebrow: 'Last updated ${document.lastUpdated}',
      crumbs: [(name: 'Home', path: '')],
      // Matches the column the document itself is set in.
      narrow: true,
    ),
    _document(config, document),
    openAppBanner(config, note: 'Every word above describes how the app already behaves.'),
  ]);

  return RenderedPage(
    meta: meta,
    html: renderPage(config: config, meta: meta, body: body, bodyClass: 'page-legal'),
  );
}

String _document(SiteConfig config, LegalDocument document) {
  final contents = document.sections
      .map(
        (section) =>
            '        <li><a href="#${section.anchor}">${escapeHtml(section.heading)}</a></li>',
      )
      .join('\n');

  final sections = document.sections.map(_section).join('\n');

  return '''
<section class="section">
  <div class="wrap wrap--narrow prose">
    <nav class="toc" aria-label="On this page">
      <h2>On this page</h2>
      <ol>
$contents
      </ol>
    </nav>

$sections
${document.id == 'licences' ? _components() : ''}
    <p class="prose__foot">
      The same document is readable inside the app under
      <strong>About</strong>, and its history is in the
      <a href="${Brand.repositoryUrl}" rel="noopener">public source repository</a>.
      Other documents:
${LegalContent.documents.where((other) => other.id != document.id).map((other) => '      <a href="${config.url(other.path)}">${escapeHtml(other.title)}</a>').join(' ·\n')}
    </p>
  </div>
</section>''';
}

String _section(LegalSection section) {
  final paragraphs = section.paragraphs
      .map((paragraph) => '    <p>${escapeHtml(paragraph)}</p>')
      .join('\n');
  final bullets = section.bullets.isEmpty
      ? ''
      : '    <ul>\n'
            '${section.bullets.map((bullet) => '      <li>${escapeHtml(bullet)}</li>').join('\n')}\n'
            '    </ul>';

  return lines([
    '    <h2 id="${section.anchor}">${escapeHtml(section.heading)}</h2>',
    paragraphs,
    bullets,
  ]);
}

/// The bundled-component tables, appended to the licences page.
String _components() {
  final groups = ComponentGroup.values
      .map(
        (group) =>
            '''
    <h3>${escapeHtml(group.label)}</h3>
    <div class="table-scroll">
      <table>
        <thead>
          <tr><th scope="col">Component</th><th scope="col">Licence</th><th scope="col">Used for</th></tr>
        </thead>
        <tbody>
${ThirdPartyNotices.inGroup(group).map(_componentRow).join('\n')}
        </tbody>
      </table>
    </div>''',
      )
      .join('\n');

  return '''
    <h2 id="components">The list</h2>
$groups''';
}

String _componentRow(ThirdPartyComponent component) {
  final url = component.url;
  final name = url == null
      ? escapeHtml(component.name)
      : '<a href="${escapeHtml(url)}" rel="noopener">${escapeHtml(component.name)}</a>';
  return '          <tr><td>$name</td><td>${escapeHtml(component.licence)}</td>'
      '<td>${escapeHtml(component.purpose)}</td></tr>';
}
