import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Web implementations backing `analytics_web_bridge.dart`.
///
/// Both loaders inject the vendor's own bootstrap snippet as an inline
/// `<script>`, the same snippet the landing site uses in
/// `apps/jasper/lib/src/analytics.dart` — including the shim that queues
/// calls until the real script (fetched from the vendor's CDN) finishes
/// loading. That shim is why `logYandexMetricaGoal` and
/// `logAppMetricaWebEvent` are safe to call immediately after loading: the
/// call just queues if the network fetch has not finished yet.
void loadYandexMetricaWeb(String counterId) {
  if (_ymLoaded) return;
  _ymLoaded = true;
  _ymCounterId = counterId;
  _inject('''
(function (m, e, t, r, i, k, a) {
  m[i] = m[i] || function () { (m[i].a = m[i].a || []).push(arguments); };
  m[i].l = 1 * new Date();
  k = e.createElement(t); a = e.getElementsByTagName(t)[0];
  k.async = 1; k.src = r; a.parentNode.insertBefore(k, a);
})(window, document, 'script', 'https://mc.yandex.ru/metrika/tag.js', 'ym');
ym(${jsonEncode(counterId)}, 'init', { clickmap: false, trackLinks: true, accurateTrackBounce: true, webvisor: false });
''');
}

void loadAppMetricaWeb(String apiKey) {
  if (_appMetricaLoaded) return;
  _appMetricaLoaded = true;
  _inject('''
(function (m, e, t, r, i, k, a) {
  m[i] = m[i] || function () { (m[i].a = m[i].a || []).push(arguments); };
  m[i].l = 1 * new Date();
  k = e.createElement(t); a = e.getElementsByTagName(t)[0];
  k.async = 1; k.src = r; a.parentNode.insertBefore(k, a);
})(window, document, 'script', 'https://appmetrica.yandex.com/tag.js?id=' + encodeURIComponent(${jsonEncode(apiKey)}), 'appMetrica');
''');
}

void logYandexMetricaGoal(String name) {
  final counterId = _ymCounterId;
  if (!_ymLoaded || counterId == null) return;
  _ymReachGoal(counterId.toJS, 'reachGoal', name.toJS);
}

void logAppMetricaWebEvent(String name, Map<String, Object?>? parameters) {
  if (!_appMetricaLoaded) return;
  _appMetricaReportEvent(name.toJS, (parameters == null ? null : jsonEncode(parameters))?.toJS);
}

bool _ymLoaded = false;
String? _ymCounterId;
bool _appMetricaLoaded = false;

void _inject(String script) {
  final element = web.document.createElement('script') as web.HTMLScriptElement
    ..type = 'text/javascript'
    ..text = script;
  web.document.head?.appendChild(element);
}

/// `window.ym`'s shim queues this call if the real script has not finished
/// loading yet, so it is safe to call as soon as [loadYandexMetricaWeb] has
/// run — no need to await the network fetch first.
@JS('ym')
external void _ymReachGoal(JSAny counterId, String action, JSString goal);

/// `window.appMetrica.reportEvent`, likewise safe to call before the real
/// script has loaded.
@JS('appMetrica.reportEvent')
external void _appMetricaReportEvent(JSString name, JSString? parametersJson);
