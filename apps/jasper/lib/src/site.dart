import 'dart:io';

import 'package:mellisuga_content/mellisuga_content.dart';

import 'assets.dart';
import 'illustrations.dart';
import 'pages/home_page.dart';
import 'pages/legal_page.dart';
import 'pages/not_found_page.dart';
import 'pages/tool_page.dart';
import 'pages/tools_index_page.dart';
import 'seo.dart';
import 'site_config.dart';

/// A generated site, held in memory.
///
/// Building to a map rather than straight to disk keeps the generator a pure
/// function: the tests assert on the same bytes the deploy writes, without a
/// temporary directory in sight.
class Site {
  const Site({required this.files, required this.pages});

  /// Output path, relative to the site root, to file contents.
  final Map<String, String> files;

  /// Every page that was rendered, in build order.
  final List<RenderedPage> pages;

  int get byteCount => files.values.fold(0, (total, contents) => total + contents.length);
}

/// Renders one locale's pages.
///
/// Each page carries its own metadata, so the sitemap is assembled from the
/// pages that were actually built rather than from a second list that has to be
/// kept in step with the first. [includeNotFoundPage] is `false` when this is
/// being built as one of the non-default locales inside [buildAllLocales] —
/// GitHub Pages only ever serves a single site-root `404.html`, so there is no
/// use in building one under every locale prefix too.
List<RenderedPage> _buildPages(SiteConfig config, {bool includeNotFoundPage = true}) =>
    <RenderedPage>[
      buildHomePage(config),
      buildToolsIndexPage(config),
      for (final tool in ToolCatalog.tools) buildToolPage(config, tool),
      for (final document in LegalContent.documents) buildLegalPage(config, document),
      if (includeNotFoundPage) buildNotFoundPage(config),
    ];

/// Renders the site in a single locale — [config.locale], defaulting to
/// English — at the site root, exactly as if the other seven languages did
/// not exist. This is what every pre-existing test builds against; multi-
/// language builds go through [buildAllLocales] instead.
Site buildSite(SiteConfig config) {
  final pages = _buildPages(config);

  final files = <String, String>{
    for (final page in pages) page.meta.filePath: page.html,
    'styles.css': Assets.styles,
    'site.js': Assets.script,
    'icon.svg': Illustrations.faviconFile(),
    'sitemap.xml': renderSitemap(config.buildDate, [
      for (final page in pages) (canonicalUrl: config.canonical(page.meta.path), meta: page.meta),
    ]),
    'robots.txt': renderRobots(config),
    // GitHub Pages runs Jekyll unless told otherwise, and Jekyll silently drops
    // files and directories whose names begin with an underscore.
    '.nojekyll': '',
  };

  return Site(files: files, pages: pages);
}

/// Renders the full multilingual site: [AppLocale.en] at the site root, as
/// [buildSite] already does, plus every other [AppLocale] under its own path
/// prefix (`fr/`, `de/`, …). The two share one stylesheet, script, icon,
/// `robots.txt`, `.nojekyll` marker and site-root `404.html` — only the pages
/// themselves are built again per locale — and one sitemap lists every page
/// from every language.
///
/// [config]'s own `locale` field is ignored; it exists so callers can still
/// pass the same [SiteConfig] they would give [buildSite].
Site buildAllLocales(SiteConfig config) {
  final english = buildSite(config.withLocale(AppLocale.en));

  final pages = <RenderedPage>[...english.pages];
  final files = <String, String>{...english.files};
  final sitemapEntries = <SitemapEntry>[
    for (final page in english.pages)
      (canonicalUrl: config.withLocale(AppLocale.en).canonical(page.meta.path), meta: page.meta),
  ];

  for (final locale in AppLocale.values) {
    if (locale == AppLocale.en) continue;
    final localeConfig = config.withLocale(locale);
    final localePages = _buildPages(localeConfig, includeNotFoundPage: false);

    pages.addAll(localePages);
    for (final page in localePages) {
      files['${localeConfig.localePrefix}${page.meta.filePath}'] = page.html;
      sitemapEntries.add((canonicalUrl: localeConfig.canonical(page.meta.path), meta: page.meta));
    }
  }

  files['sitemap.xml'] = renderSitemap(config.buildDate, sitemapEntries);

  return Site(files: files, pages: pages);
}

/// Writes [site] into [directory], replacing whatever was there.
///
/// The directory is emptied first so a page that has been renamed cannot
/// survive as a stale file — in nobody's sitemap, but still answering requests.
Future<void> writeSite(Site site, Directory directory) async {
  if (directory.existsSync()) directory.deleteSync(recursive: true);
  directory.createSync(recursive: true);

  for (final entry in site.files.entries) {
    final file = File('${directory.path}/${entry.key}');
    file.parent.createSync(recursive: true);
    await file.writeAsString(entry.value);
  }
}
