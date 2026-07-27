import 'package:mellisuga_content/mellisuga_content.dart';

/// Static facts about the application, used by legal pages, PDF metadata and
/// the about dialog.
///
/// The facts themselves live in `package:mellisuga_content` so the landing site
/// quotes the same tagline and links to the same URLs; this class adds the two
/// things only a running app knows — its version and build number.
abstract final class AppInfo {
  static const String name = Brand.name;

  static const String tagline = Brand.tagline;

  static const String description = Brand.description;

  static const String repositoryUrl = Brand.repositoryUrl;

  static const String issuesUrl = Brand.issuesUrl;

  /// The landing site. Native builds link out to it; they never embed it.
  static const String websiteUrl = Brand.websiteUrl;

  static const String licenseName = Brand.licenseName;

  static const String copyrightHolder = Brand.copyrightHolder;

  static const int copyrightYear = Brand.copyrightYear;

  static const String copyright = Brand.copyright;

  /// Overwritten at startup with the real value from `pubspec.yaml`.
  static String version = '1.0.0';

  /// Overwritten at startup with the platform build number.
  static String buildNumber = '1';

  static String get versionLabel => 'v$version (build $buildNumber)';
}
