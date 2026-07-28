import 'package:flutter/widgets.dart';
import 'package:mellisuga_content/mellisuga_content.dart';

/// Maps Flutter's current [Locale] to the shared [AppLocale] both the app and
/// the landing site translate content for, so widgets can ask for translated
/// tool copy without doing the lookup themselves.
extension AppLocaleContext on BuildContext {
  AppLocale get appLocale =>
      AppLocale.byCode(Localizations.localeOf(this).languageCode) ?? AppLocale.en;
}
