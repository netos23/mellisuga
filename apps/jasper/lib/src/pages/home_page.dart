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
  final faqs = <FaqEntry>[...Faqs.general, ...ToolCatalog.flagship.faqs];

  final meta = PageMeta(
    path: '',
    // Keyword first, brand last: nobody searches for the brand yet.
    title: '${Copy.heroHeading} — ${Brand.name}',
    description: Brand.shortDescription,
    priority: 1,
    changeFrequency: 'weekly',
    structuredData: [
      StructuredData.website(config),
      StructuredData.softwareApplication(config),
      StructuredData.faqPage(faqs),
    ],
  );

  final body = lines([
    _hero(config),
    _valueProps(),
    _how(),
    _spotlight(config),
    _tools(config),
    _sizes(),
    _platforms(config),
    faqSection(faqs, heading: Copy.faqHeading),
    _closing(config),
  ]);

  return RenderedPage(
    meta: meta,
    html: renderPage(config: config, meta: meta, body: body, bodyClass: 'page-home'),
  );
}

String _hero(SiteConfig config) =>
    '''
<section class="hero">
  <div class="wrap hero__inner">
    <div class="hero__text">
      <p class="eyebrow">${escapeHtml(Brand.tagline)}</p>
      <h1>${escapeHtml(Copy.heroHeading)}<span class="hero__heading-tail"> — without uploading them</span></h1>
      <p class="lead">${escapeHtml(Copy.heroLead)}</p>
      <p class="hero__actions">
        <a class="button button--primary" href="${config.appUrl}">${escapeHtml(Copy.primaryAction)}</a>
        <a class="button button--ghost" href="#how">${escapeHtml(Copy.secondaryAction)}</a>
      </p>
      <ul class="chips">
${Copy.heroChips.map((chip) => '        <li>${escapeHtml(chip)}</li>').join('\n')}
      </ul>
    </div>
    <div class="hero__art" data-reveal>
${indent(Illustrations.heroSheet(), 3)}
    </div>
  </div>
</section>''';

String _valueProps() =>
    '''
<section class="section section--tint" id="why">
  <div class="wrap">
    <h2 class="section__title">Why it is different from the first search result</h2>
    <div class="grid grid--three">
${Copy.valueProps.map(_valueProp).join('\n')}
    </div>
  </div>
</section>''';

String _valueProp(ValueProp prop) =>
    '''
      <article class="card card--prop" data-reveal>
        <div class="card__art">
${indent(Illustrations.valueProp(prop.illustration), 5)}
        </div>
        <h3>${escapeHtml(prop.title)}</h3>
        <p>${escapeHtml(prop.body)}</p>
      </article>''';

String _how() {
  final steps = <String>[];
  for (var index = 0; index < Copy.steps.length; index++) {
    final step = Copy.steps[index];
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
    <h2 class="section__title">Three steps, no sign-up</h2>
    <ol class="steps">
${steps.join('\n')}
    </ol>
  </div>
</section>''';
}

String _spotlight(SiteConfig config) {
  final tool = ToolCatalog.flagship;
  return '''
<section class="section section--tint" id="compose">
  <div class="wrap spotlight">
    <div class="spotlight__text">
      <p class="eyebrow">${escapeHtml(tool.status.label)}</p>
      <h2>${escapeHtml(tool.title)}</h2>
      <p class="lead">${escapeHtml(tool.summary)}</p>
${tool.overview.take(2).map((paragraph) => '      <p>${escapeHtml(paragraph)}</p>').join('\n')}
      <ul class="ticks">
${tool.highlights.map((highlight) => '        <li>${escapeHtml(highlight)}</li>').join('\n')}
      </ul>
      <p class="hero__actions">
        <a class="button button--primary" href="${config.appUrl}">Open it now</a>
        <a class="button button--ghost" href="${config.url(tool.path)}">Read the details</a>
      </p>
    </div>
    <div class="spotlight__art" data-reveal>
${indent(Illustrations.valueProp('packing'), 3)}
    </div>
  </div>
</section>''';
}

String _tools(SiteConfig config) {
  final sections = ToolCategory.values
      .map((category) {
        final tools = ToolCatalog.inCategory(category);
        return '''
    <div class="tool-group">
      <h3 class="tool-group__title">${escapeHtml(category.label)}</h3>
      <p class="tool-group__blurb">${escapeHtml(category.blurb)}</p>
      <div class="grid grid--cards">
${tools.map((tool) => toolCard(config, tool, level: 4)).join('\n')}
      </div>
    </div>''';
      })
      .join('\n');

  return '''
<section class="section" id="tools">
  <div class="wrap">
    <h2 class="section__title">${escapeHtml(Copy.toolsHeading)}</h2>
    <p class="section__lead">${escapeHtml(Copy.toolsLead)}</p>
$sections
  </div>
</section>''';
}

String _sizes() {
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
    <h2 class="section__title">${escapeHtml(Copy.sizesHeading)}</h2>
    <p class="section__lead">${escapeHtml(Copy.sizesLead)}</p>
    <div class="grid grid--two">
      <div class="table-card" data-reveal>
        <h3>Paper</h3>
        <div class="table-scroll">
          <table>
            <caption class="visually-hidden">Built-in paper formats, grouped by standard</caption>
            <tbody>
$paperRows
            </tbody>
          </table>
        </div>
      </div>
      <div class="table-card" data-reveal>
        <h3>Print sizes</h3>
        <div class="table-scroll">
          <table>
            <caption class="visually-hidden">Built-in print size presets, grouped by kind</caption>
            <tbody>
$printRows
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <p class="section__foot">${PaperFormats.all.length} paper formats and ${PhotoSizePresets.all.length} print presets are built in, in portrait or landscape — and any size you type in millimetres, centimetres or inches works just as well.</p>
  </div>
</section>''';
}

String _platforms(SiteConfig config) {
  final rows = Copy.platforms
      .map(
        (platform) =>
            '''
      <li class="platform" data-reveal>
        <h3>${escapeHtml(platform.name)}</h3>
        <p>${escapeHtml(platform.detail)}</p>
        <a href="${platform.isWeb ? config.appUrl : '${Brand.repositoryUrl}/releases'}"${platform.isWeb ? '' : ' rel="noopener"'}>
          ${platform.isWeb ? 'Open in this browser' : 'Download'}
        </a>
      </li>''',
      )
      .join('\n');

  return '''
<section class="section" id="platforms">
  <div class="wrap">
    <h2 class="section__title">${escapeHtml(Copy.platformsHeading)}</h2>
    <p class="section__lead">${escapeHtml(Copy.platformsLead)}</p>
    <ul class="platforms">
$rows
    </ul>
  </div>
</section>''';
}

String _closing(SiteConfig config) =>
    '''
<section class="section closing">
  <div class="wrap closing__inner">
    <div>
      <h2>${escapeHtml(Copy.closingHeading)}</h2>
      <p class="lead">${escapeHtml(Copy.closingBody)}</p>
      <p class="hero__actions">
        <a class="button button--primary" href="${config.appUrl}">${escapeHtml(Copy.primaryAction)}</a>
        <a class="button button--ghost" href="${Brand.repositoryUrl}" rel="noopener">Read the source</a>
      </p>
    </div>
    <div class="closing__art" aria-hidden="true">
${indent(Illustrations.mark(id: 'closing-bird'), 3)}
    </div>
  </div>
</section>''';
