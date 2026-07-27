import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app_info.dart';
import 'core/theme/app_theme.dart';
import 'features/photo_compose/state/compose_scope.dart';
import 'features/shell/app_shell.dart';

/// Root widget: theme, persisted preferences and the app-wide compose state.
class MellisugaApp extends StatefulWidget {
  const MellisugaApp({super.key});

  @override
  State<MellisugaApp> createState() => _MellisugaAppState();
}

class _MellisugaAppState extends State<MellisugaApp> {
  static const String _themeModeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  SharedPreferences? _preferences;

  @override
  void initState() {
    super.initState();
    _restorePreferences();
  }

  Future<void> _restorePreferences() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!mounted) return;
      final stored = preferences.getString(_themeModeKey);
      setState(() {
        _preferences = preferences;
        _themeMode =
            ThemeMode.values.where((mode) => mode.name == stored).firstOrNull ?? ThemeMode.system;
      });
    } catch (_) {
      // Preferences are a convenience: a browser with storage disabled should
      // still get a working app, just without remembering the theme.
    }
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
    _preferences?.setString(_themeModeKey, mode.name);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      home: ComposeScopeHost(
        child: AppShell(themeMode: _themeMode, onThemeModeChanged: _setThemeMode),
      ),
    );
  }
}
