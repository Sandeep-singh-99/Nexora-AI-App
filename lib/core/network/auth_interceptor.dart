import 'dart:async';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../security/secure_storage_service.dart';

class AuthInterceptor extends QueuedInterceptor {
  final SecureStorageService _storageService;
  final Dio _refreshDio;
  Completer<String?>? _refreshCompleter;

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
    final isRefreshEndpoint = err.requestOptions.path.contains(ApiConstants.refresh);
    final isAuthAction = err.requestOptions.path.contains(ApiConstants.login) ||
        err.requestOptions.path.contains(ApiConstants.register);

    if (err.response?.statusCode == 401 && !isRefreshEndpoint && !isAuthAction) {
      // If another request is currently refreshing the token, wait for it
      if (_refreshCompleter != null) {
        try {
          final newAccessToken = await _refreshCompleter!.future;
          if (newAccessToken != null && newAccessToken.isNotEmpty) {
            final originalOptions = err.requestOptions;
            originalOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            final retryResponse = await _refreshDio.fetch(originalOptions);
            return handler.resolve(retryResponse);
          }
        } catch (_) {}
        return handler.next(err);
      }

      _refreshCompleter = Completer<String?>();
      final refreshToken = await _storageService.getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          final baseUrl = _storageService.getBaseUrl();
          final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
          final refreshPath = ApiConstants.refresh.startsWith('/') ? ApiConstants.refresh : '/${ApiConstants.refresh}';
          final url = '$cleanBase$refreshPath';

          final response = await _refreshDio.post(
            url,
            data: {
              'refresh_token': refreshToken,
              'refreshToken': refreshToken,
            },
            options: Options(
              headers: {
                'Authorization': 'Bearer $refreshToken',
                'X-Client-Type': 'mobile',
              },
            ),
          );

          if (response.statusCode == 200 && response.data != null) {
            final data = response.data is Map ? (response.data as Map) : <String, dynamic>{};
            final newAccessToken = (data['access_token'] ?? data['token'] ?? data['accessToken']) as String?;
            final newRefreshToken = (data['refresh_token'] ?? data['refreshToken']) as String? ?? refreshToken;
            final newCsrf = (data['csrf_token'] ?? data['csrfToken']) as String? ??
                response.headers.value('x-csrf-token');

            if (newAccessToken != null && newAccessToken.isNotEmpty) {
              await _storageService.saveTokens(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken,
                csrfToken: newCsrf,
              );

              _refreshCompleter?.complete(newAccessToken);
              _refreshCompleter = null;

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

          _refreshCompleter?.complete(null);
          _refreshCompleter = null;
        } catch (refreshErr) {
          _refreshCompleter?.complete(null);
          _refreshCompleter = null;

          // Only wipe stored tokens if server explicitly rejected the refresh token with 401 or 403
          // Do NOT clear auth on network dropouts, socket timeouts, or server cold starts!
          if (refreshErr is DioException) {
            final status = refreshErr.response?.statusCode;
            if (status == 401 || status == 403) {
              await _storageService.clearAuth();
            }
          }
        }
      } else {
        _refreshCompleter?.complete(null);
        _refreshCompleter = null;
        await _storageService.clearAuth();
      }
    }

    return handler.next(err);
  }
}
