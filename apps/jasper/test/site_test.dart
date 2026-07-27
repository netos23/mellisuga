import 'dart:convert';

import 'package:jasper/jasper.dart';
import 'package:mellisuga_content/mellisuga_content.dart';
import 'package:test/test.dart';

/// A build at a project subpath, which is how the site is actually deployed —
/// testing at `/` would hide every hard-coded root-relative link.
SiteConfig config() => SiteConfig(
  baseHref: '/mellisuga/',
  siteUrl: 'https://netos23.github.io/mellisuga/',
  buildDate: DateTime.utc(2026, 7, 27),
);

Iterable<String> htmlFiles(Site site) =>
    site.files.entries.where((entry) => entry.key.endsWith('.html')).map((entry) => entry.value);

/// Every `href`/`src` value in [html].
List<String> linksIn(String html) => RegExp(
  r'(?:href|src)="([^"]*)"',
).allMatches(html).map((match) => match.group(1)!).toList(growable: false);

void main() {
  final site = buildSite(config());

  group('files', () {
    test('the pages that must exist do', () {
      expect(site.files, contains('index.html'));
      expect(site.files, contains('tools/index.html'));
      expect(site.files, contains('404.html'));
      expect(site.files, contains('sitemap.xml'));
      expect(site.files, contains('robots.txt'));
      expect(site.files, contains('styles.css'));
      expect(site.files, contains('site.js'));
      expect(site.files, contains('icon.svg'));
      expect(site.files, contains('.nojekyll'));
    });

    test('every tool in the catalogue gets a page', () {
      for (final tool in ToolCatalog.tools) {
        expect(site.files, contains('${tool.path}index.html'), reason: tool.id);
      }
    });

    test('every legal document gets a page', () {
      for (final document in LegalContent.documents) {
        expect(site.files, contains('${document.path}index.html'), reason: document.id);
      }
    });

    test('nothing is empty except the Jekyll opt-out', () {
      for (final entry in site.files.entries) {
        if (entry.key == '.nojekyll') continue;
        expect(entry.value.trim(), isNotEmpty, reason: entry.key);
      }
    });
  });

  group('every page', () {
    test('is a complete document', () {
      for (final html in htmlFiles(site)) {
        expect(html, startsWith('<!DOCTYPE html>'));
        expect(html, contains('<html lang="en"'));
        expect(html, contains('</html>'));
        expect(html, contains('<meta charset="utf-8">'));
        expect(html, contains('name="viewport"'));
      }
    });

    test('has exactly one h1', () {
      for (final entry in site.files.entries) {
        if (!entry.key.endsWith('.html')) continue;
        expect(RegExp('<h1[ >]').allMatches(entry.value).length, 1, reason: entry.key);
      }
    });

    test('has a title and a description of a usable length', () {
      for (final page in site.pages) {
        expect(page.meta.title.length, inInclusiveRange(20, 70), reason: page.meta.filePath);
        expect(page.meta.description.length, inInclusiveRange(50, 170), reason: page.meta.filePath);
      }
    });

    test('has a canonical URL that matches where the file is written', () {
      for (final page in site.pages) {
        if (page.meta.noIndex) continue;
        expect(
          page.html,
          contains(
            '<link rel="canonical" href="https://netos23.github.io/mellisuga/'
            '${page.meta.path}">',
          ),
          reason: page.meta.filePath,
        );
      }
    });

    test('carries Open Graph and Twitter cards', () {
      for (final html in htmlFiles(site)) {
        expect(html, contains('property="og:title"'));
        expect(html, contains('property="og:description"'));
        expect(html, contains('property="og:url"'));
        expect(html, contains('name="twitter:card"'));
      }
    });

    test('links to the stylesheet and script under the base href', () {
      for (final html in htmlFiles(site)) {
        expect(html, contains('href="/mellisuga/styles.css"'));
        expect(html, contains('src="/mellisuga/site.js"'));
      }
    });

    test('has a skip link and a labelled main landmark', () {
      for (final html in htmlFiles(site)) {
        expect(html, contains('class="skip-link" href="#main"'));
        expect(html, contains('<main id="main">'));
      }
    });

    test('offers the same legal links the app does', () {
      for (final html in htmlFiles(site)) {
        for (final document in LegalContent.documents) {
          expect(html, contains('href="/mellisuga/${document.path}"'), reason: document.id);
        }
        expect(html, contains(Brand.licenseUrl));
      }
    });

    test('links to the app, never embeds it', () {
      for (final html in htmlFiles(site)) {
        expect(html, contains('href="/mellisuga/app/"'));
      }
      // Nothing in the output may reference the Flutter build's own files: the
      // landing links to the app, it does not ship any part of it.
      for (final html in htmlFiles(site)) {
        expect(html, isNot(contains('flutter_bootstrap.js')));
        expect(html, isNot(contains('main.dart.js')));
        expect(html, isNot(contains('canvaskit')));
      }
    });
  });

  group('privacy promises the page itself has to keep', () {
    test('no page loads a resource from another origin', () {
      // Anchors to GitHub are fine — the promise is that nothing is *fetched*
      // from a third party while the page renders.
      final resources = <RegExp>[
        RegExp(r'<script[^>]*\ssrc="([^"]+)"'),
        RegExp(r'<img[^>]*\ssrc="([^"]+)"'),
        // Only the tags that fetch something: a canonical URL is a claim about
        // this page's address, not a request.
        RegExp(
          r'<link[^>]*\srel="(?:stylesheet|icon|preload|apple-touch-icon)"[^>]*\shref="([^"]+)"',
        ),
      ];

      for (final entry in site.files.entries) {
        if (!entry.key.endsWith('.html')) continue;
        for (final pattern in resources) {
          for (final match in pattern.allMatches(entry.value)) {
            final url = match.group(1)!;
            expect(
              url.startsWith('http://') || url.startsWith('https://') || url.startsWith('//'),
              isFalse,
              reason: '${entry.key} loads $url from another origin',
            );
          }
        }
      }
    });

    test('external links are only ever anchors, and carry rel="noopener"', () {
      for (final entry in site.files.entries) {
        if (!entry.key.endsWith('.html')) continue;
        final anchors = RegExp(r'<a\b[^>]*>').allMatches(entry.value);
        for (final anchor in anchors) {
          final tag = anchor.group(0)!;
          if (!tag.contains('href="http')) continue;
          expect(tag, contains('rel="noopener"'), reason: '${entry.key}: $tag');
        }
      }
    });

    test('the stylesheet imports nothing and the script fetches nothing', () {
      expect(site.files['styles.css'], isNot(contains('@import')));
      expect(site.files['styles.css'], isNot(contains('url(http')));
      expect(site.files['site.js'], isNot(contains('fetch(')));
      expect(site.files['site.js'], isNot(contains('XMLHttpRequest')));
    });

    test('no analytics or tracking snippets crept in', () {
      for (final entry in site.files.entries) {
        final haystack = entry.value.toLowerCase();
        for (final tracker in ['google-analytics', 'gtag(', 'googletagmanager', 'facebook.net']) {
          expect(haystack, isNot(contains(tracker)), reason: '${entry.key} mentions $tracker');
        }
      }
    });
  });

  group('structured data', () {
    List<Map<String, Object?>> blocksIn(String html) => RegExp(
      r'<script type="application/ld\+json">(.*?)</script>',
      dotAll: true,
    ).allMatches(html).map((match) => jsonDecode(match.group(1)!) as Map<String, Object?>).toList();

    test('every block is valid JSON with a schema.org type', () {
      for (final entry in site.files.entries) {
        if (!entry.key.endsWith('.html')) continue;
        for (final block in blocksIn(entry.value)) {
          expect(block['@context'], 'https://schema.org', reason: entry.key);
          expect(block['@type'], isNotNull, reason: entry.key);
        }
      }
    });

    test('the home page describes the site, the app and the FAQ', () {
      final types = blocksIn(site.files['index.html']!).map((block) => block['@type']).toList();
      expect(types, containsAll(<String>['WebSite', 'SoftwareApplication', 'FAQPage']));
    });

    test('the FAQ block matches the questions on the page', () {
      final faq = blocksIn(
        site.files['index.html']!,
      ).firstWhere((block) => block['@type'] == 'FAQPage');
      final questions = (faq['mainEntity']! as List<Object?>)
          .map((entry) => (entry! as Map<String, Object?>)['name'] as String)
          .toList();
      expect(questions, containsAll(Faqs.general.map((entry) => entry.question)));
      for (final question in questions) {
        expect(site.files['index.html'], contains(_escaped(question)));
      }
    });

    test('subpages carry a breadcrumb trail that resolves', () {
      final page = site.files['${ToolCatalog.flagship.path}index.html']!;
      final crumbs = blocksIn(page).firstWhere((block) => block['@type'] == 'BreadcrumbList');
      final items = (crumbs['itemListElement']! as List<Object?>)
          .map((entry) => (entry! as Map<String, Object?>)['item'] as String)
          .toList();
      expect(items.first, 'https://netos23.github.io/mellisuga/');
      for (final item in items) {
        final path = item.replaceFirst('https://netos23.github.io/mellisuga/', '');
        expect(site.files, contains('${path}index.html'), reason: item);
      }
    });
  });

  group('sitemap and robots', () {
    test('the sitemap lists every indexable page and nothing else', () {
      final sitemap = site.files['sitemap.xml']!;
      final locations = RegExp(
        r'<loc>(.*?)</loc>',
      ).allMatches(sitemap).map((match) => match.group(1)!).toList();

      final expected = site.pages
          .where((page) => page.meta.inSitemap && !page.meta.noIndex)
          .map((page) => 'https://netos23.github.io/mellisuga/${page.meta.path}')
          .toList();

      expect(locations, expected);
      expect(locations.toSet().length, locations.length, reason: 'duplicate entries');
      expect(sitemap, isNot(contains('404.html')));
    });

    test('every sitemap entry corresponds to a generated file', () {
      for (final match in RegExp(r'<loc>(.*?)</loc>').allMatches(site.files['sitemap.xml']!)) {
        final path = match.group(1)!.replaceFirst('https://netos23.github.io/mellisuga/', '');
        expect(site.files, contains('${path}index.html'));
      }
    });

    test('the sitemap is stamped with the build date', () {
      expect(site.files['sitemap.xml'], contains('<lastmod>2026-07-27</lastmod>'));
    });

    test('robots.txt allows everything and points at the sitemap', () {
      expect(site.files['robots.txt'], contains('User-agent: *'));
      expect(site.files['robots.txt'], contains('Allow: /'));
      expect(
        site.files['robots.txt'],
        contains('Sitemap: https://netos23.github.io/mellisuga/sitemap.xml'),
      );
    });

    test('the 404 page is excluded from indexing', () {
      expect(site.files['404.html'], contains('name="robots" content="noindex, follow"'));
    });
  });

  group('content comes from the shared package', () {
    test('the home page shows every tool and its status', () {
      final home = site.files['index.html']!;
      for (final tool in ToolCatalog.tools) {
        expect(home, contains(_escaped(tool.title)), reason: tool.id);
        expect(home, contains('href="/mellisuga/${tool.path}"'), reason: tool.id);
      }
      expect(home, contains('badge--live'));
    });

    test('a tool page shows the same highlights the app does', () {
      final tool = ToolCatalog.flagship;
      final page = site.files['${tool.path}index.html']!;
      for (final highlight in tool.highlights) {
        expect(page, contains(_escaped(highlight)));
      }
      for (final paragraph in tool.overview) {
        expect(page, contains(_escaped(paragraph)));
      }
    });

    test('legal pages reproduce every section of the shared documents', () {
      for (final document in LegalContent.documents) {
        final page = site.files['${document.path}index.html']!;
        for (final section in document.sections) {
          expect(page, contains(_escaped(section.heading)), reason: document.id);
          for (final paragraph in section.paragraphs) {
            expect(page, contains(_escaped(paragraph)), reason: document.id);
          }
          for (final bullet in section.bullets) {
            expect(page, contains(_escaped(bullet)), reason: document.id);
          }
        }
      }
    });

    test('the licences page lists every bundled component', () {
      final page = site.files['licences/index.html']!;
      for (final component in ThirdPartyNotices.components) {
        expect(page, contains(_escaped(component.name)), reason: component.name);
      }
    });

    test('the sizes section lists the formats the app actually offers', () {
      final home = site.files['index.html']!;
      for (final format in PaperFormats.all) {
        expect(home, contains(_escaped(format.name)), reason: format.id);
      }
      for (final preset in PhotoSizePresets.all) {
        expect(home, contains(_escaped(preset.name)), reason: preset.id);
      }
    });

    test('the brand mark is drawn from the shared geometry', () {
      final home = site.files['index.html']!;
      for (final shape in BrandMark.paths) {
        expect(home, contains('d="${shape.data}"'), reason: shape.id);
      }
      expect(site.files['icon.svg'], contains(BrandMark.body.data));
    });

    test('mask ids are unique, so no two birds share an eye', () {
      for (final entry in site.files.entries) {
        if (!entry.key.endsWith('.html')) continue;
        final ids = RegExp(
          r'<mask id="([^"]+)"',
        ).allMatches(entry.value).map((match) => match.group(1)!).toList();
        expect(ids.toSet().length, ids.length, reason: '${entry.key}: $ids');
      }
    });
  });

  group('escaping', () {
    test('turns the dangerous characters into entities', () {
      expect(escapeHtml('<script>&"\'</script>'), '&lt;script&gt;&amp;&quot;&#39;&lt;/script&gt;');
    });

    test('leaves ordinary prose alone, punctuation and all', () {
      expect(escapeHtml('10 × 15 cm — passport'), '10 × 15 cm — passport');
    });

    test('no raw script-closing tag can appear inside structured data', () {
      final block = jsonLdScript(<String, Object?>{'name': '</script><img src=x>'});
      expect(block, isNot(contains('</script><img')));
      expect(block, contains(r'<'));
    });
  });

  group('deployment shape', () {
    test('a root build produces root-relative links', () {
      final rootSite = buildSite(SiteConfig(siteUrl: 'https://example.com/'));
      expect(rootSite.files['index.html'], contains('href="/styles.css"'));
      expect(rootSite.files['index.html'], contains('href="/app/"'));
      expect(
        rootSite.files['index.html'],
        contains('<link rel="canonical" href="https://example.com/">'),
      );
    });

    test('a subpath build never emits a link that escapes the subpath', () {
      for (final entry in site.files.entries) {
        if (!entry.key.endsWith('.html')) continue;
        for (final link in linksIn(entry.value)) {
          if (!link.startsWith('/')) continue;
          expect(link, startsWith('/mellisuga/'), reason: '${entry.key}: $link');
        }
      }
    });

    test('the whole site stays small enough to load instantly', () {
      expect(site.byteCount, lessThan(700 * 1024));
    });
  });
}

String _escaped(String value) => escapeHtml(value);
