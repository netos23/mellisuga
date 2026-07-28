import 'package:mellisuga_content/mellisuga_content.dart';

import 'site_config.dart';

/// One step in a breadcrumb trail.
class Crumb {
  const Crumb({required this.name, required this.path});

  final String name;

  /// Site-relative path, without a leading slash. Empty means the home page.
  final String path;
}

/// Everything the `<head>` and the sitemap need to know about a page.
class PageMeta {
  const PageMeta({
    required this.path,
    required this.title,
    required this.description,
    this.breadcrumbs = const <Crumb>[],
    this.structuredData = const <Map<String, Object?>>[],
    this.inSitemap = true,
    this.priority = 0.5,
    this.changeFrequency = 'monthly',
    this.fileName,
    this.noIndex = false,
  });

  /// Site-relative directory, ending in a slash. Empty for the home page.
  final String path;

  /// The `<title>`, and the text search results show as the headline.
  final String title;

  /// The meta description.
  final String description;

  final List<Crumb> breadcrumbs;

  /// JSON-LD blocks, in the order they should appear.
  final List<Map<String, Object?>> structuredData;

  final bool inSitemap;

  final double priority;

  final String changeFrequency;

  /// Overrides the usual `<path>/index.html`, for the one page that is not a
  /// directory: `404.html`.
  final String? fileName;

  final bool noIndex;

  /// Where the file is written, relative to the output directory.
  String get filePath => fileName ?? '${path}index.html';
}

/// A page that has been rendered: its metadata and its HTML.
///
/// Page builders return both so the sitemap can be assembled from what was
/// actually generated instead of from a parallel list.
class RenderedPage {
  const RenderedPage({required this.meta, required this.html});

  final PageMeta meta;
  final String html;
}

/// Structured data, written once so every page describes the project the same
/// way to a crawler.
abstract final class StructuredData {
  /// The site itself.
  static Map<String, Object?> website(SiteConfig config) => <String, Object?>{
    '@context': 'https://schema.org',
    '@type': 'WebSite',
    'name': Brand.name,
    'url': config.siteUrl,
    'description': config.locale.brandShortDescriptionIn(),
    'inLanguage': config.locale.code,
    'publisher': <String, Object?>{
      '@type': 'Person',
      'name': Brand.copyrightHolder,
      'url': Brand.authorUrl,
    },
  };

  /// The application. Free, browser-based, and worth telling a search engine
  /// costs nothing — "price: 0" is what produces the "Free" annotation.
  static Map<String, Object?> softwareApplication(SiteConfig config) => <String, Object?>{
    '@context': 'https://schema.org',
    '@type': 'SoftwareApplication',
    'name': Brand.name,
    'url': config.siteUrl,
    'applicationCategory': 'MultimediaApplication',
    'applicationSubCategory': 'Photo and PDF utilities',
    'operatingSystem': Brand.platforms.join(', '),
    'description': config.locale.brandShortDescriptionIn(),
    'browserRequirements': 'Requires JavaScript. Runs entirely client-side.',
    'softwareHelp': config.canonical(ToolCatalog.flagship.path),
    'license': Brand.licenseUrl,
    'isAccessibleForFree': true,
    'offers': <String, Object?>{
      '@type': 'Offer',
      'price': '0',
      'priceCurrency': 'USD',
      'availability': 'https://schema.org/InStock',
    },
    'featureList': ToolCatalog.available
        .expand((tool) => tool.highlightsIn(config.locale))
        .toList(growable: false),
    'author': <String, Object?>{
      '@type': 'Person',
      'name': Brand.copyrightHolder,
      'url': Brand.authorUrl,
    },
    'codeRepository': Brand.repositoryUrl,
  };

  /// One tool, as its own application entry.
  static Map<String, Object?> tool(SiteConfig config, ToolInfo tool) => <String, Object?>{
    '@context': 'https://schema.org',
    '@type': 'SoftwareApplication',
    'name': '${tool.titleIn(config.locale)} — ${Brand.name}',
    'url': config.canonical(tool.path),
    'applicationCategory': 'MultimediaApplication',
    'operatingSystem': Brand.platforms.join(', '),
    'description': tool.metaDescriptionIn(config.locale),
    'isAccessibleForFree': true,
    'offers': <String, Object?>{'@type': 'Offer', 'price': '0', 'priceCurrency': 'USD'},
    'featureList': tool.highlightsIn(config.locale),
    'keywords': tool.keywords.join(', '),
    'softwareVersion': tool.status.isAvailable ? 'released' : 'planned',
  };

  static Map<String, Object?> faqPage(SiteConfig config, List<FaqEntry> entries) =>
      <String, Object?>{
        '@context': 'https://schema.org',
        '@type': 'FAQPage',
        'mainEntity': entries
            .map(
              (entry) => <String, Object?>{
                '@type': 'Question',
                'name': entry.questionIn(config.locale),
                'acceptedAnswer': <String, Object?>{
                  '@type': 'Answer',
                  'text': entry.answerIn(config.locale),
                },
              },
            )
            .toList(growable: false),
      };

  static Map<String, Object?>? breadcrumbs(SiteConfig config, List<Crumb> crumbs) {
    if (crumbs.isEmpty) return null;
    return <String, Object?>{
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      'itemListElement': <Map<String, Object?>>[
        for (var index = 0; index < crumbs.length; index++)
          <String, Object?>{
            '@type': 'ListItem',
            'position': index + 1,
            'name': crumbs[index].name,
            'item': config.canonical(crumbs[index].path),
          },
      ],
    };
  }

  /// A legal document, so search engines label it as one rather than guessing.
  static Map<String, Object?> legalPage(
    SiteConfig config,
    LegalDocument document,
  ) => <String, Object?>{
    '@context': 'https://schema.org',
    '@type': 'WebPage',
    'name': '${document.title} — ${Brand.name}',
    'url': config.canonical(document.path),
    'description': document.summary,
    'dateModified': document.lastUpdated,
    'isPartOf': <String, Object?>{'@type': 'WebSite', 'name': Brand.name, 'url': config.siteUrl},
  };
}

/// One page's entry in the sitemap: its metadata plus the canonical URL it
/// actually resolved to. The URL is precomputed by the caller rather than
/// derived from a single [SiteConfig] here, because a multilingual sitemap
/// mixes pages built under several different locale prefixes.
typedef SitemapEntry = ({String canonicalUrl, PageMeta meta});

/// The sitemap, built from the pages that were actually generated rather than
/// from a hand-kept list — a sitemap that promises a page nobody built is worse
/// than no sitemap.
String renderSitemap(DateTime buildDate, List<SitemapEntry> entries) {
  final stamp = _isoDate(buildDate);
  final rows = entries
      .where((entry) => entry.meta.inSitemap && !entry.meta.noIndex)
      .map(
        (entry) =>
            '  <url>\n'
            '    <loc>${entry.canonicalUrl}</loc>\n'
            '    <lastmod>$stamp</lastmod>\n'
            '    <changefreq>${entry.meta.changeFrequency}</changefreq>\n'
            '    <priority>${entry.meta.priority.toStringAsFixed(1)}</priority>\n'
            '  </url>',
      )
      .join('\n');

  return '<?xml version="1.0" encoding="UTF-8"?>\n'
      '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
      '$rows\n'
      '</urlset>\n';
}

String renderRobots(SiteConfig config) =>
    '''
# Everything here is public and static.
User-agent: *
Allow: /

Sitemap: ${config.canonical('sitemap.xml')}
''';

String _isoDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
