import 'package:flutter/material.dart';
import 'package:mellisuga_content/mellisuga_content.dart';

import '../../l10n/generated/app_localizations.dart';

/// Opens a dialog listing every supported language plus "match system
/// language", and calls [onSelected] with the choice — `null` for "match
/// system".
Future<void> showLanguagePicker(
  BuildContext context, {
  required Locale? currentLocale,
  required ValueChanged<AppLocale?> onSelected,
}) {
  final l10n = AppLocalizations.of(context);
  final currentCode = currentLocale?.languageCode;

  Widget item({required String? code, required String label, required AppLocale? locale}) {
    return ListTile(
      title: Text(label),
      trailing: code == currentCode ? const Icon(Icons.check_rounded) : null,
      onTap: () {
        onSelected(locale);
        Navigator.of(context).pop();
      },
    );
  }

  return showDialog<void>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(l10n.chooseLanguage),
      children: [
        item(code: null, label: l10n.useSystemLanguage, locale: null),
        for (final locale in AppLocale.values)
          item(code: locale.code, label: locale.nativeName, locale: locale),
      ],
    ),
  );
}
