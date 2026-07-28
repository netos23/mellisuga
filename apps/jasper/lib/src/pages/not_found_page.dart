import 'package:mellisuga_content/mellisuga_content.dart';

import '../html.dart';
import '../illustrations.dart';
import '../layout.dart';
import '../seo.dart';
import '../site_config.dart';

/// The 404 page.
///
/// GitHub Pages serves the site root's `404.html` for anything it cannot find,
/// including paths under the app, so this page has to offer both ways out.
/// It only ever exists in English — see [buildAllLocales] — since GitHub
/// Pages has no way to serve a different one per locale prefix anyway.
RenderedPage buildNotFoundPage(SiteConfig config) {
  final strings = config.strings;
  final meta = PageMeta(
    path: '',
    fileName: '404.html',
    title: '${strings.notFoundHeading} — ${Brand.name}',
    description: 'That page does not exist. The tools are all still here.',
    inSitemap: false,
    noIndex: true,
  );

  final body =
      '''
<section class="section not-found">
  <div class="wrap wrap--narrow not-found__inner">
    <div class="not-found__art" aria-hidden="true">
${indent(Illustrations.mark(id: 'lost-bird'), 3)}
    </div>
    <h1>${escapeHtml(strings.notFoundHeading)}</h1>
    <p class="lead">${escapeHtml(strings.notFoundLead)}</p>
    <p class="hero__actions">
      <a class="button button--primary" href="${config.url('')}">${escapeHtml(strings.notFoundBackToStart)}</a>
      <a class="button button--ghost" href="${config.appUrl}">${escapeHtml(strings.navOpenApp)}</a>
    </p>
    <p class="not-found__links">
      ${escapeHtml(strings.notFoundOrJumpTo)}
      <a href="${config.url('tools/')}">${escapeHtml(strings.notFoundTheTools)}</a>,
${LegalContent.documents.map((document) => '      <a href="${config.url(document.path)}">${escapeHtml(document.title.toLowerCase())}</a>').join(',\n')}.
    </p>
  </div>
</section>''';

  return RenderedPage(
    meta: meta,
    html: renderPage(config: config, meta: meta, body: body, bodyClass: 'page-404'),
  );
}
