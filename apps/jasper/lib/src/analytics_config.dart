/// Which analytics vendors this build should report to, and their public IDs.
///
/// None of these values are secret in the sense of granting write access to
/// anything — a Firebase measurement ID, a Yandex Metrica counter ID and an
/// AppMetrica API key are all measurement identifiers that end up in public
/// HTML the moment analytics is switched on, the same way a Google Analytics
/// ID always has been. They still never appear as a literal in this
/// repository's source: they are read from environment variables at build
/// time (see `bin/build.dart`), which in CI are populated from GitHub
/// secrets (see `SECRETS_SETUP.md`) — so a fork of this project never
/// silently reports usage to the upstream project's accounts, and rotating a
/// key never means editing code.
///
/// A build where every field is empty — the default, and the one every
/// existing test in `site_test.dart` builds — emits no consent banner and no
/// analytics script whatsoever, byte-for-byte the same output as before this
/// class existed.
class AnalyticsConfig {
  const AnalyticsConfig({
    this.firebaseApiKey = '',
    this.firebaseAppId = '',
    this.firebaseMessagingSenderId = '',
    this.firebaseProjectId = '',
    this.firebaseMeasurementId = '',
    this.yandexMetricaCounterId = '',
    this.appMetricaApiKey = '',
  });

  const AnalyticsConfig.disabled() : this();

  /// Web API key for the Firebase project (public; scoped by Firebase's own
  /// security rules, not a secret credential).
  final String firebaseApiKey;
  final String firebaseAppId;
  final String firebaseMessagingSenderId;
  final String firebaseProjectId;

  /// The `G-XXXXXXX` id gtag.js reports events under.
  final String firebaseMeasurementId;

  final String yandexMetricaCounterId;
  final String appMetricaApiKey;

  bool get firebaseEnabled =>
      firebaseApiKey.isNotEmpty && firebaseAppId.isNotEmpty && firebaseMeasurementId.isNotEmpty;

  bool get yandexMetricaEnabled => yandexMetricaCounterId.isNotEmpty;

  bool get appMetricaEnabled => appMetricaApiKey.isNotEmpty;

  /// Whether any vendor is configured — the single switch that decides
  /// whether the consent banner and the analytics loader are built at all.
  bool get anyEnabled => firebaseEnabled || yandexMetricaEnabled || appMetricaEnabled;
}
