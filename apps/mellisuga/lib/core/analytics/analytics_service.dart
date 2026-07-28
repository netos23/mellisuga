import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'analytics_build_config.dart';
import 'analytics_events.dart';
import 'web/analytics_web_bridge.dart' as web_bridge;

/// Fans a small, fixed set of events (see [AnalyticsEvents], and
/// `ANALYTICS.md` for the version people outside this codebase can read) out
/// to whichever backends this build was configured with (see
/// [AnalyticsBuildConfig]) on whichever platforms actually support them.
///
/// Nothing in this class runs before [enable] is called, and [enable] is only
/// ever called after the consent dialog has been accepted — see
/// `analytics_consent.dart`, which owns that decision. This class only
/// decides *how* to report once consent already exists.
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  bool _enabled = false;
  bool _firebaseReady = false;

  bool get _isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  bool get _isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Firebase Analytics covers Android and web, matching where
  /// `firebase_analytics` actually ships a working implementation. iOS and
  /// macOS are supported by the package too, but this project does not build
  /// or release for either, so there is nothing to configure there yet.
  bool get _firebaseSupported => kIsWeb || _isAndroid;

  bool get _firebaseConfigured =>
      AnalyticsBuildConfig.firebaseApiKey.isNotEmpty &&
      AnalyticsBuildConfig.firebaseMeasurementId.isNotEmpty &&
      (kIsWeb
          ? AnalyticsBuildConfig.firebaseAppIdWeb.isNotEmpty
          : AnalyticsBuildConfig.firebaseAppIdAndroid.isNotEmpty);

  /// AppMetrica's own Flutter plugin only implements Android and iOS; the web
  /// build reports to AppMetrica through `web_bridge` instead (see
  /// `web/analytics_web_bridge_web.dart`).
  bool get _appMetricaNativeSupported => !kIsWeb && (_isAndroid || _isIOS);

  bool get _appMetricaNativeConfigured => AnalyticsBuildConfig.appMetricaApiKey.isNotEmpty;

  bool get _appMetricaWebConfigured =>
      kIsWeb && AnalyticsBuildConfig.appMetricaWebApiKey.isNotEmpty;

  /// Yandex Metrica is a web analytics product with no mobile SDK of its own
  /// — AppMetrica is Yandex's mobile product — so this only ever runs on web.
  bool get _yandexMetricaConfigured =>
      kIsWeb && AnalyticsBuildConfig.yandexMetricaCounterId.isNotEmpty;

  /// Whether at least one backend could run on this platform with this
  /// build's configuration. This is the switch that decides whether the
  /// consent dialog appears at all — there is nothing to ask permission for
  /// on a build with no vendor configured, which is every build without
  /// secrets supplied, including every contributor's local run.
  bool get hasAnyBackendConfigured =>
      (_firebaseSupported && _firebaseConfigured) ||
      (_appMetricaNativeSupported && _appMetricaNativeConfigured) ||
      _appMetricaWebConfigured ||
      _yandexMetricaConfigured;

  /// Starts every configured, supported backend. Safe to call more than
  /// once; only the first call does anything.
  Future<void> enable() async {
    if (_enabled) return;
    _enabled = true;

    if (_firebaseSupported && _firebaseConfigured) {
      await _enableFirebase();
    }
    if (_appMetricaNativeSupported && _appMetricaNativeConfigured) {
      _enableAppMetricaNative();
    }
    if (_appMetricaWebConfigured) {
      web_bridge.loadAppMetricaWeb(AnalyticsBuildConfig.appMetricaWebApiKey);
    }
    if (_yandexMetricaConfigured) {
      web_bridge.loadYandexMetricaWeb(AnalyticsBuildConfig.yandexMetricaCounterId);
    }

    logEvent(AnalyticsEvents.appOpen);
  }

  /// Stops Firebase from collecting further events after consent is
  /// withdrawn. The other backends were only ever loaded after consent was
  /// granted in the first place, so revoking simply stops this class from
  /// calling them again — there is no in-page way to unload an already
  /// loaded vendor script, which is why the consent dialog only appears once
  /// per decision rather than injecting and un-injecting scripts repeatedly.
  void disable() {
    _enabled = false;
    if (_firebaseReady) {
      FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
    }
  }

  Future<void> _enableFirebase() async {
    try {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: AnalyticsBuildConfig.firebaseApiKey,
          appId: kIsWeb
              ? AnalyticsBuildConfig.firebaseAppIdWeb
              : AnalyticsBuildConfig.firebaseAppIdAndroid,
          messagingSenderId: AnalyticsBuildConfig.firebaseMessagingSenderId,
          projectId: AnalyticsBuildConfig.firebaseProjectId,
          measurementId: kIsWeb ? AnalyticsBuildConfig.firebaseMeasurementId : null,
        ),
      );
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      _firebaseReady = true;
    } catch (error) {
      // A misconfigured key should not take the rest of the app down with it.
      debugPrint('Firebase Analytics did not start: $error');
    }
  }

  void _enableAppMetricaNative() {
    try {
      AppMetrica.activate(AppMetricaConfig(AnalyticsBuildConfig.appMetricaApiKey));
    } catch (error) {
      debugPrint('AppMetrica did not start: $error');
    }
  }

  /// Reports one of [AnalyticsEvents] to every backend that is currently
  /// running. [parameters] values must be `String`, `num` or `bool` — the
  /// same restriction `firebase_analytics` itself imposes.
  void logEvent(String name, {Map<String, Object>? parameters}) {
    if (!_enabled) return;

    if (_firebaseReady) {
      FirebaseAnalytics.instance.logEvent(name: name, parameters: parameters);
    }
    if (_appMetricaNativeSupported && _appMetricaNativeConfigured) {
      // The native plugin's public API reports an event name with no
      // attached parameters; see ANALYTICS.md for what that means for the
      // events below on mobile specifically.
      AppMetrica.reportEvent(name);
    }
    if (_appMetricaWebConfigured) {
      web_bridge.logAppMetricaWebEvent(name, parameters);
    }
    if (_yandexMetricaConfigured) {
      web_bridge.logYandexMetricaGoal(name);
    }
  }

  void logToolOpened(String toolId) =>
      logEvent(AnalyticsEvents.toolOpened, parameters: {'tool_id': toolId});

  void logExportCompleted({required String toolId, required String format, int? pageCount}) =>
      logEvent(
        AnalyticsEvents.exportCompleted,
        parameters: {'tool_id': toolId, 'format': format, 'page_count': ?pageCount},
      );

  void logThemeChanged(String mode) =>
      logEvent(AnalyticsEvents.themeChanged, parameters: {'mode': mode});

  void logLocaleChanged(String locale) =>
      logEvent(AnalyticsEvents.localeChanged, parameters: {'locale': locale});

  void logConsentChanged(bool granted) =>
      logEvent(AnalyticsEvents.consentChanged, parameters: {'granted': granted.toString()});
}
