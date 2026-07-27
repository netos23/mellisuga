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

/// Renders the whole site.
///
/// Each page carries its own metadata, so the sitemap is assembled from the
/// pages that were actually built rather than from a second list that has to be
/// kept in step with the first.
Site buildSite(SiteConfig config) {
  final pages = <RenderedPage>[
    buildHomePage(config),
    buildToolsIndexPage(config),
    for (final tool in ToolCatalog.tools) buildToolPage(config, tool),
    for (final document in LegalContent.documents) buildLegalPage(config, document),
    buildNotFoundPage(config),
  ];

  final files = <String, String>{
    for (final page in pages) page.meta.filePath: page.html,
    'styles.css': Assets.styles,
    'site.js': Assets.script,
    'icon.svg': Illustrations.faviconFile(),
    'sitemap.xml': renderSitemap(config, pages.map((page) => page.meta).toList(growable: false)),
    'robots.txt': renderRobots(config),
    // GitHub Pages runs Jekyll unless told otherwise, and Jekyll silently drops
    // files and directories whose names begin with an underscore.
    '.nojekyll': '',
  };

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
