import 'package:mellisuga_content/mellisuga_content.dart';

import '../copy.dart';
import 'dictionaries/ar.dart';
import 'dictionaries/de.dart';
import 'dictionaries/es.dart';
import 'dictionaries/fr.dart';
import 'dictionaries/ja.dart';
import 'dictionaries/ru.dart';
import 'dictionaries/zh.dart';

/// Every piece of the landing site's own chrome — navigation, footer, section
/// headings, banners — translated into each supported locale.
///
/// Tool descriptions, the general FAQ and the brand copy are not duplicated
/// here: they already have their own translation maps in
/// `package:mellisuga_content` ([ToolCatalogTranslations], [FaqsTranslations],
/// [BrandTranslations]) and are read directly from there. This class only
/// covers text that belongs to the site itself.
///
/// Values are looked up in a flat `key -> text` map so each locale can be
/// written as a plain literal map rather than an eight-way constructor call;
/// [SiteStringsCompletenessTest] in `test/` (see `i18n_test.dart`) asserts
/// every locale defines every key English does, so a missing translation
/// fails the build instead of silently falling back at runtime.
class SiteStrings {
  const SiteStrings._(this.locale, this._values);

  final AppLocale locale;
  final Map<String, String> _values;

  static SiteStrings forLocale(AppLocale locale) =>
      SiteStrings._(locale, _dictionaries[locale] ?? _en);

  String _t(String key) => _values[key] ?? _en[key] ?? key;

  // Header / navigation -----------------------------------------------------
  String get skipLink => _t('skipLink');
  String get navTools => _t('nav.tools');
  String get navHow => _t('nav.how');
  String get navSizes => _t('nav.sizes');
  String get navFaq => _t('nav.faq');
  String get navSource => _t('nav.source');
  String get navOpenApp => _t('nav.openApp');
  String get menuLabel => _t('menuLabel');
  String get themeToggleAria => _t('themeToggleAria');
  String get languagePickerLabel => _t('languagePickerLabel');

  // Footer --------------------------------------------------------------
  String get footerProduct => _t('footer.product');
  String get footerAllTools => _t('footer.allTools');
  String get footerDownloads => _t('footer.downloads');
  String get footerLegal => _t('footer.legal');
  String get footerProject => _t('footer.project');
  String get footerSourceCode => _t('footer.sourceCode');
  String get footerReportProblem => _t('footer.reportProblem');
  String get footerReleasedUnder => _t('footer.releasedUnder');
  String get footerNoAnalyticsLine => _t('footer.noAnalyticsLine');
  String get footerAnalyticsEnabledLine => _t('footer.analyticsEnabledLine');
  String get consentManageLink => _t('consent.manageLink');

  // Shared banner ---------------------------------------------------------
  String get bannerDefaultNote => _t('banner.defaultNote');

  // Home page ---------------------------------------------------------------
  String get heroHeading => _t('home.heroHeading');
  String get heroTail => _t('home.heroTail');
  String get heroLead => _t('home.heroLead');
  List<String> get heroChips => _values.containsKey('home.heroChips')
      ? _t('home.heroChips').split('|')
      : _en['home.heroChips']!.split('|');
  String get primaryAction => _t('home.primaryAction');
  String get secondaryAction => _t('home.secondaryAction');
  String get whyDifferentHeading => _t('home.whyDifferentHeading');
  String get howHeading => _t('home.howHeading');
  String get toolsHeading => _t('home.toolsHeading');
  String get toolsLead => _t('home.toolsLead');
  String get sizesHeading => _t('home.sizesHeading');
  String get sizesLead => _t('home.sizesLead');
  String get paperHeading => _t('home.paperHeading');
  String get printSizesHeading => _t('home.printSizesHeading');
  String get paperCaption => _t('home.paperCaption');
  String get printSizesCaption => _t('home.printSizesCaption');
  String sizesFoot(int paperFormats, int printPresets) => _t(
    'home.sizesFoot',
  ).replaceAll('{paper}', '$paperFormats').replaceAll('{prints}', '$printPresets');
  String get platformsHeading => _t('home.platformsHeading');
  String get platformsLead => _t('home.platformsLead');
  String get openInBrowser => _t('home.openInBrowser');
  String get download => _t('home.download');
  String get faqHeading => _t('home.faqHeading');
  String get closingHeading => _t('home.closingHeading');
  String get closingBody => _t('home.closingBody');
  String get openItNow => _t('home.openItNow');
  String get readDetails => _t('home.readDetails');
  String get readSource => _t('home.readSource');

  List<ValueProp> get valueProps => _nonEmpty(_valueProps[locale], Copy.valueProps);
  List<Step> get steps => _nonEmpty(_steps[locale], Copy.steps);
  List<Platform> get platforms => _nonEmpty(_platforms[locale], Copy.platforms);

  /// Falls back to [fallback] when [translated] is missing *or* still an
  /// empty placeholder — a locale whose dictionary file has not been filled
  /// in yet reads as untranslated either way.
  static List<T> _nonEmpty<T>(List<T>? translated, List<T> fallback) =>
      (translated == null || translated.isEmpty) ? fallback : translated;

  // Tool & tools-index pages ------------------------------------------------
  String get crumbHome => _t('crumb.home');
  String get whatItDoes => _t('tool.whatItDoes');
  String get seeHowItWorks => _t('tool.seeHowItWorks');
  String get notBuiltYetHeading => _t('tool.notBuiltYetHeading');
  String get notBuiltYetBodyBefore => _t('tool.notBuiltYetBodyBefore');
  String get notBuiltYetBodyLinkText => _t('tool.notBuiltYetBodyLinkText');
  String get notBuiltYetBodyAfter => _t('tool.notBuiltYetBodyAfter');
  String get moreInTheBox => _t('tool.moreInTheBox');
  String get toolReadyNote => _t('tool.readyNote');
  String get toolNotReadyNote => _t('tool.notReadyNote');

  String get toolsIndexMetaTitle => _t('toolsIndex.metaTitle');
  String toolsIndexMetaDescription(String brand) =>
      _t('toolsIndex.metaDescription').replaceAll('{brand}', brand);
  String toolsIndexSummary(int available, int roadmap) => _t(
    'toolsIndex.summary',
  ).replaceAll('{available}', '$available').replaceAll('{roadmap}', '$roadmap');

  // Legal pages ---------------------------------------------------------
  String legalLastUpdated(String date) => _t('legal.lastUpdated').replaceAll('{date}', date);
  String get legalOnThisPage => _t('legal.onThisPage');
  String get legalProseFootBefore => _t('legal.proseFootBefore');
  String get legalProseFootAppLink => _t('legal.proseFootAppLink');
  String get legalProseFootMiddle => _t('legal.proseFootMiddle');
  String get legalProseFootRepoLink => _t('legal.proseFootRepoLink');
  String get legalOtherDocuments => _t('legal.otherDocuments');
  String get legalBannerNote => _t('legal.bannerNote');

  // 404 page ------------------------------------------------------------
  String get notFoundHeading => _t('notFound.heading');
  String get notFoundLead => _t('notFound.lead');
  String get notFoundBackToStart => _t('notFound.backToStart');
  String get notFoundOrJumpTo => _t('notFound.orJumpTo');
  String get notFoundTheTools => _t('notFound.theTools');

  // Analytics consent banner ------------------------------------------------
  String get consentTitle => _t('consent.title');
  String get consentBody => _t('consent.body');
  String get consentAccept => _t('consent.accept');
  String get consentDecline => _t('consent.decline');

  /// Every key defined for English — the set every other locale is checked
  /// against.
  static Set<String> get englishKeys => _en.keys.toSet();

  /// Every key defined for [locale], or `null` for English (which has no
  /// override map — it is the dictionary itself).
  static Map<String, String>? keysFor(AppLocale locale) => _dictionaries[locale];
}

const Map<AppLocale, Map<String, String>> _dictionaries = <AppLocale, Map<String, String>>{
  AppLocale.fr: siteStringsFr,
  AppLocale.de: siteStringsDe,
  AppLocale.es: siteStringsEs,
  AppLocale.ru: siteStringsRu,
  AppLocale.ar: siteStringsAr,
  AppLocale.ja: siteStringsJa,
  AppLocale.zh: siteStringsZh,
};

final Map<String, String> _en = <String, String>{
  'skipLink': 'Skip to content',
  'nav.tools': 'Tools',
  'nav.how': 'How it works',
  'nav.sizes': 'Sizes',
  'nav.faq': 'FAQ',
  'nav.source': 'Source',
  'nav.openApp': 'Open the app',
  'menuLabel': 'Menu',
  'themeToggleAria': 'Switch between light and dark theme',
  'languagePickerLabel': 'Language',
  'footer.product': 'Product',
  'footer.allTools': 'All tools',
  'footer.downloads': 'Downloads',
  'footer.legal': 'Legal',
  'footer.project': 'Project',
  'footer.sourceCode': 'Source code',
  'footer.reportProblem': 'Report a problem',
  'footer.releasedUnder': 'Released under the',
  'footer.noAnalyticsLine': 'No cookies. No analytics. No accounts.',
  'footer.analyticsEnabledLine': 'No accounts. Analytics are optional — see the Privacy Policy.',
  'consent.manageLink': 'Manage analytics',
  'banner.defaultNote': 'Everything here runs in your browser. Nothing is uploaded.',
  'home.heroHeading': Copy.heroHeading,
  'home.heroTail': ' — without uploading them',
  'home.heroLead': Copy.heroLead,
  'home.heroChips': Copy.heroChips.join('|'),
  'home.primaryAction': Copy.primaryAction,
  'home.secondaryAction': Copy.secondaryAction,
  'home.whyDifferentHeading': 'Why it is different from the first search result',
  'home.howHeading': 'Three steps, no sign-up',
  'home.toolsHeading': Copy.toolsHeading,
  'home.toolsLead': Copy.toolsLead,
  'home.sizesHeading': Copy.sizesHeading,
  'home.sizesLead': Copy.sizesLead,
  'home.paperHeading': 'Paper',
  'home.printSizesHeading': 'Print sizes',
  'home.paperCaption': 'Built-in paper formats, grouped by standard',
  'home.printSizesCaption': 'Built-in print size presets, grouped by kind',
  'home.sizesFoot':
      '{paper} paper formats and {prints} print presets are built in, in portrait or '
      'landscape — and any size you type in millimetres, centimetres or inches works '
      'just as well.',
  'home.platformsHeading': Copy.platformsHeading,
  'home.platformsLead': Copy.platformsLead,
  'home.openInBrowser': 'Open in this browser',
  'home.download': 'Download',
  'home.faqHeading': Copy.faqHeading,
  'home.closingHeading': Copy.closingHeading,
  'home.closingBody': Copy.closingBody,
  'home.openItNow': 'Open it now',
  'home.readDetails': 'Read the details',
  'home.readSource': 'Read the source',
  'crumb.home': 'Home',
  'tool.whatItDoes': 'What it does',
  'tool.seeHowItWorks': 'See how it works',
  'tool.notBuiltYetHeading': 'Not built yet',
  'tool.notBuiltYetBodyBefore':
      'This tool is on the roadmap and has a page in the app describing what it will '
      'do. If you need it, say so on the',
  'tool.notBuiltYetBodyLinkText': 'issue tracker',
  'tool.notBuiltYetBodyAfter': '— that is how the order gets decided.',
  'tool.moreInTheBox': 'More in the same box',
  'tool.readyNote': 'This tool is ready. It opens in the tab you are already looking at.',
  'tool.notReadyNote': 'This one is not built yet — the app has the finished tools in it.',
  'toolsIndex.metaTitle': 'Photo and PDF tools that run on your device',
  'toolsIndex.metaDescription':
      'Every {brand} tool: compose photos for print, merge and split PDFs, convert '
      'images, watermark and more — all client-side, nothing uploaded.',
  'toolsIndex.summary':
      '{available} finished, {roadmap} on the way. Every one of them does its work on '
      'your own device.',
  'legal.lastUpdated': 'Last updated {date}',
  'legal.onThisPage': 'On this page',
  'legal.proseFootBefore': 'The same document is readable inside the app under',
  'legal.proseFootAppLink': 'About',
  'legal.proseFootMiddle': ', and its history is in the',
  'legal.proseFootRepoLink': 'public source repository',
  'legal.otherDocuments': 'Other documents:',
  'legal.bannerNote': 'Every word above describes how the app already behaves.',
  'notFound.heading': 'Nothing here',
  'notFound.lead':
      'The page you asked for does not exist — but nothing was uploaded on the way, '
      'so no harm done.',
  'notFound.backToStart': 'Back to the start',
  'notFound.orJumpTo': 'Or jump to',
  'notFound.theTools': 'the tools',
  'consent.title': 'Can we use anonymous analytics?',
  'consent.body':
      'If you say yes, this site sends anonymous usage events (page views, button '
      'clicks) to the analytics services listed in the Privacy Policy. Nothing about '
      'files opened in the app is ever collected — this site does not even have a '
      'file tool. You can change your mind at any time.',
  'consent.accept': 'Allow analytics',
  'consent.decline': 'No thanks',
};

final Map<AppLocale, List<ValueProp>> _valueProps = <AppLocale, List<ValueProp>>{
  AppLocale.en: Copy.valueProps,
  AppLocale.fr: siteValuePropsFr,
  AppLocale.de: siteValuePropsDe,
  AppLocale.es: siteValuePropsEs,
  AppLocale.ru: siteValuePropsRu,
  AppLocale.ar: siteValuePropsAr,
  AppLocale.ja: siteValuePropsJa,
  AppLocale.zh: siteValuePropsZh,
};

final Map<AppLocale, List<Step>> _steps = <AppLocale, List<Step>>{
  AppLocale.en: Copy.steps,
  AppLocale.fr: siteStepsFr,
  AppLocale.de: siteStepsDe,
  AppLocale.es: siteStepsEs,
  AppLocale.ru: siteStepsRu,
  AppLocale.ar: siteStepsAr,
  AppLocale.ja: siteStepsJa,
  AppLocale.zh: siteStepsZh,
};

final Map<AppLocale, List<Platform>> _platforms = <AppLocale, List<Platform>>{
  AppLocale.en: Copy.platforms,
  AppLocale.fr: sitePlatformsFr,
  AppLocale.de: sitePlatformsDe,
  AppLocale.es: sitePlatformsEs,
  AppLocale.ru: sitePlatformsRu,
  AppLocale.ar: sitePlatformsAr,
  AppLocale.ja: sitePlatformsJa,
  AppLocale.zh: sitePlatformsZh,
};
