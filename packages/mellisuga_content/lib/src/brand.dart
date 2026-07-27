/// Static facts about the product.
///
/// The app shows these on its home and about screens; the landing site puts
/// them in page titles, structured data and the footer. Changing a URL here
/// changes it in both places.
abstract final class Brand {
  static const String name = 'Mellisuga';

  static const String tagline = 'Photo and PDF tools that run in your browser.';

  /// One sentence, used as the default meta description and app-store style
  /// blurb. Kept under 160 characters so search engines show all of it.
  static const String shortDescription =
      'Pack photos of any size onto A4, Letter or photo paper with no wasted '
      'space. Everything runs on your device — nothing is ever uploaded.';

  static const String description =
      'Mellisuga is a collection of photo and document utilities that do all '
      'their work on your own device. Files you open are never uploaded to a '
      'server — there is no server.';

  /// Where the name comes from. Used in the about screen and the landing's
  /// closing section.
  static const String nameOrigin =
      'Named after Mellisuga helenae, the bee hummingbird — the smallest bird '
      'there is, and a fitting mascot for tools that fit a lot into very little '
      'space.';

  static const String repositoryUrl = 'https://github.com/netos23/mellisuga';

  static const String issuesUrl = '$repositoryUrl/issues';

  static const String licenseUrl = '$repositoryUrl/blob/main/LICENSE';

  static const String authorUrl = 'https://github.com/netos23';

  /// Canonical home of the landing site.
  ///
  /// The site is generated with whatever base URL the build is given, but this
  /// is the address the app links to and the one that appears in structured
  /// data by default.
  static const String websiteUrl = 'https://netos23.github.io/mellisuga/';

  /// Where the web build of the app lives, relative to [websiteUrl].
  ///
  /// The landing site occupies the root of the deployment; the Flutter app is
  /// published underneath it, so a single GitHub Pages site serves both.
  static const String appPathSegment = 'app';

  static const String appUrl = '$websiteUrl$appPathSegment/';

  static const String licenseName = 'MIT License';

  static const String copyrightHolder = 'Nikita Morozov';

  static const int copyrightYear = 2026;

  static const String copyright = '© $copyrightYear $copyrightHolder';

  /// Platforms the project ships to, in the order they are listed publicly.
  static const List<String> platforms = <String>['Web', 'Android', 'Windows', 'macOS', 'Linux'];
}

/// The palette shared by the app's theme, the site's stylesheet and the
/// generated icons.
///
/// Mellisuga is named after the bee hummingbird, so the colours borrow its
/// iridescent green-teal with a magenta throat accent.
abstract final class BrandColors {
  /// Seed colour for the app's Material scheme and the site's primary.
  static const String seedHex = '#0E9F8E';

  static const String accentHex = '#E0457B';

  /// Page background of the light theme, matching the app's surface.
  static const String surfaceLightHex = '#FAFDFC';

  static const String surfaceDarkHex = '#101413';

  /// ARGB values for Flutter, kept beside the hex strings so the two can never
  /// drift apart.
  static const int seedValue = 0xFF0E9F8E;

  static const int accentValue = 0xFFE0457B;

  static const int surfaceLightValue = 0xFFFAFDFC;

  static const int surfaceDarkValue = 0xFF101413;

  /// Colour of the "paper" area behind a sheet preview, light theme.
  static const int canvasLightValue = 0xFFE7EAEC;

  /// Colour of the "paper" area behind a sheet preview, dark theme.
  static const int canvasDarkValue = 0xFF1A1C1E;
}
