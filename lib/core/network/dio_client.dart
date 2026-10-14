import 'dart:async';
import 'package:dio/dio.dart';
import '../security/secure_storage_service.dart';
import 'auth_interceptor.dart';
import 'sse_stream_reader.dart';

class DioClient {
  final SecureStorageService _storageService;
  late final Dio dio;
  late final Dio _refreshDio;

  DioClient(this._storageService) {
    final baseUrl = _storageService.getBaseUrl();

    final baseOptions = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      validateStatus: (status) => status != null && status < 500,
    );

    _refreshDio = Dio(baseOptions);
    dio = Dio(baseOptions);

    dio.interceptors.add(
      AuthInterceptor(_storageService, _refreshDio),
    );
  }

  void updateBaseUrl(String newUrl) {
    dio.options.baseUrl = newUrl;
    _refreshDio.options.baseUrl = newUrl;
  }

  /// Sends a request and streams back parsed SSE events
  Stream<SseEvent> postStream(
    String path, {
    dynamic data,
    CancelToken? cancelToken,
  }) async* {
    final response = await dio.post<ResponseBody>(
      path,
      data: data,
      cancelToken: cancelToken,
      options: Options(
        responseType: ResponseType.stream,
        headers: {
          'Accept': 'text/event-stream',
          'Cache-Control': 'no-cache',
        },
      ),
    );

    if (response.data == null) {
      yield const SseErrorEvent(
        errorCode: 'EMPTY_STREAM',
        message: 'No response data received from server.',
      );
      return;
    }

    yield* SseStreamReader.parseStream(response.data!.stream);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}
