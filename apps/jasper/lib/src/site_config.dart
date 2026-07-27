import 'package:mellisuga_content/mellisuga_content.dart';

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

  /// An internal link to [relative], which must not start with a slash.
  String url(String relative) => '$baseHref$relative';

  /// The absolute URL of [relative], for canonicals and structured data.
  String canonical(String relative) => '$siteUrl$relative';

  /// Link to the web build of the app.
  String get appUrl => url(appPath);

  /// Absolute URL of the app, for structured data.
  String get appCanonical => canonical(appPath);

  static String _withTrailingSlash(String value) => value.endsWith('/') ? value : '$value/';

  static String _withSlashes(String value) {
    final withLeading = value.startsWith('/') ? value : '/$value';
    return _withTrailingSlash(withLeading);
  }
}
