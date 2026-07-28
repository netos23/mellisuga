/// Every analytics vendor's build-time configuration.
///
/// Every value is injected with `--dart-define` at build time and is never a
/// literal in this repository — see `SECRETS_SETUP.md` for where each one
/// comes from and how CI supplies it from a GitHub secret. Every field
/// defaults to the empty string, so a build that sets none of them (every
/// local `flutter run`, every CI job) has [AnalyticsService.hasAnyBackendConfigured]
/// come back false and every backend stays off — no consent dialog, no
/// network request, nothing to disable.
abstract final class AnalyticsBuildConfig {
  static const String firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String firebaseAppIdAndroid = String.fromEnvironment('FIREBASE_APP_ID_ANDROID');
  static const String firebaseAppIdWeb = String.fromEnvironment('FIREBASE_APP_ID_WEB');
  static const String firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const String firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const String firebaseMeasurementId = String.fromEnvironment('FIREBASE_MEASUREMENT_ID');

  /// Mobile API key, used by the native `appmetrica_plugin` on Android.
  static const String appMetricaApiKey = String.fromEnvironment('APPMETRICA_API_KEY');

  /// Web API key, used by the hand-written AppMetrica Web SDK loader — the
  /// mobile plugin has no web implementation.
  static const String appMetricaWebApiKey = String.fromEnvironment('APPMETRICA_WEB_API_KEY');

  /// Yandex Metrica has no mobile SDK — AppMetrica is Yandex's mobile
  /// product — so this only ever applies to the web build, the same as it
  /// does for the landing site.
  static const String yandexMetricaCounterId = String.fromEnvironment('YANDEX_METRICA_COUNTER_ID');
}
