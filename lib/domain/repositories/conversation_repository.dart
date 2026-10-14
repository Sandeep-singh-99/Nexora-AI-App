import '../entities/conversation_entity.dart';
import '../entities/message_entity.dart';

abstract class ConversationRepository {
  Future<List<ConversationEntity>> getConversations({int limit = 50, int offset = 0});
  Future<ConversationEntity> createConversation({
    required String title,
    String? message,
    required String model,
    String? documentName,
  });
  Future<String> autoGenerateTitle(String conversationId);
  Future<ConversationEntity> updateConversation({
    required String id,
    String? title,
    bool? isPinned,
    bool? isArchived,
    String? model,
  });
  Future<void> deleteConversation(String id);
  Future<void> bulkDeleteConversations();
  Future<List<MessageEntity>> getMessages(String conversationId, {int limit = 100});
}
