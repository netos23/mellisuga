import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:mellisuga_content/mellisuga_content.dart';

import '../copy.dart';
import '../illustrations.dart';
import '../layout.dart';
import '../seo.dart';
import '../site_config.dart';
import 'partials.dart';

/// The home page: what the thing is, why it is different, what it can do, and
/// a link to it — in that order, because that is the order a stranger needs.
SitePage buildHomePage(SiteConfig config) {
  final locale = config.locale;
  final strings = config.strings;
  final faqs = <FaqEntry>[...Faqs.general, ...ToolCatalog.flagship.faqs];

  final meta = PageMeta(
    path: '',
    // Keyword first, brand last: nobody searches for the brand yet.
    title: '${strings.heroHeading} — ${Brand.name}',
    description: locale.brandShortDescriptionIn(),
    priority: 1,
    changeFrequency: 'weekly',
    structuredData: [
      StructuredData.website(config),
      StructuredData.softwareApplication(config),
      StructuredData.faqPage(config, faqs),
    ],
  );

  return SitePage(
    meta: meta,
    component: PageLayout(
      config: config,
      page: meta,
      bodyClass: 'page-home',
      children: [
        _hero(config),
        _valueProps(config),
        _how(config),
        _spotlight(config),
        _tools(config),
        _sizes(config),
        _platforms(config),
        faqSection(config, faqs, heading: strings.faqHeading),
        _closing(config),
      ],
    ),
  );
}

Component _hero(SiteConfig config) {
  final strings = config.strings;
  return section(classes: 'hero', [
    div(classes: 'wrap hero__inner', [
      div(classes: 'hero__text', [
        p(classes: 'eyebrow', [Component.text(config.locale.brandTaglineIn())]),
        h1([
          Component.text(strings.heroHeading),
          span(classes: 'hero__heading-tail', [Component.text(strings.heroTail)]),
        ]),
        p(classes: 'lead', [Component.text(strings.heroLead)]),
        p(classes: 'hero__actions', [
          a(classes: 'button button--primary', href: config.appUrl, [
            Component.text(strings.primaryAction),
          ]),
          a(classes: 'button button--ghost', href: '#how', [
            Component.text(strings.secondaryAction),
          ]),
        ]),
        ul(classes: 'chips', [
          for (final chip in strings.heroChips) li([Component.text(chip)]),
        ]),
      ]),
      div(classes: 'hero__art', attributes: const {'data-reveal': ''}, [Illustrations.heroSheet()]),
    ]),
  ]);
}

Component _valueProps(SiteConfig config) {
  final strings = config.strings;
  return section(classes: 'section section--tint', id: 'why', [
    div(classes: 'wrap', [
      h2(classes: 'section__title', [Component.text(strings.whyDifferentHeading)]),
      div(classes: 'grid grid--three', [for (final prop in strings.valueProps) _valueProp(prop)]),
    ]),
  ]);
}

Component _valueProp(ValueProp prop) => article(
  classes: 'card card--prop',
  attributes: const {'data-reveal': ''},
  [
    div(classes: 'card__art', [Illustrations.valueProp(prop.illustration)]),
    h3([Component.text(prop.title)]),
    p([Component.text(prop.body)]),
  ],
);

Component _how(SiteConfig config) {
  final strings = config.strings;
  return section(classes: 'section', id: 'how', [
    div(classes: 'wrap', [
      h2(classes: 'section__title', [Component.text(strings.howHeading)]),
      ol(classes: 'steps', [
        for (final (index, step) in strings.steps.indexed)
          li(
            classes: 'step',
            attributes: {
              'data-reveal': '',
              'style': '--delay: ${(index * 0.1).toStringAsFixed(1)}s',
            },
            [
              div(
                classes: 'step__badge',
                attributes: const {'aria-hidden': 'true'},
                [Component.text('${index + 1}')],
              ),
              Illustrations.step(index),
              h3([Component.text(step.title)]),
              p([Component.text(step.body)]),
            ],
          ),
      ]),
    ]),
  ]);
}

Component _spotlight(SiteConfig config) {
  final locale = config.locale;
  final strings = config.strings;
  final tool = ToolCatalog.flagship;
  return section(classes: 'section section--tint', id: 'compose', [
    div(classes: 'wrap spotlight', [
      div(classes: 'spotlight__text', [
        p(classes: 'eyebrow', [Component.text(tool.status.labelIn(locale))]),
        h2([Component.text(tool.titleIn(locale))]),
        p(classes: 'lead', [Component.text(tool.summaryIn(locale))]),
        for (final paragraph in tool.overview.take(2)) p([Component.text(paragraph)]),
        ul(classes: 'ticks', [
          for (final highlight in tool.highlightsIn(locale)) li([Component.text(highlight)]),
        ]),
        p(classes: 'hero__actions', [
          a(classes: 'button button--primary', href: config.appUrl, [
            Component.text(strings.openItNow),
          ]),
          a(classes: 'button button--ghost', href: config.url(tool.path), [
            Component.text(strings.readDetails),
          ]),
        ]),
      ]),
      div(
        classes: 'spotlight__art',
        attributes: const {'data-reveal': ''},
        [Illustrations.valueProp('packing')],
      ),
    ]),
  ]);
}

Component _tools(SiteConfig config) {
  final locale = config.locale;
  final strings = config.strings;
  return section(classes: 'section', id: 'tools', [
    div(classes: 'wrap', [
      h2(classes: 'section__title', [Component.text(strings.toolsHeading)]),
      p(classes: 'section__lead', [Component.text(strings.toolsLead)]),
      for (final category in ToolCategory.values)
        div(classes: 'tool-group', [
          h3(classes: 'tool-group__title', [Component.text(category.labelIn(locale))]),
          p(classes: 'tool-group__blurb', [Component.text(category.blurbIn(locale))]),
          div(classes: 'grid grid--cards', [
            for (final tool in ToolCatalog.inCategory(category)) toolCard(config, tool, level: 4),
          ]),
        ]),
    ]),
  ]);
}

Component _sizes(SiteConfig config) {
  final strings = config.strings;
  return section(classes: 'section section--tint', id: 'sizes', [
    div(classes: 'wrap', [
      h2(classes: 'section__title', [Component.text(strings.sizesHeading)]),
      p(classes: 'section__lead', [Component.text(strings.sizesLead)]),
      div(classes: 'grid grid--two', [
        _sizeTable(
          heading: strings.paperHeading,
          caption: strings.paperCaption,
          rows: {
            for (final entry in PaperFormats.grouped.entries)
              entry.key: entry.value.map((format) => format.name).join(' · '),
          },
        ),
        _sizeTable(
          heading: strings.printSizesHeading,
          caption: strings.printSizesCaption,
          rows: {
            for (final entry in PhotoSizePresets.grouped.entries)
              entry.key: entry.value.map((preset) => preset.name).join(' · '),
          },
        ),
      ]),
      p(classes: 'section__foot', [
        Component.text(strings.sizesFoot(PaperFormats.all.length, PhotoSizePresets.all.length)),
      ]),
    ]),
  ]);
}

Component _sizeTable({
  required String heading,
  required String caption,
  required Map<String, String> rows,
}) => div(
  classes: 'table-card',
  attributes: const {'data-reveal': ''},
  [
    h3([Component.text(heading)]),
    div(classes: 'table-scroll', [
      table([
        Component.element(
          tag: 'caption',
          classes: 'visually-hidden',
          children: [Component.text(caption)],
        ),
        tbody([
          for (final row in rows.entries)
            tr([
              th(scope: 'row', [Component.text(row.key)]),
              td([Component.text(row.value)]),
            ]),
        ]),
      ]),
    ]),
  ],
);

Component _platforms(SiteConfig config) {
  final strings = config.strings;
  return section(classes: 'section', id: 'platforms', [
    div(classes: 'wrap', [
      h2(classes: 'section__title', [Component.text(strings.platformsHeading)]),
      p(classes: 'section__lead', [Component.text(strings.platformsLead)]),
      ul(classes: 'platforms', [
        for (final platform in strings.platforms)
          li(
            classes: 'platform',
            attributes: const {'data-reveal': ''},
            [
              h3([Component.text(platform.name)]),
              p([Component.text(platform.detail)]),
              if (platform.isWeb)
                a(href: config.appUrl, [Component.text(strings.openInBrowser)])
              else
                externalLink(href: '${Brand.repositoryUrl}/releases', [
                  Component.text(strings.download),
                ]),
            ],
          ),
      ]),
    ]),
  ]);
}

Component _closing(SiteConfig config) {
  final strings = config.strings;
  return section(classes: 'section closing', [
    div(classes: 'wrap closing__inner', [
      div([
        h2([Component.text(strings.closingHeading)]),
        p(classes: 'lead', [Component.text(strings.closingBody)]),
        p(classes: 'hero__actions', [
          a(classes: 'button button--primary', href: config.appUrl, [
            Component.text(strings.primaryAction),
          ]),
          externalLink(classes: 'button button--ghost', href: Brand.repositoryUrl, [
            Component.text(strings.readSource),
          ]),
        ]),
      ]),
      div(
        classes: 'closing__art',
        attributes: const {'aria-hidden': 'true'},
        [Illustrations.mark(id: 'closing-bird')],
      ),
    ]),
  ]);
}
