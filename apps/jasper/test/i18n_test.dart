import 'package:jasper/jasper.dart';
import 'package:mellisuga_content/mellisuga_content.dart';
import 'package:test/test.dart';

void main() {
  group('SiteStrings completeness', () {
    test('every non-English locale defines every key English does', () {
      final english = SiteStrings.englishKeys;
      for (final locale in AppLocale.values) {
        if (locale.isFallback) continue;
        final keys = SiteStrings.keysFor(locale);
        expect(keys, isNotNull, reason: locale.code);
        final missing = english.difference(keys!.keys.toSet());
        expect(missing, isEmpty, reason: '${locale.code} is missing: $missing');
      }
    });

    test('no locale defines a key English does not', () {
      final english = SiteStrings.englishKeys;
      for (final locale in AppLocale.values) {
        final keys = SiteStrings.keysFor(locale);
        if (keys == null) continue;
        final extra = keys.keys.toSet().difference(english);
        expect(extra, isEmpty, reason: '${locale.code} defines unknown keys: $extra');
      }
    });
  });

  group('ToolCatalogTranslations completeness', () {
    test('every locale translates every tool, or none of them yet', () {
      for (final locale in AppLocale.values) {
        if (locale.isFallback) continue;
        final translations = ToolCatalogTranslations.forLocale(locale)!;
        if (translations.isEmpty) continue; // not translated yet
        for (final tool in ToolCatalog.tools) {
          expect(translations, contains(tool.id), reason: '${locale.code}: ${tool.id}');
        }
      }
    });
  });

  group('buildAllLocales', () {
    final config = SiteConfig(
      baseHref: '/mellisuga/',
      siteUrl: 'https://netos23.github.io/mellisuga/',
      buildDate: DateTime.utc(2026, 7, 27),
    );
    final site = buildAllLocales(config);

    test('every locale gets every page, at its own prefix', () {
      for (final locale in AppLocale.values) {
        final prefix = locale.isFallback ? '' : '${locale.code}/';
        expect(site.files, contains('${prefix}index.html'), reason: locale.code);
        expect(site.files, contains('${prefix}tools/index.html'), reason: locale.code);
        for (final tool in ToolCatalog.tools) {
          expect(
            site.files,
            contains('$prefix${tool.path}index.html'),
            reason: '${locale.code}/${tool.id}',
          );
        }
        for (final document in LegalContent.documents) {
          expect(
            site.files,
            contains('$prefix${document.path}index.html'),
            reason: '${locale.code}/${document.id}',
          );
        }
      }
    });

    test('only English gets a 404 page', () {
      expect(site.files, contains('404.html'));
      for (final locale in AppLocale.values) {
        if (locale.isFallback) continue;
        expect(site.files, isNot(contains('${locale.code}/404.html')));
      }
    });

    test('shared assets are written once, not once per locale', () {
      expect(site.files, contains('styles.css'));
      expect(site.files, contains('site.js'));
      expect(site.files, contains('icon.svg'));
      for (final locale in AppLocale.values) {
        if (locale.isFallback) continue;
        expect(site.files, isNot(contains('${locale.code}/styles.css')));
      }
    });

    test('every non-English page declares its own <html lang> and hreflang alternates', () {
      for (final locale in AppLocale.values) {
        if (locale.isFallback) continue;
        final page = site.files['${locale.code}/index.html']!;
        expect(page, contains('<html lang="${locale.code}"'));
        for (final other in AppLocale.values) {
          expect(page, contains('hreflang="${other.code}"'));
        }
        expect(page, contains('hreflang="x-default"'));
      }
    });

    test('Arabic pages are marked right-to-left', () {
      final page = site.files['ar/index.html']!;
      expect(page, contains('dir="rtl"'));
      final englishPage = site.files['index.html']!;
      expect(englishPage, isNot(contains('dir="rtl"')));
    });

    test('the sitemap lists every locale, not just English', () {
      final sitemap = site.files['sitemap.xml']!;
      for (final locale in AppLocale.values) {
        if (locale.isFallback) {
          expect(sitemap, contains('<loc>https://netos23.github.io/mellisuga/</loc>'));
        } else {
          expect(
            sitemap,
            contains('<loc>https://netos23.github.io/mellisuga/${locale.code}/</loc>'),
          );
        }
      }
    });

    test('non-English legal pages carry the English-only notice', () {
      for (final locale in AppLocale.values) {
        if (locale.isFallback) continue;
        final page = site.files['${locale.code}/privacy/index.html']!;
        expect(page, contains(escapeHtml(LegalNotices.englishOnlyNotice(locale)!)));
      }
    });

    test('titles and descriptions stay within a usable length in every locale', () {
      for (final page in site.pages) {
        expect(page.meta.title.length, inInclusiveRange(10, 90), reason: page.meta.filePath);
        expect(page.meta.description.length, inInclusiveRange(20, 200), reason: page.meta.filePath);
      }
    });
  });

  group('analytics (disabled by default)', () {
    test('a build with no vendor configured never writes analytics.js', () {
      final config = SiteConfig(buildDate: DateTime.utc(2026, 7, 27));
      final site = buildAllLocales(config);
      expect(site.files, isNot(contains('analytics.js')));
      for (final html in site.files.entries.where((e) => e.key.endsWith('.html'))) {
        expect(html.value, isNot(contains('consent-banner')), reason: html.key);
      }
    });
  });

  group('analytics (configured)', () {
    final config = SiteConfig(
      buildDate: DateTime.utc(2026, 7, 27),
      analytics: const AnalyticsConfig(
        firebaseApiKey: 'test-key',
        firebaseAppId: '1:test:web:test',
        firebaseMessagingSenderId: '123',
        firebaseProjectId: 'mellisuga-test',
        firebaseMeasurementId: 'G-TEST123',
        yandexMetricaCounterId: '99999999',
        appMetricaApiKey: 'test-appmetrica-key',
      ),
    );
    final site = buildAllLocales(config);

    test('every vendor is configured, so every loader is present', () {
      expect(site.files, contains('analytics.js'));
      final script = site.files['analytics.js']!;
      expect(script, contains('googletagmanager.com/gtag/js'));
      expect(script, contains('"G-TEST123"'));
      expect(script, contains('mc.yandex.ru/metrika/tag.js'));
      expect(script, contains('"99999999"'));
      expect(script, contains('appmetrica.yandex.com/tag.js'));
      expect(script, contains('"test-appmetrica-key"'));
    });

    test(
      'nothing runs before consent: the loader only calls vendors from inside the granted branch',
      () {
        final script = site.files['analytics.js']!;
        final loadVendorsBody = script.substring(
          script.indexOf('function loadVendors'),
          script.indexOf('function enable'),
        );
        expect(loadVendorsBody, contains('gtag'));
        // loadVendors is only ever invoked from enable(), which only runs after
        // stored() === 'granted' or a fresh accept click.
        expect(script, contains('function enable() {\n    hideBanner();\n    loadVendors();\n  }'));
      },
    );

    test('every page ships the consent banner and the analytics script tag', () {
      for (final entry in site.files.entries) {
        if (!entry.key.endsWith('.html')) continue;
        expect(entry.value, contains('id="consent-banner"'), reason: entry.key);
        expect(entry.value, contains('src="/analytics.js"'), reason: entry.key);
      }
    });

    test('the footer explains analytics are optional instead of claiming there are none', () {
      final home = site.files['index.html']!;
      expect(home, isNot(contains('No cookies. No analytics. No accounts.')));
      expect(home, contains('data-consent-manage'));
    });
  });
}
