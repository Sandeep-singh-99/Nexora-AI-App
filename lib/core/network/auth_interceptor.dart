import 'dart:async';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../security/secure_storage_service.dart';

class AuthInterceptor extends QueuedInterceptor {
  final SecureStorageService _storageService;
  final Dio _refreshDio;

  AuthInterceptor(this._storageService, this._refreshDio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Ensure mobile client identifier header is present
    options.headers['X-Client-Type'] = 'mobile';

    // Skip auth header for login, register, and refresh
    final isAuthEndpoint = options.path.contains(ApiConstants.login) ||
        options.path.contains(ApiConstants.register) ||
        options.path.contains(ApiConstants.refresh);

    if (!isAuthEndpoint) {
      final token = await _storageService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      final csrf = await _storageService.getCsrfToken();
      if (csrf != null && csrf.isNotEmpty) {
        options.headers['X-CSRF-Token'] = csrf;
      }

      // Inject BYOK headers if available
      final byok = await _storageService.getByokChat();
      if (byok['key'] != null && byok['key']!.isNotEmpty) {
        options.headers['x-custom-chat-key'] = byok['key'];
        if (byok['provider'] != null) {
          options.headers['x-custom-chat-provider'] = byok['provider'];
        }
        if (byok['model'] != null) {
          options.headers['x-custom-chat-model'] = byok['model'];
        }
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains(ApiConstants.refresh)) {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          final baseUrl = _storageService.getBaseUrl();
          final response = await _refreshDio.post(
            '$baseUrl${ApiConstants.refresh}',
            data: {'refresh_token': refreshToken},
          );

          if (response.statusCode == 200 && response.data != null) {
            final data = response.data is Map ? (response.data as Map) : <String, dynamic>{};
            final newAccessToken = (data['access_token'] ?? data['token']) as String?;
            final newRefreshToken = (data['refresh_token'] as String?) ?? refreshToken;
            final newCsrf = (data['csrf_token'] as String?) ??
                response.headers.value('x-csrf-token');

            if (newAccessToken != null && newAccessToken.isNotEmpty) {
              await _storageService.saveTokens(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken,
                csrfToken: newCsrf,
              );

              // Retry original request with new token
              final originalOptions = err.requestOptions;
              originalOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              if (newCsrf != null) {
                originalOptions.headers['X-CSRF-Token'] = newCsrf;
              }

              final retryResponse = await _refreshDio.fetch(originalOptions);
              return handler.resolve(retryResponse);
            }
          }
        } catch (_) {
          // Token refresh failed, clear credentials
          await _storageService.clearAuth();
        }
      }
    }

    return handler.next(err);
  }
}
