import '../../core/security/secure_storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource _remoteDataSource;
  final SecureStorageService _storageService;

  AuthRepositoryImpl(this._remoteDataSource, this._storageService);

  @override
  Future<UserEntity> login({required String email, required String password}) async {
    final res = await _remoteDataSource.login(email: email, password: password);
    final accessToken = res['access_token'] as String;
    final refreshToken = res['refresh_token'] as String;
    final csrfToken = res['csrf_token'] as String?;

    await _storageService.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      csrfToken: csrfToken,
    );

    if (res['user'] != null) {
      return UserModel.fromJson(res['user'] as Map<String, dynamic>);
    }

    return await getCurrentUser() ??
        UserModel(id: 'me', email: email, username: email.split('@').first);
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String username,
    required String password,
  }) async {
    final res = await _remoteDataSource.register(
      email: email,
      username: username,
      password: password,
    );
    final accessToken = res['access_token'] as String?;
    final refreshToken = res['refresh_token'] as String?;
    final csrfToken = res['csrf_token'] as String?;

    if (accessToken != null && refreshToken != null) {
      await _storageService.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        csrfToken: csrfToken,
      );
    }

    if (res['user'] != null) {
      return UserModel.fromJson(res['user'] as Map<String, dynamic>);
    }

    return UserModel(id: 'registered', email: email, username: username);
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
    await _storageService.clearAuth();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final token = await _storageService.getAccessToken();
      if (token == null || token.isEmpty) return null;
      return await _remoteDataSource.getMe();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> resetPassword({required String token, required String newPassword}) async {
    await _remoteDataSource.resetPassword(token: token, newPassword: newPassword);
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _storageService.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
