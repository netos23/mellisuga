/// A language the app and the landing site can be shown in.
///
/// This is the one list every surface agrees on: the app's `l10n.yaml`
/// generates a delegate per [code], Jasper prefixes a locale's pages with
/// [code] (English stays at the site root), and both read [rtl] to flip
/// text direction.
enum AppLocale {
  en('en', 'English', rtl: false),
  fr('fr', 'Français', rtl: false),
  de('de', 'Deutsch', rtl: false),
  es('es', 'Español', rtl: false),
  ru('ru', 'Русский', rtl: false),
  ar('ar', 'العربية', rtl: true),
  ja('ja', '日本語', rtl: false),
  zh('zh', '中文', rtl: false);

  const AppLocale(this.code, this.nativeName, {required this.rtl});

  /// The language tag used as the ARB locale suffix, the site's URL prefix and
  /// the `<html lang>` attribute.
  final String code;

  /// How this language names itself, for use in a language picker.
  final String nativeName;

  /// Whether this language is read right-to-left.
  final bool rtl;

  /// The language every translation map falls back to when an entry for
  /// another locale is missing.
  static const AppLocale fallback = AppLocale.en;

  bool get isFallback => this == fallback;

  static AppLocale? byCode(String code) {
    for (final locale in values) {
      if (locale.code == code) return locale;
    }
    return null;
  }
}
