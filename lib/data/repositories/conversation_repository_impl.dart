import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../datasources/remote_datasource.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final RemoteDataSource _remoteDataSource;

  ConversationRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ConversationEntity>> getConversations({int limit = 50, int offset = 0}) {
    return _remoteDataSource.getConversations(limit: limit, offset: offset);
  }

  @override
  Future<ConversationEntity> createConversation({
    required String title,
    String? message,
    required String model,
    String? documentName,
  }) {
    return _remoteDataSource.createConversation(
      title: title,
      message: message,
      model: model,
      documentName: documentName,
    );
  }

  @override
  Future<String> autoGenerateTitle(
    String conversationId, {
    String? message,
    String? assistantResponse,
    String? documentName,
  }) {
    return _remoteDataSource.generateTitle(
      conversationId,
      message: message,
      assistantResponse: assistantResponse,
      documentName: documentName,
    );
  }

  @override
  Future<ConversationEntity> updateConversation({
    required String id,
    String? title,
    bool? isPinned,
    bool? isArchived,
    String? model,
  }) {
    return _remoteDataSource.updateConversation(
      id: id,
      title: title,
      isPinned: isPinned,
      isArchived: isArchived,
      model: model,
    );
  }

  @override
  Future<void> deleteConversation(String id) {
    return _remoteDataSource.deleteConversation(id);
  }

  @override
  Future<void> bulkDeleteConversations() {
    return _remoteDataSource.bulkDeleteConversations();
  }

  @override
  Future<List<MessageEntity>> getMessages(String conversationId, {int limit = 100}) {
    return _remoteDataSource.getMessages(conversationId, limit: limit);
  }
}
