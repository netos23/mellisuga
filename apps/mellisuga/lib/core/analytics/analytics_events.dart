/// Every event this app can report, in one place, so `ANALYTICS.md` can list
/// exactly what a "yes" on the consent dialog actually sends — nothing is
/// reported that is not named here.
///
/// None of these ever carry file contents, file names, or anything else about
/// the photos or documents a person is working with; the app has no code path
/// that could attach that data to an analytics call in the first place.
abstract final class AnalyticsEvents {
  /// Fired once, the first time the app finishes starting in a session.
  static const String appOpen = 'app_open';

  /// A tool screen was opened. Parameter: `tool_id`.
  static const String toolOpened = 'tool_opened';

  /// An export finished successfully. Parameters: `tool_id`, `format`,
  /// `page_count`.
  static const String exportCompleted = 'export_completed';

  /// The theme was changed. Parameter: `mode` (`light`, `dark`, `system`).
  static const String themeChanged = 'theme_changed';

  /// The display language was changed. Parameter: `locale` (a language code,
  /// or `system`).
  static const String localeChanged = 'locale_changed';

  /// The consent choice changed after the first prompt, from the About page.
  /// Parameter: `granted` (`true`/`false`).
  static const String consentChanged = 'consent_changed';
}
