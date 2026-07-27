import 'package:mellisuga_content/mellisuga_content.dart';

import '../html.dart';
import '../site_config.dart';

/// Fragments that appear on more than one page.

/// A tool card, as it appears on the home page and at the foot of every tool
/// page.
///
/// [level] keeps the heading outline honest: the card sits under a category
/// heading on the home page and directly under a section heading elsewhere.
String toolCard(SiteConfig config, ToolInfo tool, {int level = 3}) {
  final status = tool.status.isAvailable
      ? '<span class="badge badge--live">${escapeHtml(tool.status.label)}</span>'
      : '<span class="badge">${escapeHtml(tool.status.label)}</span>';

  return '''
        <article class="card card--tool" data-reveal>
          <div class="card__head">
            <h$level class="card__title"><a href="${config.url(tool.path)}">${escapeHtml(tool.title)}</a></h$level>
            $status
          </div>
          <p>${escapeHtml(tool.summary)}</p>
        </article>''';
}

/// The FAQ accordion. `<details>` does the work, so it opens with JavaScript
/// switched off and search engines can read every answer.
String faqSection(List<FaqEntry> entries, {required String heading, String id = 'faq'}) {
  final items = entries
      .map(
        (entry) =>
            '''
      <details class="faq__item">
        <summary>${escapeHtml(entry.question)}</summary>
        <p>${escapeHtml(entry.answer)}</p>
      </details>''',
      )
      .join('\n');

  return '''
<section class="section" id="$id">
  <div class="wrap wrap--narrow">
    <h2 class="section__title">${escapeHtml(heading)}</h2>
    <div class="faq">
$items
    </div>
  </div>
</section>''';
}

/// The banner at the top of a subpage: breadcrumb, title, summary.
String pageHead({
  required SiteConfig config,
  required String title,
  required String summary,
  required List<({String name, String path})> crumbs,
  String? eyebrow,
  bool narrow = false,
}) {
  final trail = crumbs
      .map((crumb) => '<li><a href="${config.url(crumb.path)}">${escapeHtml(crumb.name)}</a></li>')
      .join('\n        ');

  return '''
<section class="page-head">
  <div class="wrap${narrow ? ' wrap--narrow' : ''}">
    <nav class="crumbs" aria-label="Breadcrumb">
      <ol>
        $trail
        <li aria-current="page">${escapeHtml(title)}</li>
      </ol>
    </nav>
    ${eyebrow == null ? '' : '<p class="eyebrow">${escapeHtml(eyebrow)}</p>'}
    <h1>${escapeHtml(title)}</h1>
    <p class="lead">${escapeHtml(summary)}</p>
  </div>
</section>''';
}

/// The call to action that closes every subpage.
String openAppBanner(SiteConfig config, {String? note}) =>
    '''
<section class="section banner">
  <div class="wrap banner__inner">
    <p class="banner__text">${escapeHtml(note ?? 'Everything here runs in your browser. Nothing is uploaded.')}</p>
    <a class="button button--primary" href="${config.appUrl}">Open the app</a>
  </div>
</section>''';
