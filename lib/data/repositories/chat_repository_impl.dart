import 'package:dio/dio.dart';
import '../../core/network/sse_stream_reader.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final RemoteDataSource _remoteDataSource;

  ChatRepositoryImpl(this._remoteDataSource);

  @override
  Stream<SseEvent> streamChat({
    required String conversationId,
    required String message,
    required String model,
    String? documentId,
    CancelToken? cancelToken,
  }) {
    return _remoteDataSource.streamChat(
      conversationId: conversationId,
      message: message,
      model: model,
      documentId: documentId,
      cancelToken: cancelToken,
    );
  }
}
