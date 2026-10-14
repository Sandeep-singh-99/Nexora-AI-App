import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/sse_stream_reader.dart';
import '../models/analytics_model.dart';
import '../models/conversation_model.dart';
import '../models/document_model.dart';
import '../models/memory_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

class RemoteDataSource {
  final DioClient _dioClient;

  RemoteDataSource(this._dioClient);

  // AUTH
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      throw AuthException(response.data?['detail'] ?? 'Login failed', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw AuthException(e.response?.data?['detail'] ?? e.message ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.register,
        data: {'email': email, 'username': username, 'password': password},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      throw AuthException(response.data?['detail'] ?? 'Registration failed', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw AuthException(e.response?.data?['detail'] ?? e.message ?? 'Registration failed');
    }
  }

  Future<void> logout() async {
    try {
      await _dioClient.post(ApiConstants.logout);
    } catch (_) {}
  }

  Future<UserModel> getMe() async {
    final response = await _dioClient.get(ApiConstants.me);
    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    }
    throw AuthException('Failed to fetch user profile');
  }

  Future<void> forgotPassword(String email) async {
    await _dioClient.post(ApiConstants.forgotPassword, data: {'email': email});
  }

  Future<void> resetPassword({required String token, required String newPassword}) async {
    await _dioClient.post(ApiConstants.resetPassword, data: {
      'token': token,
      'new_password': newPassword,
    });
  }

  // CONVERSATIONS
  Future<List<ConversationModel>> getConversations({int limit = 50, int offset = 0}) async {
    final response = await _dioClient.get(
      ApiConstants.conversations,
      queryParameters: {'limit': limit, 'offset': offset},
    );
    if (response.statusCode == 200) {
      final data = response.data;
      final List list = data is List ? data : (data['items'] ?? data['conversations'] ?? []);
      return list.map((e) => ConversationModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw ServerException('Failed to load conversations', statusCode: response.statusCode);
  }

  Future<ConversationModel> createConversation({
    required String title,
    String? message,
    required String model,
    String? documentName,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.conversations,
      data: {
        'title': title,
        if (message != null) 'message': message,
        'model': model,
        if (documentName != null) 'document_name': documentName,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ConversationModel.fromJson(response.data as Map<String, dynamic>);
    }
    throw ServerException('Failed to create conversation', statusCode: response.statusCode);
  }

  Future<String> generateTitle(String conversationId) async {
    final response = await _dioClient.post(ApiConstants.generateTitle(conversationId));
    if (response.statusCode == 200) {
      return response.data['title'] as String? ?? 'Conversation';
    }
    return 'Conversation';
  }

  Future<ConversationModel> updateConversation({
    required String id,
    String? title,
    bool? isPinned,
    bool? isArchived,
    String? model,
  }) async {
    final response = await _dioClient.patch(
      ApiConstants.conversation(id),
      data: {
        if (title != null) 'title': title,
        if (isPinned != null) 'is_pinned': isPinned,
        if (isArchived != null) 'is_archived': isArchived,
        if (model != null) 'model': model,
      },
    );
    if (response.statusCode == 200) {
      return ConversationModel.fromJson(response.data as Map<String, dynamic>);
    }
    throw ServerException('Failed to update conversation', statusCode: response.statusCode);
  }

  Future<void> deleteConversation(String id) async {
    await _dioClient.delete(ApiConstants.conversation(id));
  }

  Future<void> bulkDeleteConversations() async {
    await _dioClient.delete(ApiConstants.conversations);
  }

  Future<List<MessageModel>> getMessages(String conversationId, {int limit = 100}) async {
    final response = await _dioClient.get(
      ApiConstants.conversationMessages(conversationId),
      queryParameters: {'limit': limit},
    );
    if (response.statusCode == 200) {
      final data = response.data;
      final List list = data is List ? data : (data['messages'] ?? data['items'] ?? []);
      return list.map((e) => MessageModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw ServerException('Failed to load messages', statusCode: response.statusCode);
  }

  // CHAT STREAM
  Stream<SseEvent> streamChat({
    required String conversationId,
    required String message,
    required String model,
    String? documentId,
    CancelToken? cancelToken,
  }) {
    return _dioClient.postStream(
      ApiConstants.chatStream,
      cancelToken: cancelToken,
      data: {
        'conversation_id': conversationId,
        'message': message,
        'model': model,
        if (documentId != null) 'document_id': documentId,
      },
    );
  }

  // DOCUMENTS
  Future<List<DocumentModel>> getDocuments() async {
    final response = await _dioClient.get(ApiConstants.documents);
    if (response.statusCode == 200) {
      final data = response.data;
      final List list = data is List ? data : (data['documents'] ?? []);
      return list.map((e) => DocumentModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw ServerException('Failed to load documents');
  }

  Future<DocumentModel> uploadDocument({
    required File file,
    bool confirmSensitive = false,
  }) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
      'confirm_sensitive': confirmSensitive,
    });

    try {
      final response = await _dioClient.post(
        ApiConstants.documentUpload,
        data: formData,
      );

      if (response.statusCode == 409) {
        final data = response.data as Map<String, dynamic>? ?? {};
        if (data['error'] == 'SENSITIVE_DATA_DETECTED' || data['code'] == 'SENSITIVE_DATA_DETECTED') {
          throw SensitiveDataException(
            data['message'] ?? 'Sensitive data detected in document.',
            piiDetails: data,
          );
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return DocumentModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw ServerException('Upload failed', statusCode: response.statusCode);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        final data = e.response?.data as Map<String, dynamic>? ?? {};
        throw SensitiveDataException(
          data['message'] ?? 'Sensitive data detected in document.',
          piiDetails: data,
        );
      }
      rethrow;
    }
  }

  Future<void> deleteDocument(String id) async {
    await _dioClient.delete(ApiConstants.document(id));
  }

  Future<void> ingestYoutube(String url) async {
    await _dioClient.post(ApiConstants.documentYoutube, data: {'url': url});
  }

  Future<String> queryDocument({required String documentId, required String query}) async {
    final response = await _dioClient.post(
      ApiConstants.documentQuery,
      data: {'document_id': documentId, 'query': query},
    );
    return response.data['answer'] as String? ?? 'No answer provided.';
  }

  // MEMORY
  Future<List<MemoryModel>> getMemories({String? category, String? query}) async {
    final response = await _dioClient.get(
      ApiConstants.memory,
      queryParameters: {
        if (category != null) 'category': category,
        if (query != null) 'q': query,
      },
    );
    if (response.statusCode == 200) {
      final data = response.data;
      final List list = data is List ? data : (data['memories'] ?? []);
      return list.map((e) => MemoryModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw ServerException('Failed to load memories');
  }

  Future<MemoryModel> createMemory({required String content, required String category}) async {
    final response = await _dioClient.post(
      ApiConstants.memory,
      data: {'content': content, 'category': category},
    );
    return MemoryModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<MemoryModel> updateMemory({required String id, required String content, required String category}) async {
    final response = await _dioClient.patch(
      ApiConstants.memoryItem(id),
      data: {'content': content, 'category': category},
    );
    return MemoryModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteMemory(String id) async {
    await _dioClient.delete(ApiConstants.memoryItem(id));
  }

  Future<KnowledgeGraphModel> getKnowledgeGraph() async {
    final response = await _dioClient.get(ApiConstants.memoryGraph);
    if (response.statusCode == 200) {
      return KnowledgeGraphModel.fromJson(response.data as Map<String, dynamic>);
    }
    throw ServerException('Failed to load knowledge graph');
  }

  // ANALYTICS
  Future<AnalyticsModel> getAnalytics({String timeframe = 'week'}) async {
    final response = await _dioClient.get(
      ApiConstants.analytics,
      queryParameters: {'timeframe': timeframe},
    );
    if (response.statusCode == 200) {
      return AnalyticsModel.fromJson(response.data as Map<String, dynamic>);
    }
    throw ServerException('Failed to load analytics');
  }
}
