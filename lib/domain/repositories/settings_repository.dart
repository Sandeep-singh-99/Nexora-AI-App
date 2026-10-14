import '../entities/analytics_entity.dart';

abstract class SettingsRepository {
  Future<void> saveByokChat({required String provider, required String key, required String model});
  Future<Map<String, String?>> getByokChat();
  Future<void> clearByok();
  Future<AnalyticsEntity> getAnalytics({String timeframe = 'week'});
  String getBaseUrl();
  Future<void> setBaseUrl(String url);
  String getActiveModel();
  Future<void> setActiveModel(String model);
  String getThemeMode();
  Future<void> setThemeMode(String mode);
}
