import '../../core/errors/exceptions.dart';
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
    final accessToken = (res['access_token'] ?? res['token'])?.toString();
    if (accessToken == null || accessToken.isEmpty) {
      throw AuthException('Authentication token missing from response');
    }
    final refreshToken = (res['refresh_token'] ?? res['refreshToken'])?.toString();
    final csrfToken = (res['csrf_token'] ?? res['csrfToken'])?.toString();

    await _storageService.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      csrfToken: csrfToken,
    );

    final UserEntity user;
    if (res['user'] != null && res['user'] is Map) {
      user = UserModel.fromJson(Map<String, dynamic>.from(res['user'] as Map));
    } else {
      user = UserModel(
        id: 'me',
        email: email,
        username: email.contains('@') ? email.split('@').first : email,
      );
    }

    if (user is UserModel) {
      await _storageService.saveUserProfile(user.toJson());
    }

    return user;
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
    final accessToken = (res['access_token'] ?? res['token'])?.toString();
    final refreshToken = (res['refresh_token'] ?? res['refreshToken'])?.toString();
    final csrfToken = (res['csrf_token'] ?? res['csrfToken'])?.toString();

    if (accessToken != null && accessToken.isNotEmpty) {
      await _storageService.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        csrfToken: csrfToken,
      );
    }

    final UserEntity user;
    if (res['user'] != null && res['user'] is Map) {
      user = UserModel.fromJson(Map<String, dynamic>.from(res['user'] as Map));
    } else {
      user = UserModel(id: 'registered', email: email, username: username);
    }

    if (user is UserModel) {
      await _storageService.saveUserProfile(user.toJson());
    }

    return user;
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
    await _storageService.clearAuth();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final cachedJson = _storageService.getUserProfile();
    final cachedUser = cachedJson != null ? UserModel.fromJson(cachedJson) : null;

    final token = await _storageService.getAccessToken();
    final refreshToken = await _storageService.getRefreshToken();
    final hasAnyToken = (token != null && token.isNotEmpty) || (refreshToken != null && refreshToken.isNotEmpty);

    if (!hasAnyToken) {
      return null;
    }

    try {
      final fresh = await _remoteDataSource.getMe();
      await _storageService.saveUserProfile(fresh.toJson());
      return fresh;
    } catch (_) {
      // Check if tokens were explicitly cleared by unrecoverable 401 refresh failure
      final stillHasToken = await _storageService.getAccessToken();
      final stillHasRefreshToken = await _storageService.getRefreshToken();
      if ((stillHasToken == null || stillHasToken.isEmpty) &&
          (stillHasRefreshToken == null || stillHasRefreshToken.isEmpty)) {
        return null;
      }

      // If network drop, timeout, or server cold start, fall back to cached user profile
      if (cachedUser != null) {
        return cachedUser;
      }

      return const UserModel(id: 'me', email: 'user@nexora.ai', username: 'User');
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
    final refreshToken = await _storageService.getRefreshToken();
    return (token != null && token.isNotEmpty) || (refreshToken != null && refreshToken.isNotEmpty);
  }
}
