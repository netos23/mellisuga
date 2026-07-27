/// Static facts about the application, used by legal pages, PDF metadata and
/// the about dialog.
///
/// The runtime version is filled in from the package metadata at startup; the
/// constant here is the fallback used before that resolves (and in tests).
abstract final class AppInfo {
  static const String name = 'Mellisuga';

  static const String tagline = 'Photo and PDF tools that run in your browser.';

  static const String description =
      'Mellisuga is a collection of photo and document utilities that do all '
      'their work on your own device. Files you open are never uploaded to a '
      'server — there is no server.';

  static const String repositoryUrl = 'https://github.com/netos23/mellisuga';

  static const String issuesUrl = 'https://github.com/netos23/mellisuga/issues';

  static const String licenseName = 'MIT License';

  static const String copyrightHolder = 'Nikita Morozov';

  static const int copyrightYear = 2026;

  static String get copyright => '© $copyrightYear $copyrightHolder';

  /// Overwritten at startup with the real value from `pubspec.yaml`.
  static String version = '1.0.0';

  /// Overwritten at startup with the platform build number.
  static String buildNumber = '1';

  static String get versionLabel => 'v$version (build $buildNumber)';
}
