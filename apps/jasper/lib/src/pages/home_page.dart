import 'package:mellisuga_content/mellisuga_content.dart';

import '../copy.dart';
import '../html.dart';
import '../illustrations.dart';
import '../layout.dart';
import '../seo.dart';
import '../site_config.dart';
import 'partials.dart';

/// The home page: what the thing is, why it is different, what it can do, and
/// a link to it — in that order, because that is the order a stranger needs.
RenderedPage buildHomePage(SiteConfig config) {
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

  final body = lines([
    _hero(config),
    _valueProps(config),
    _how(config),
    _spotlight(config),
    _tools(config),
    _sizes(config),
    _platforms(config),
    faqSection(config, faqs, heading: strings.faqHeading),
    _closing(config),
  ]);

  return RenderedPage(
    meta: meta,
    html: renderPage(config: config, meta: meta, body: body, bodyClass: 'page-home'),
  );
}

String _hero(SiteConfig config) {
  final strings = config.strings;
  return '''
<section class="hero">
  <div class="wrap hero__inner">
    <div class="hero__text">
      <p class="eyebrow">${escapeHtml(config.locale.brandTaglineIn())}</p>
      <h1>${escapeHtml(strings.heroHeading)}<span class="hero__heading-tail">${escapeHtml(strings.heroTail)}</span></h1>
      <p class="lead">${escapeHtml(strings.heroLead)}</p>
      <p class="hero__actions">
        <a class="button button--primary" href="${config.appUrl}">${escapeHtml(strings.primaryAction)}</a>
        <a class="button button--ghost" href="#how">${escapeHtml(strings.secondaryAction)}</a>
      </p>
      <ul class="chips">
${strings.heroChips.map((chip) => '        <li>${escapeHtml(chip)}</li>').join('\n')}
      </ul>
    </div>
    <div class="hero__art" data-reveal>
${indent(Illustrations.heroSheet(), 3)}
    </div>
  </div>
</section>''';
}

String _valueProps(SiteConfig config) {
  final strings = config.strings;
  return '''
<section class="section section--tint" id="why">
  <div class="wrap">
    <h2 class="section__title">${escapeHtml(strings.whyDifferentHeading)}</h2>
    <div class="grid grid--three">
${strings.valueProps.map(_valueProp).join('\n')}
    </div>
  </div>
</section>''';
}

String _valueProp(ValueProp prop) =>
    '''
      <article class="card card--prop" data-reveal>
        <div class="card__art">
${indent(Illustrations.valueProp(prop.illustration), 5)}
        </div>
        <h3>${escapeHtml(prop.title)}</h3>
        <p>${escapeHtml(prop.body)}</p>
      </article>''';

String _how(SiteConfig config) {
  final strings = config.strings;
  final steps = <String>[];
  final stepList = strings.steps;
  for (var index = 0; index < stepList.length; index++) {
    final step = stepList[index];
    steps.add('''
      <li class="step" data-reveal style="--delay: ${(index * 0.1).toStringAsFixed(1)}s">
        <div class="step__badge" aria-hidden="true">${index + 1}</div>
${indent(Illustrations.step(index), 4)}
        <h3>${escapeHtml(step.title)}</h3>
        <p>${escapeHtml(step.body)}</p>
      </li>''');
  }

  return '''
<section class="section" id="how">
  <div class="wrap">
    <h2 class="section__title">${escapeHtml(strings.howHeading)}</h2>
    <ol class="steps">
${steps.join('\n')}
    </ol>
  </div>
</section>''';
}

String _spotlight(SiteConfig config) {
  final locale = config.locale;
  final strings = config.strings;
  final tool = ToolCatalog.flagship;
  return '''
<section class="section section--tint" id="compose">
  <div class="wrap spotlight">
    <div class="spotlight__text">
      <p class="eyebrow">${escapeHtml(tool.status.labelIn(locale))}</p>
      <h2>${escapeHtml(tool.titleIn(locale))}</h2>
      <p class="lead">${escapeHtml(tool.summaryIn(locale))}</p>
${tool.overview.take(2).map((paragraph) => '      <p>${escapeHtml(paragraph)}</p>').join('\n')}
      <ul class="ticks">
${tool.highlightsIn(locale).map((highlight) => '        <li>${escapeHtml(highlight)}</li>').join('\n')}
      </ul>
      <p class="hero__actions">
        <a class="button button--primary" href="${config.appUrl}">${escapeHtml(strings.openItNow)}</a>
        <a class="button button--ghost" href="${config.url(tool.path)}">${escapeHtml(strings.readDetails)}</a>
      </p>
    </div>
    <div class="spotlight__art" data-reveal>
${indent(Illustrations.valueProp('packing'), 3)}
    </div>
  </div>
</section>''';
}

String _tools(SiteConfig config) {
  final locale = config.locale;
  final strings = config.strings;
  final sections = ToolCategory.values
      .map((category) {
        final tools = ToolCatalog.inCategory(category);
        return '''
    <div class="tool-group">
      <h3 class="tool-group__title">${escapeHtml(category.labelIn(locale))}</h3>
      <p class="tool-group__blurb">${escapeHtml(category.blurbIn(locale))}</p>
      <div class="grid grid--cards">
${tools.map((tool) => toolCard(config, tool, level: 4)).join('\n')}
      </div>
    </div>''';
      })
      .join('\n');

  return '''
<section class="section" id="tools">
  <div class="wrap">
    <h2 class="section__title">${escapeHtml(strings.toolsHeading)}</h2>
    <p class="section__lead">${escapeHtml(strings.toolsLead)}</p>
$sections
  </div>
</section>''';
}

String _sizes(SiteConfig config) {
  final strings = config.strings;
  final paperRows = PaperFormats.grouped.entries
      .map(
        (entry) =>
            '''
        <tr>
          <th scope="row">${escapeHtml(entry.key)}</th>
          <td>${entry.value.map((format) => escapeHtml(format.name)).join(' · ')}</td>
        </tr>''',
      )
      .join('\n');

  final printRows = PhotoSizePresets.grouped.entries
      .map(
        (entry) =>
            '''
        <tr>
          <th scope="row">${escapeHtml(entry.key)}</th>
          <td>${entry.value.map((preset) => escapeHtml(preset.name)).join(' · ')}</td>
        </tr>''',
      )
      .join('\n');

  return '''
<section class="section section--tint" id="sizes">
  <div class="wrap">
    <h2 class="section__title">${escapeHtml(strings.sizesHeading)}</h2>
    <p class="section__lead">${escapeHtml(strings.sizesLead)}</p>
    <div class="grid grid--two">
      <div class="table-card" data-reveal>
        <h3>${escapeHtml(strings.paperHeading)}</h3>
        <div class="table-scroll">
          <table>
            <caption class="visually-hidden">${escapeHtml(strings.paperCaption)}</caption>
            <tbody>
$paperRows
            </tbody>
          </table>
        </div>
      </div>
      <div class="table-card" data-reveal>
        <h3>${escapeHtml(strings.printSizesHeading)}</h3>
        <div class="table-scroll">
          <table>
            <caption class="visually-hidden">${escapeHtml(strings.printSizesCaption)}</caption>
            <tbody>
$printRows
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <p class="section__foot">${escapeHtml(strings.sizesFoot(PaperFormats.all.length, PhotoSizePresets.all.length))}</p>
  </div>
</section>''';
}

String _platforms(SiteConfig config) {
  final strings = config.strings;
  final rows = strings.platforms
      .map(
        (platform) =>
            '''
      <li class="platform" data-reveal>
        <h3>${escapeHtml(platform.name)}</h3>
        <p>${escapeHtml(platform.detail)}</p>
        <a href="${platform.isWeb ? config.appUrl : '${Brand.repositoryUrl}/releases'}"${platform.isWeb ? '' : ' rel="noopener"'}>
          ${platform.isWeb ? escapeHtml(strings.openInBrowser) : escapeHtml(strings.download)}
        </a>
      </li>''',
      )
      .join('\n');

  return '''
<section class="section" id="platforms">
  <div class="wrap">
    <h2 class="section__title">${escapeHtml(strings.platformsHeading)}</h2>
    <p class="section__lead">${escapeHtml(strings.platformsLead)}</p>
    <ul class="platforms">
$rows
    </ul>
  </div>
</section>''';
}

String _closing(SiteConfig config) {
  final strings = config.strings;
  return '''
<section class="section closing">
  <div class="wrap closing__inner">
    <div>
      <h2>${escapeHtml(strings.closingHeading)}</h2>
      <p class="lead">${escapeHtml(strings.closingBody)}</p>
      <p class="hero__actions">
        <a class="button button--primary" href="${config.appUrl}">${escapeHtml(strings.primaryAction)}</a>
        <a class="button button--ghost" href="${Brand.repositoryUrl}" rel="noopener">${escapeHtml(strings.readSource)}</a>
      </p>
    </div>
    <div class="closing__art" aria-hidden="true">
${indent(Illustrations.mark(id: 'closing-bird'), 3)}
    </div>
  </div>
</section>''';
}
