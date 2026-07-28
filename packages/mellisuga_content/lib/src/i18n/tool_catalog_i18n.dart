import 'package:meta/meta.dart';

import '../tool_catalog.dart';
import 'locale.dart';
import 'translations/ar.dart';
import 'translations/de.dart';
import 'translations/es.dart';
import 'translations/fr.dart';
import 'translations/ja.dart';
import 'translations/ru.dart';
import 'translations/zh.dart';

/// A translated rendering of a [ToolInfo]'s short, high-visibility fields.
///
/// Long-form fields — [ToolInfo.overview] and [ToolInfo.faqs] — are not part
/// of this first localisation pass and stay in English on every locale. That
/// keeps the deep-dive prose for each tool from drifting out of sync with the
/// English original while it waits for a human-reviewed translation; the
/// title, summary and highlights are what actually appear in navigation,
/// cards and search results, so those are translated now.
@immutable
class ToolTranslation {
  const ToolTranslation({
    required this.title,
    required this.summary,
    this.highlights = const <String>[],
    this.searchSummary,
  });

  final String title;
  final String summary;

  /// Replaces [ToolInfo.highlights] when non-empty; falls back to the English
  /// list otherwise so a partial translation never shows an empty bullet list.
  final List<String> highlights;
  final String? searchSummary;
}

/// Every tool's translated title, summary and highlights, keyed by locale and
/// then by [ToolInfo.id]. English is not listed here — [ToolInfo]'s own fields
/// are the English text and the fallback for anything missing below.
abstract final class ToolCatalogTranslations {
  static const Map<AppLocale, Map<String, ToolTranslation>> _byLocale =
      <AppLocale, Map<String, ToolTranslation>>{
        AppLocale.fr: toolCatalogFr,
        AppLocale.de: toolCatalogDe,
        AppLocale.es: toolCatalogEs,
        AppLocale.ru: toolCatalogRu,
        AppLocale.ar: toolCatalogAr,
        AppLocale.ja: toolCatalogJa,
        AppLocale.zh: toolCatalogZh,
      };

  /// `null` for English, since [ToolInfo] itself is the English text.
  static Map<String, ToolTranslation>? forLocale(AppLocale locale) => _byLocale[locale];
}

/// Translated labels for [ToolCategory] and [ToolStatus], the two enums whose
/// English text appears next to every tool.
@immutable
class CategoryTranslation {
  const CategoryTranslation({required this.label, required this.blurb});

  final String label;
  final String blurb;
}

abstract final class ToolCategoryTranslations {
  static const Map<AppLocale, Map<ToolCategory, CategoryTranslation>> _byLocale =
      <AppLocale, Map<ToolCategory, CategoryTranslation>>{
        AppLocale.fr: toolCategoriesFr,
        AppLocale.de: toolCategoriesDe,
        AppLocale.es: toolCategoriesEs,
        AppLocale.ru: toolCategoriesRu,
        AppLocale.ar: toolCategoriesAr,
        AppLocale.ja: toolCategoriesJa,
        AppLocale.zh: toolCategoriesZh,
      };

  static Map<ToolCategory, CategoryTranslation>? forLocale(AppLocale locale) => _byLocale[locale];
}

abstract final class ToolStatusTranslations {
  static const Map<AppLocale, Map<ToolStatus, String>> _byLocale =
      <AppLocale, Map<ToolStatus, String>>{
        AppLocale.fr: toolStatusesFr,
        AppLocale.de: toolStatusesDe,
        AppLocale.es: toolStatusesEs,
        AppLocale.ru: toolStatusesRu,
        AppLocale.ar: toolStatusesAr,
        AppLocale.ja: toolStatusesJa,
        AppLocale.zh: toolStatusesZh,
      };

  static Map<ToolStatus, String>? forLocale(AppLocale locale) => _byLocale[locale];
}

/// Reads a tool's fields in [locale], falling back to the English text on
/// [ToolInfo] itself for anything not yet translated.
extension ToolInfoLocalization on ToolInfo {
  String titleIn(AppLocale locale) =>
      ToolCatalogTranslations.forLocale(locale)?[id]?.title ?? title;

  String summaryIn(AppLocale locale) =>
      ToolCatalogTranslations.forLocale(locale)?[id]?.summary ?? summary;

  List<String> highlightsIn(AppLocale locale) {
    final translated = ToolCatalogTranslations.forLocale(locale)?[id]?.highlights;
    return (translated != null && translated.isNotEmpty) ? translated : highlights;
  }

  String metaDescriptionIn(AppLocale locale) {
    final translation = ToolCatalogTranslations.forLocale(locale)?[id];
    return translation?.searchSummary ?? translation?.summary ?? metaDescription;
  }
}

extension ToolCategoryLocalization on ToolCategory {
  String labelIn(AppLocale locale) =>
      ToolCategoryTranslations.forLocale(locale)?[this]?.label ?? label;

  String blurbIn(AppLocale locale) =>
      ToolCategoryTranslations.forLocale(locale)?[this]?.blurb ?? blurb;
}

extension ToolStatusLocalization on ToolStatus {
  String labelIn(AppLocale locale) => ToolStatusTranslations.forLocale(locale)?[this] ?? label;
}
