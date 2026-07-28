import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mellisuga_content/mellisuga_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/analytics/analytics_consent.dart';
import 'core/analytics/analytics_service.dart';
import 'core/app_info.dart';
import 'core/theme/app_theme.dart';
import 'features/photo_compose/state/compose_scope.dart';
import 'features/shell/app_shell.dart';
import 'l10n/generated/app_localizations.dart';

/// Root widget: theme, locale, analytics consent, persisted preferences and
/// the app-wide compose state.
class MellisugaApp extends StatefulWidget {
  const MellisugaApp({super.key});

  @override
  State<MellisugaApp> createState() => _MellisugaAppState();
}

class _MellisugaAppState extends State<MellisugaApp> {
  static const String _themeModeKey = 'theme_mode';
  static const String _localeKey = 'locale_code';

  ThemeMode _themeMode = ThemeMode.system;

  /// `null` means "follow the system locale", same convention as `ThemeMode`.
  Locale? _locale;

  SharedPreferences? _preferences;

  @override
  void initState() {
    super.initState();
    _restorePreferences();
    // Consent is asked for after the first frame, so the dialog has a
    // BuildContext with a Navigator and a theme already attached.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => AnalyticsConsent.instance.maybeAsk(context),
    );
  }

  Future<void> _restorePreferences() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!mounted) return;
      final storedTheme = preferences.getString(_themeModeKey);
      final storedLocale = preferences.getString(_localeKey);
      setState(() {
        _preferences = preferences;
        _themeMode =
            ThemeMode.values.where((mode) => mode.name == storedTheme).firstOrNull ??
            ThemeMode.system;
        _locale = storedLocale == null ? null : Locale(storedLocale);
      });
    } catch (_) {
      // Preferences are a convenience: a browser with storage disabled should
      // still get a working app, just without remembering the choice.
    }
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
    _preferences?.setString(_themeModeKey, mode.name);
    AnalyticsService.instance.logThemeChanged(mode.name);
  }

  void _setLocale(AppLocale? locale) {
    setState(() => _locale = locale == null ? null : Locale(locale.code));
    if (locale == null) {
      _preferences?.remove(_localeKey);
    } else {
      _preferences?.setString(_localeKey, locale.code);
    }
    AnalyticsService.instance.logLocaleChanged(locale?.code ?? 'system');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: ComposeScopeHost(
        child: AppShell(
          themeMode: _themeMode,
          onThemeModeChanged: _setThemeMode,
          locale: _locale,
          onLocaleChanged: _setLocale,
        ),
      ),
    );
  }
}
