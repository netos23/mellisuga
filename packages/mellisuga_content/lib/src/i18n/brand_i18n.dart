import 'package:meta/meta.dart';

import '../brand.dart';
import 'locale.dart';
import 'translations/ar.dart';
import 'translations/de.dart';
import 'translations/es.dart';
import 'translations/fr.dart';
import 'translations/ja.dart';
import 'translations/ru.dart';
import 'translations/zh.dart';

/// Translated renderings of the handful of [Brand] strings that appear as
/// prose — the tagline, the two descriptions and the name's origin story.
/// Everything else on [Brand] (URLs, the licence name, platform names) is not
/// language-dependent.
@immutable
class BrandTranslation {
  const BrandTranslation({
    required this.tagline,
    required this.shortDescription,
    required this.description,
    required this.nameOrigin,
  });

  final String tagline;
  final String shortDescription;
  final String description;
  final String nameOrigin;
}

abstract final class BrandTranslations {
  static const Map<AppLocale, BrandTranslation> _byLocale = <AppLocale, BrandTranslation>{
    AppLocale.fr: brandFr,
    AppLocale.de: brandDe,
    AppLocale.es: brandEs,
    AppLocale.ru: brandRu,
    AppLocale.ar: brandAr,
    AppLocale.ja: brandJa,
    AppLocale.zh: brandZh,
  };

  static BrandTranslation? forLocale(AppLocale locale) => _byLocale[locale];
}

extension BrandLocalization on AppLocale {
  String brandTaglineIn() => BrandTranslations.forLocale(this)?.tagline ?? Brand.tagline;

  String brandShortDescriptionIn() =>
      BrandTranslations.forLocale(this)?.shortDescription ?? Brand.shortDescription;

  String brandDescriptionIn() =>
      BrandTranslations.forLocale(this)?.description ?? Brand.description;

  String brandNameOriginIn() => BrandTranslations.forLocale(this)?.nameOrigin ?? Brand.nameOrigin;
}
