import 'package:dio/dio.dart';
import '../../core/network/sse_stream_reader.dart';

abstract class ChatRepository {
  Stream<SseEvent> streamChat({
    required String conversationId,
    required String message,
    required String model,
    String? documentId,
    CancelToken? cancelToken,
  });
}
