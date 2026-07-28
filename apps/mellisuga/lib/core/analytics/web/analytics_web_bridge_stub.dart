/// No-op implementation for every non-web platform.
///
/// Yandex Metrica and the AppMetrica Web SDK are, as their names say, web
/// products with no Flutter plugin — on Android and iOS, AppMetrica's own
/// `appmetrica_plugin` is used instead (see `analytics_service.dart`), and on
/// desktop nothing runs at all.
void loadYandexMetricaWeb(String counterId) {}

void loadAppMetricaWeb(String apiKey) {}

void logYandexMetricaGoal(String name) {}

void logAppMetricaWebEvent(String name, Map<String, Object?>? parameters) {}
