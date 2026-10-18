import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  SecureStorageService(this._secureStorage, this._prefs);

  // Auth tokens
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    String? csrfToken,
  }) async {
    await _secureStorage.write(key: StorageConstants.accessToken, value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _secureStorage.write(key: StorageConstants.refreshToken, value: refreshToken);
    }
    if (csrfToken != null && csrfToken.isNotEmpty) {
      await _secureStorage.write(key: StorageConstants.csrfToken, value: csrfToken);
    }
  }

  Future<void> saveUserProfile(Map<String, dynamic> userJson) async {
    await _prefs.setString(StorageConstants.userProfile, jsonEncode(userJson));
  }

  Map<String, dynamic>? getUserProfile() {
    final str = _prefs.getString(StorageConstants.userProfile);
    if (str == null || str.isEmpty) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: StorageConstants.accessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: StorageConstants.refreshToken);
  }

  Future<String?> getCsrfToken() async {
    return await _secureStorage.read(key: StorageConstants.csrfToken);
  }

  Future<void> clearAuth() async {
    await _secureStorage.delete(key: StorageConstants.accessToken);
    await _secureStorage.delete(key: StorageConstants.refreshToken);
    await _secureStorage.delete(key: StorageConstants.csrfToken);
    await _prefs.remove(StorageConstants.userProfile);
  }

  // BYOK Settings
  Future<void> saveByokChat({
    required String provider,
    required String key,
    required String model,
  }) async {
    await _secureStorage.write(key: StorageConstants.byokChatProvider, value: provider);
    await _secureStorage.write(key: StorageConstants.byokChatKey, value: key);
    await _secureStorage.write(key: StorageConstants.byokChatModel, value: model);
  }

  Future<Map<String, String?>> getByokChat() async {
    final provider = await _secureStorage.read(key: StorageConstants.byokChatProvider);
    final key = await _secureStorage.read(key: StorageConstants.byokChatKey);
    final model = await _secureStorage.read(key: StorageConstants.byokChatModel);
    return {
      'provider': provider,
      'key': key,
      'model': model,
    };
  }

  Future<void> clearByok() async {
    await _secureStorage.delete(key: StorageConstants.byokChatProvider);
    await _secureStorage.delete(key: StorageConstants.byokChatKey);
    await _secureStorage.delete(key: StorageConstants.byokChatModel);
    await _secureStorage.delete(key: StorageConstants.byokEmbeddingProvider);
    await _secureStorage.delete(key: StorageConstants.byokEmbeddingKey);
    await _secureStorage.delete(key: StorageConstants.byokEmbeddingModel);
  }

  // Preferences (Base URL, Active Model, Theme)
  String getBaseUrl() {
    return _prefs.getString(StorageConstants.baseUrl) ?? ApiConstants.defaultBaseUrl;
  }

  Future<void> setBaseUrl(String url) async {
    await _prefs.setString(StorageConstants.baseUrl, url);
  }

  String getActiveModel() {
    return _prefs.getString(StorageConstants.activeModel) ?? 'gemini-2.0-flash';
  }

  Future<void> setActiveModel(String model) async {
    await _prefs.setString(StorageConstants.activeModel, model);
  }

  String getThemeMode() {
    return _prefs.getString(StorageConstants.themeMode) ?? 'dark';
  }

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(StorageConstants.themeMode, mode);
  }
}
