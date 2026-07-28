import 'locale.dart';

/// The legal documents themselves ([LegalContent]) are not translated: a
/// mistranslated privacy policy or terms of use is worse than an English one,
/// so this first localisation pass keeps their body text canonical in one
/// language. Non-English readers instead see this one translated sentence
/// above the document, explaining why.
abstract final class LegalNotices {
  static const Map<AppLocale, String> _englishOnlyNotice = <AppLocale, String>{
    AppLocale.fr:
        'Ce document légal n\'est disponible qu\'en anglais pour l\'instant, afin '
        'd\'éviter toute imprécision de traduction sur un texte à portée juridique.',
    AppLocale.de:
        'Dieses rechtliche Dokument ist derzeit nur auf Englisch verfügbar, damit '
        'sich bei einem rechtlich bedeutsamen Text keine Übersetzungsfehler '
        'einschleichen.',
    AppLocale.es:
        'Este documento legal solo está disponible en inglés por ahora, para '
        'evitar imprecisiones de traducción en un texto con implicaciones '
        'legales.',
    AppLocale.ru:
        'Этот юридический документ пока доступен только на английском языке — '
        'чтобы избежать неточностей перевода в тексте, имеющем юридическое '
        'значение.',
    AppLocale.ar:
        'هذه الوثيقة القانونية متاحة حاليًا باللغة الإنجليزية فقط، تجنبًا لأي عدم '
        'دقة في الترجمة قد تؤثر على نص له طابع قانوني.',
    AppLocale.ja: '法的な文書は翻訳の不正確さを避けるため、現時点では英語のみでの提供となります。',
    AppLocale.zh: '为避免翻译不准确影响具有法律效力的文本，本法律文件目前仅提供英文版本。',
  };

  /// `null` for English, where the document already is the canonical text.
  static String? englishOnlyNotice(AppLocale locale) => _englishOnlyNotice[locale];
}
