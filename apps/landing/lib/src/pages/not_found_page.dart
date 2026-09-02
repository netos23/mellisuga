import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:mellisuga_content/mellisuga_content.dart';

import '../illustrations.dart';
import '../layout.dart';
import '../seo.dart';
import '../site_config.dart';

/// The 404 page.
///
/// GitHub Pages serves the site root's `404.html` for anything it cannot find,
/// including paths under the app, so this page has to offer both ways out.
/// It only ever exists in English — see `buildAllLocales` — since GitHub
/// Pages has no way to serve a different one per locale prefix anyway.
SitePage buildNotFoundPage(SiteConfig config) {
  final strings = config.strings;
  final meta = PageMeta(
    path: '',
    fileName: '404.html',
    title: '${strings.notFoundHeading} — ${Brand.name}',
    description: 'That page does not exist. The tools are all still here.',
    inSitemap: false,
    noIndex: true,
  );

  return SitePage(
    meta: meta,
    component: PageLayout(
      config: config,
      page: meta,
      bodyClass: 'page-404',
      children: [
        section(classes: 'section not-found', [
          div(classes: 'wrap wrap--narrow not-found__inner', [
            div(
              classes: 'not-found__art',
              attributes: const {'aria-hidden': 'true'},
              [Illustrations.mark(id: 'lost-bird')],
            ),
            h1([Component.text(strings.notFoundHeading)]),
            p(classes: 'lead', [Component.text(strings.notFoundLead)]),
            p(classes: 'hero__actions', [
              a(classes: 'button button--primary', href: config.url(''), [
                Component.text(strings.notFoundBackToStart),
              ]),
              a(classes: 'button button--ghost', href: config.appUrl, [
                Component.text(strings.navOpenApp),
              ]),
            ]),
            p(classes: 'not-found__links', [
              Component.text('${strings.notFoundOrJumpTo} '),
              a(href: config.url('tools/'), [Component.text(strings.notFoundTheTools)]),
              for (final document in LegalContent.documents) ...[
                const Component.text(', '),
                a(href: config.url(document.path), [Component.text(document.title.toLowerCase())]),
              ],
              const Component.text('.'),
            ]),
          ]),
        ]),
      ],
    ),
  );
}
