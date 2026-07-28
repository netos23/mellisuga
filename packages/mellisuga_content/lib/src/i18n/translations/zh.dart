import '../../brand.dart';
import '../../tool_catalog.dart';
import '../brand_i18n.dart';
import '../faq_i18n.dart';
import '../tool_catalog_i18n.dart';

/// Chinese translations: tool catalogue, category/status labels,
/// general FAQ and brand copy.
const Map<String, ToolTranslation> toolCatalogZh = <String, ToolTranslation>{};

const Map<ToolCategory, CategoryTranslation> toolCategoriesZh =
    <ToolCategory, CategoryTranslation>{};

const Map<ToolStatus, String> toolStatusesZh = <ToolStatus, String>{};

const Map<String, FaqTranslation> faqsZh = <String, FaqTranslation>{};

const BrandTranslation brandZh = BrandTranslation(
  tagline: Brand.tagline,
  shortDescription: Brand.shortDescription,
  description: Brand.description,
  nameOrigin: Brand.nameOrigin,
);
