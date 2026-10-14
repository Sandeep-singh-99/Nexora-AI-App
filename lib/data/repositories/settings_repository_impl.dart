import '../../core/security/secure_storage_service.dart';
import '../../domain/entities/analytics_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/remote_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final RemoteDataSource _remoteDataSource;
  final SecureStorageService _storageService;

  SettingsRepositoryImpl(this._remoteDataSource, this._storageService);

  @override
  Future<void> saveByokChat({required String provider, required String key, required String model}) {
    return _storageService.saveByokChat(provider: provider, key: key, model: model);
  }

  @override
  Future<Map<String, String?>> getByokChat() {
    return _storageService.getByokChat();
  }

  @override
  Future<void> clearByok() {
    return _storageService.clearByok();
  }

  @override
  Future<AnalyticsEntity> getAnalytics({String timeframe = 'week'}) {
    return _remoteDataSource.getAnalytics(timeframe: timeframe);
  }

  @override
  String getBaseUrl() {
    return _storageService.getBaseUrl();
  }

  @override
  Future<void> setBaseUrl(String url) {
    return _storageService.setBaseUrl(url);
  }

  @override
  String getActiveModel() {
    return _storageService.getActiveModel();
  }

  @override
  Future<void> setActiveModel(String model) {
    return _storageService.setActiveModel(model);
  }

  @override
  String getThemeMode() {
    return _storageService.getThemeMode();
  }

  @override
  Future<void> setThemeMode(String mode) {
    return _storageService.setThemeMode(mode);
  }
}
