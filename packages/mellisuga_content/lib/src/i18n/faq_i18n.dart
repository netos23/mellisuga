import 'package:meta/meta.dart';

import '../faq.dart';
import 'locale.dart';
import 'translations/ar.dart';
import 'translations/de.dart';
import 'translations/es.dart';
import 'translations/fr.dart';
import 'translations/ja.dart';
import 'translations/ru.dart';
import 'translations/zh.dart';

/// A translated question and answer. Only [Faqs.general] is translated in
/// this pass — a tool's own [FaqEntry] list stays in English, alongside its
/// untranslated overview paragraphs.
@immutable
class FaqTranslation {
  const FaqTranslation({required this.question, required this.answer});

  final String question;
  final String answer;
}

/// Translations of [Faqs.general], keyed by locale and then by the original
/// English question — which [content_test.dart] already asserts are unique.
abstract final class FaqsTranslations {
  static const Map<AppLocale, Map<String, FaqTranslation>> _byLocale =
      <AppLocale, Map<String, FaqTranslation>>{
        AppLocale.fr: faqsFr,
        AppLocale.de: faqsDe,
        AppLocale.es: faqsEs,
        AppLocale.ru: faqsRu,
        AppLocale.ar: faqsAr,
        AppLocale.ja: faqsJa,
        AppLocale.zh: faqsZh,
      };

  static Map<String, FaqTranslation>? forLocale(AppLocale locale) => _byLocale[locale];
}

extension FaqEntryLocalization on FaqEntry {
  String questionIn(AppLocale locale) =>
      FaqsTranslations.forLocale(locale)?[question]?.question ?? question;

  String answerIn(AppLocale locale) =>
      FaqsTranslations.forLocale(locale)?[question]?.answer ?? answer;
}
