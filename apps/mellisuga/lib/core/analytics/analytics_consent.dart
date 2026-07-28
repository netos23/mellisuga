import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/generated/app_localizations.dart';
import 'analytics_service.dart';

/// Whether this device has agreed to analytics: asked once, and changeable
/// at any time from About → Privacy & analytics.
class AnalyticsConsent {
  AnalyticsConsent._();

  static final AnalyticsConsent instance = AnalyticsConsent._();

  static const String _prefsKey = 'analytics_consent';

  /// `null` until a choice is loaded or made. `About` reads this to show the
  /// current state and to know whether to offer a toggle at all.
  final ValueNotifier<bool?> granted = ValueNotifier<bool?>(null);

  SharedPreferences? _preferences;
  bool _asked = false;

  Future<void> _load() async {
    _preferences ??= await SharedPreferences.getInstance();
    final stored = _preferences!.getString(_prefsKey);
    granted.value = switch (stored) {
      'granted' => true,
      'denied' => false,
      _ => null,
    };
  }

  /// Shows the consent dialog once per app install, and only when at least
  /// one analytics backend is actually configured for this build — there is
  /// nothing to ask permission for otherwise, so a plain `flutter run` never
  /// sees this dialog.
  Future<void> maybeAsk(BuildContext context) async {
    if (_asked) return;
    if (!AnalyticsService.instance.hasAnyBackendConfigured) return;

    await _load();
    if (granted.value != null) {
      if (granted.value == true) unawaited(AnalyticsService.instance.enable());
      return;
    }

    _asked = true;
    if (!context.mounted) return;
    await showDialog<void>(context: context, barrierDismissible: false, builder: _buildDialog);
  }

  /// Records a new choice, and starts or stops reporting immediately.
  Future<void> setConsent(bool value) async {
    granted.value = value;
    _preferences ??= await SharedPreferences.getInstance();
    await _preferences!.setString(_prefsKey, value ? 'granted' : 'denied');
    if (value) {
      await AnalyticsService.instance.enable();
    } else {
      AnalyticsService.instance.disable();
    }
    AnalyticsService.instance.logConsentChanged(value);
  }

  /// Reopens the choice from the About page, whether or not it was asked
  /// before.
  Future<void> reopen(BuildContext context) =>
      showDialog<void>(context: context, builder: _buildDialog);

  static Widget _buildDialog(BuildContext context) => const _ConsentDialog();
}

class _ConsentDialog extends StatelessWidget {
  const _ConsentDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.consentTitle),
      content: Text(l10n.consentBody),
      actions: [
        TextButton(
          onPressed: () {
            AnalyticsConsent.instance.setConsent(false);
            Navigator.of(context).pop();
          },
          child: Text(l10n.consentDecline),
        ),
        FilledButton(
          onPressed: () {
            AnalyticsConsent.instance.setConsent(true);
            Navigator.of(context).pop();
          },
          child: Text(l10n.consentAccept),
        ),
      ],
    );
  }
}
