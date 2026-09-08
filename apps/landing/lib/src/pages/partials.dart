import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:mellisuga_content/mellisuga_content.dart';

import '../site_config.dart';

/// Fragments that appear on more than one page.

/// A tool card, as it appears on the home page and at the foot of every tool
/// page.
///
/// [level] keeps the heading outline honest: the card sits under a category
/// heading on the home page and directly under a section heading elsewhere.
Component toolCard(SiteConfig config, ToolInfo tool, {int level = 3}) {
  final locale = config.locale;
  final label = Component.text(tool.status.labelIn(locale));

  return article(
    classes: 'card card--tool',
    attributes: const {'data-reveal': ''},
    [
      div(classes: 'card__head', [
        Component.element(
          tag: 'h$level',
          classes: 'card__title',
          children: [
            a(href: config.url(tool.path), [Component.text(tool.titleIn(locale))]),
          ],
        ),
        if (tool.status.isAvailable)
          span(classes: 'badge badge--live', [label])
        else
          span(classes: 'badge', [label]),
      ]),
      p([Component.text(tool.summaryIn(locale))]),
    ],
  );
}

/// The FAQ accordion. `<details>` does the work, so it opens with JavaScript
/// switched off and search engines can read every answer.
Component faqSection(
  SiteConfig config,
  List<FaqEntry> entries, {
  required String heading,
  String id = 'faq',
}) {
  final locale = config.locale;
  return section(classes: 'section', id: id, [
    div(classes: 'wrap wrap--narrow', [
      h2(classes: 'section__title', [Component.text(heading)]),
      div(classes: 'faq', [
        for (final entry in entries)
          details(classes: 'faq__item', [
            summary([Component.text(entry.questionIn(locale))]),
            p([Component.text(entry.answerIn(locale))]),
          ]),
      ]),
    ]),
  ]);
}

/// The banner at the top of a subpage: breadcrumb, title, summary.
Component pageHead({
  required SiteConfig config,
  required String title,
  required String summary,
  required List<({String name, String path})> crumbs,
  String? eyebrow,
  bool narrow = false,
}) => section(classes: 'page-head', [
  div(classes: narrow ? 'wrap wrap--narrow' : 'wrap', [
    nav(
      classes: 'crumbs',
      attributes: const {'aria-label': 'Breadcrumb'},
      [
        ol([
          for (final crumb in crumbs)
            li([
              a(href: config.url(crumb.path), [Component.text(crumb.name)]),
            ]),
          li(attributes: const {'aria-current': 'page'}, [Component.text(title)]),
        ]),
      ],
    ),
    if (eyebrow != null) p(classes: 'eyebrow', [Component.text(eyebrow)]),
    h1([Component.text(title)]),
    p(classes: 'lead', [Component.text(summary)]),
  ]),
]);

/// The call to action that closes every subpage.
Component openAppBanner(SiteConfig config, {String? note}) => section(classes: 'section banner', [
  div(classes: 'wrap banner__inner', [
    p(classes: 'banner__text', [Component.text(note ?? config.strings.bannerDefaultNote)]),
    a(classes: 'button button--primary', href: config.appUrl, [
      Component.text(config.strings.navOpenApp),
    ]),
  ]),
]);
