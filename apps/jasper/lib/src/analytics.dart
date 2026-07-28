import 'dart:convert';

import 'analytics_config.dart';
import 'html.dart';
import 'site_config.dart';

/// The consent banner shown until a visitor accepts or declines. Only ever
/// rendered when [SiteConfig.analytics] configures at least one vendor —
/// see [renderPage] in `layout.dart`.
String consentBannerHtml(SiteConfig config) {
  final strings = config.strings;
  return '''
<div class="consent-banner" id="consent-banner" hidden data-consent-banner role="dialog" aria-live="polite" aria-label="${escapeHtml(strings.consentTitle)}">
  <div class="wrap consent-banner__inner">
    <div>
      <p class="consent-banner__title">${escapeHtml(strings.consentTitle)}</p>
      <p class="consent-banner__body">${escapeHtml(strings.consentBody)}</p>
    </div>
    <div class="consent-banner__actions">
      <button type="button" class="button button--ghost" data-consent-decline>${escapeHtml(strings.consentDecline)}</button>
      <button type="button" class="button button--primary" data-consent-accept>${escapeHtml(strings.consentAccept)}</button>
    </div>
  </div>
</div>''';
}

/// `analytics.js`: the consent banner's behaviour, plus a loader for each
/// vendor [config] actually names. Every vendor call sits behind two gates —
/// the visitor said yes, *and* [config] configured that vendor — so this file
/// is only ever written to the site when [AnalyticsConfig.anyEnabled] is true,
/// and even then sends nothing until consent is granted.
///
/// The list of events this site (and the app) can report is documented in
/// `ANALYTICS.md`, not invented here — `page_view` is the only one the static
/// site itself fires, since it has no interactive features of its own.
String analyticsScript(SiteConfig config) {
  final analytics = config.analytics;
  final vendorLoaders = <String>[
    if (analytics.firebaseEnabled) _firebaseLoader(analytics),
    if (analytics.yandexMetricaEnabled) _yandexMetricaLoader(analytics),
    if (analytics.appMetricaEnabled) _appMetricaWebLoader(analytics),
  ].join('\n');

  return '''
(function () {
  var STORAGE_KEY = 'mellisuga-analytics-consent';
  var banner = document.getElementById('consent-banner');

  function stored() {
    try {
      return localStorage.getItem(STORAGE_KEY);
    } catch (error) {
      return null;
    }
  }

  function store(value) {
    try {
      localStorage.setItem(STORAGE_KEY, value);
    } catch (error) {
      /* Storage disabled: the choice just will not be remembered. */
    }
  }

  function hideBanner() {
    if (banner) banner.hidden = true;
  }

  function showBanner() {
    if (banner) banner.hidden = false;
  }

  function loadVendors() {
$vendorLoaders
  }

  function enable() {
    hideBanner();
    loadVendors();
  }

  if (stored() === 'granted') {
    enable();
  } else if (stored() !== 'denied') {
    showBanner();
  }

  document.addEventListener('click', function (event) {
    var target = event.target;
    if (!target || !target.closest) return;
    if (target.closest('[data-consent-accept]')) {
      store('granted');
      enable();
    } else if (target.closest('[data-consent-decline]')) {
      store('denied');
      hideBanner();
    } else if (target.closest('[data-consent-manage]')) {
      event.preventDefault();
      showBanner();
    }
  });
})();
''';
}

/// Loads gtag.js and points it at the configured Firebase/GA4 measurement id.
/// This is the one loader that fetches its vendor script from a CDN
/// (`googletagmanager.com`) rather than a first-party path, because Firebase
/// Analytics on the web has no self-hosted alternative — exactly the
/// trade-off the consent banner exists to gate.
String _firebaseLoader(AnalyticsConfig analytics) =>
    '''
    if (!window.__mellisugaFirebaseLoaded) {
      window.__mellisugaFirebaseLoaded = true;
      window.dataLayer = window.dataLayer || [];
      window.gtag = window.gtag || function () { window.dataLayer.push(arguments); };
      gtag('js', new Date());
      gtag('config', ${jsonEncode(analytics.firebaseMeasurementId)});
      var gtagScript = document.createElement('script');
      gtagScript.async = true;
      gtagScript.src = 'https://www.googletagmanager.com/gtag/js?id=' + encodeURIComponent(${jsonEncode(analytics.firebaseMeasurementId)});
      document.head.appendChild(gtagScript);
    }''';

String _yandexMetricaLoader(AnalyticsConfig analytics) =>
    '''
    if (!window.__mellisugaYmLoaded) {
      window.__mellisugaYmLoaded = true;
      (function (m, e, t, r, i, k, a) {
        m[i] = m[i] || function () { (m[i].a = m[i].a || []).push(arguments); };
        m[i].l = 1 * new Date();
        k = e.createElement(t); a = e.getElementsByTagName(t)[0];
        k.async = 1; k.src = r; a.parentNode.insertBefore(k, a);
      })(window, document, 'script', 'https://mc.yandex.ru/metrika/tag.js', 'ym');
      ym(${jsonEncode(analytics.yandexMetricaCounterId)}, 'init', {
        clickmap: false,
        trackLinks: true,
        accurateTrackBounce: true,
        webvisor: false
      });
    }''';

/// AppMetrica's web SDK. Distinct from the `appmetrica_plugin` the Flutter app
/// uses — that plugin only covers Android and iOS, so the web build of both
/// the site and the app reports to AppMetrica through this script tag instead.
String _appMetricaWebLoader(AnalyticsConfig analytics) =>
    '''
    if (!window.__mellisugaAppMetricaLoaded) {
      window.__mellisugaAppMetricaLoaded = true;
      (function (m, e, t, r, i, k, a) {
        m[i] = m[i] || function () { (m[i].a = m[i].a || []).push(arguments); };
        m[i].l = 1 * new Date();
        k = e.createElement(t); a = e.getElementsByTagName(t)[0];
        k.async = 1; k.src = r; a.parentNode.insertBefore(k, a);
      })(window, document, 'script', 'https://appmetrica.yandex.com/tag.js?id=' + encodeURIComponent(${jsonEncode(analytics.appMetricaApiKey)}), 'appMetrica');
    }''';
