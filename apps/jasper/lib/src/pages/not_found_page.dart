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
RenderedPage buildNotFoundPage(SiteConfig config) {
  final meta = PageMeta(
    path: '',
    fileName: '404.html',
    title: 'Page not found — ${Brand.name}',
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
    <h1>Nothing here</h1>
    <p class="lead">The page you asked for does not exist — but nothing was
    uploaded on the way, so no harm done.</p>
    <p class="hero__actions">
      <a class="button button--primary" href="${config.url('')}">Back to the start</a>
      <a class="button button--ghost" href="${config.appUrl}">Open the app</a>
    </p>
    <p class="not-found__links">
      Or jump to
      <a href="${config.url('tools/')}">the tools</a>,
${LegalContent.documents.map((document) => '      <a href="${config.url(document.path)}">${escapeHtml(document.title.toLowerCase())}</a>').join(',\n')}.
    </p>
  </div>
</section>''';

  return RenderedPage(
    meta: meta,
    html: renderPage(config: config, meta: meta, body: body, bodyClass: 'page-404'),
  );
}
