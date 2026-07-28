import 'package:mellisuga_content/mellisuga_content.dart';

import 'analytics_config.dart';
import 'i18n/site_strings.dart';

/// Where the generated site will live, and therefore how its links are written.
///
/// GitHub Pages serves project sites from a subpath (`/mellisuga/`), so nothing
/// in the site may assume it sits at the root of a domain. Every internal link
/// goes through [url] and every canonical through [canonical]; there are no
/// hand-written absolute paths anywhere in the templates.
class SiteConfig {
  SiteConfig({
    String baseHref = '/',
    String siteUrl = Brand.websiteUrl,
    String appPath = '${Brand.appPathSegment}/',
    DateTime? buildDate,
    this.locale = AppLocale.en,
    this.analytics = const AnalyticsConfig.disabled(),
  }) : baseHref = _withSlashes(baseHref),
       siteUrl = _withTrailingSlash(siteUrl),
       appPath = _withTrailingSlash(appPath),
       buildDate = buildDate ?? DateTime.now().toUtc();

  /// Root of the deployment, as a path: `/` locally, `/mellisuga/` on Pages.
  final String baseHref;

  /// Absolute URL of that same root, used for canonicals, Open Graph and the
  /// sitemap — the three places a relative URL is not allowed.
  final String siteUrl;

  /// Where the Flutter app is published, relative to the site root.
  ///
  /// The landing site links to the app; it never contains it. The two are
  /// separate builds that happen to be published to one place.
  final String appPath;

  /// Stamped into the sitemap. Injectable so a test can assert on a fixed date.
  final DateTime buildDate;

  /// The language this build's pages are rendered in.
  final AppLocale locale;

  /// Which analytics vendors (if any) this build reports to. Empty by
  /// default, which is what every existing test builds — a build with no
  /// vendor configured emits no consent banner and no analytics script at
  /// all, identical to the site before this existed.
  final AnalyticsConfig analytics;

  /// Every page's translated chrome text, for [locale].
  SiteStrings get strings => SiteStrings.forLocale(locale);

  /// English stays at the site root, for backward-compatible URLs and because
  /// it is the language search engines have already indexed. Every other
  /// locale gets its own path prefix.
  String get localePrefix => locale.isFallback ? '' : '${locale.code}/';

  /// A copy of this config rendering a different [locale]'s pages.
  SiteConfig withLocale(AppLocale locale) => SiteConfig(
    baseHref: baseHref,
    siteUrl: siteUrl,
    appPath: appPath,
    buildDate: buildDate,
    locale: locale,
    analytics: analytics,
  );

  /// An internal link to a page at [relative], which must not start with a
  /// slash. Carries the current locale's path prefix.
  String url(String relative) => '$baseHref$localePrefix$relative';

  /// The absolute URL of a page at [relative], for canonicals and structured
  /// data. Carries the current locale's path prefix.
  String canonical(String relative) => '$siteUrl$localePrefix$relative';

  /// A link to a same-origin file shared by every locale — the stylesheet,
  /// the script and the icon — which live at the site root, never under a
  /// locale prefix.
  String asset(String relative) => '$baseHref$relative';

  /// The absolute URL of a shared asset.
  String assetCanonical(String relative) => '$siteUrl$relative';

  /// Link to the web build of the app. The app is a single build with its own
  /// in-app language switcher, so it is never locale-prefixed.
  String get appUrl => asset(appPath);

  /// Absolute URL of the app, for structured data.
  String get appCanonical => assetCanonical(appPath);

  static String _withTrailingSlash(String value) => value.endsWith('/') ? value : '$value/';

  static String _withSlashes(String value) {
    final withLeading = value.startsWith('/') ? value : '/$value';
    return _withTrailingSlash(withLeading);
  }
}
