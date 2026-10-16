import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexora_ai_app/core/network/sse_stream_reader.dart';
import 'package:nexora_ai_app/domain/entities/conversation_entity.dart';
import 'package:nexora_ai_app/domain/entities/message_entity.dart';
import 'package:nexora_ai_app/domain/repositories/chat_repository.dart';
import 'package:nexora_ai_app/domain/repositories/conversation_repository.dart';
import 'package:nexora_ai_app/presentation/blocs/chat/chat_bloc.dart';
import 'package:nexora_ai_app/presentation/blocs/chat/chat_event.dart';
import 'package:nexora_ai_app/presentation/blocs/chat/chat_state.dart';
import 'package:nexora_ai_app/presentation/blocs/conversation/conversation_bloc.dart';
import 'package:nexora_ai_app/presentation/blocs/conversation/conversation_event.dart';
import 'package:nexora_ai_app/presentation/blocs/conversation/conversation_state.dart';

class MockChatRepository implements ChatRepository {
  final StreamController<SseEvent> streamController = StreamController<SseEvent>.broadcast();

  @override
  Stream<SseEvent> streamChat({
    required String conversationId,
    required String message,
    required String model,
    String? documentId,
    CancelToken? cancelToken,
  }) {
    return streamController.stream;
  }
}

class MockConversationRepository implements ConversationRepository {
  final List<MessageEntity> persistedMessages = [];
  final List<ConversationEntity> conversations = [];

  @override
  Future<MessageEntity> addMessage({
    required String conversationId,
    required String content,
    required String role,
    Map<String, dynamic>? metadata,
  }) async {
    final msg = MessageEntity(
      id: 'msg-${persistedMessages.length}',
      conversationId: conversationId,
      role: role,
      content: content,
      createdAt: DateTime.now(),
    );
    persistedMessages.add(msg);
    return msg;
  }

  @override
  Future<ConversationEntity> createConversation({
    required String title,
    String? message,
    required String model,
    String? documentName,
  }) async {
    final conv = ConversationEntity(
      id: 'conv-${conversations.length + 1}',
      title: title,
      model: model,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    conversations.insert(0, conv);
    return conv;
  }

  @override
  Future<List<ConversationEntity>> getConversations({int limit = 50, int offset = 0}) async {
    return List.from(conversations);
  }

  @override
  Future<String> autoGenerateTitle(
    String conversationId, {
    String? message,
    String? assistantResponse,
    String? documentName,
  }) async {
    return 'Generated Title';
  }

  @override
  Future<void> bulkDeleteConversations() async {
    conversations.clear();
  }

  @override
  Future<void> deleteConversation(String id) async {
    conversations.removeWhere((c) => c.id == id);
  }

  @override
  Future<List<MessageEntity>> getMessages(String conversationId, {int limit = 100}) async {
    return persistedMessages.where((m) => m.conversationId == conversationId).toList();
  }

  @override
  Future<ConversationEntity> updateConversation({
    required String id,
    String? title,
    bool? isPinned,
    bool? isArchived,
    String? model,
  }) async {
    final index = conversations.indexWhere((c) => c.id == id);
    final updated = conversations[index].copyWith(
      title: title,
      isPinned: isPinned,
      isArchived: isArchived,
      model: model,
    );
    conversations[index] = updated;
    return updated;
  }
}

void main() {
  group('Chat & Conversation Persistence Tests', () {
    late MockChatRepository mockChatRepo;
    late MockConversationRepository mockConvRepo;
    late ChatBloc chatBloc;
    late ConversationBloc convBloc;

    setUp(() {
      mockChatRepo = MockChatRepository();
      mockConvRepo = MockConversationRepository();
      chatBloc = ChatBloc(
        chatRepository: mockChatRepo,
        conversationRepository: mockConvRepo,
      );
      convBloc = ConversationBloc(mockConvRepo);
    });

    tearDown(() {
      chatBloc.close();
      convBloc.close();
    });

    test('ChatBloc persists user message and assistant message on stream completion', () async {
      const convId = 'test-conv-1';
      chatBloc.add(const SendMessage(
        conversationId: convId,
        content: 'Hello AI',
        model: 'groq',
      ));

      // Allow microtasks to run for user message persistence
      await Future.delayed(const Duration(milliseconds: 50));
      expect(mockConvRepo.persistedMessages.length, 1);
      expect(mockConvRepo.persistedMessages.first.role, 'user');
      expect(mockConvRepo.persistedMessages.first.content, 'Hello AI');

      // Emit token and end stream
      chatBloc.add(const StreamTokenReceived('Hello human!'));
      chatBloc.add(const StreamEndReceived(conversationId: convId));

      await Future.delayed(const Duration(milliseconds: 50));
      expect(mockConvRepo.persistedMessages.length, 2);
      expect(mockConvRepo.persistedMessages[1].role, 'assistant');
      expect(mockConvRepo.persistedMessages[1].content, 'Hello human!');

      // Second end event (e.g. from stream onDone) should NOT save a duplicate
      chatBloc.add(const StreamEndReceived(conversationId: convId));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(mockConvRepo.persistedMessages.length, 2); // Still strictly 2!
    });

    test('ChatBloc ResetChat clears all loaded messages', () async {
      chatBloc.add(const ResetChat());
      await Future.delayed(const Duration(milliseconds: 20));

      expect(chatBloc.state, isA<ChatLoaded>());
      expect((chatBloc.state as ChatLoaded).messages, isEmpty);
    });

    test('ConversationBloc ResetToNewChat sets selectedConversationId to null', () async {
      mockConvRepo.conversations.add(ConversationEntity(
        id: 'conv-1',
        title: 'Initial',
        model: 'groq',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      convBloc.add(LoadConversations());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(convBloc.state, isA<ConversationLoaded>());
      expect((convBloc.state as ConversationLoaded).selectedConversationId, 'conv-1');

      convBloc.add(ResetToNewChat());
      await Future.delayed(const Duration(milliseconds: 20));

      expect((convBloc.state as ConversationLoaded).selectedConversationId, isNull);
    });

    test('ConversationBloc CreateConversation completes completer with newly created conversation', () async {
      final completer = Completer<ConversationEntity>();
      convBloc.add(CreateConversation(
        title: 'New Chat',
        initialMessage: 'My first prompt',
        model: 'groq',
        completer: completer,
      ));

      final created = await completer.future.timeout(const Duration(seconds: 1));
      expect(created.id, isNotEmpty);
      expect(created.title, 'New Chat');
      expect((convBloc.state as ConversationLoaded).selectedConversationId, created.id);
    });

    test('ConversationBloc LoadConversations preserves currently selected conversation', () async {
      mockConvRepo.conversations.addAll([
        ConversationEntity(
          id: 'conv-1',
          title: 'First',
          model: 'groq',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ConversationEntity(
          id: 'conv-2',
          title: 'Second',
          model: 'groq',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ]);

      convBloc.add(LoadConversations());
      await Future.delayed(const Duration(milliseconds: 50));
      convBloc.add(const SelectConversation('conv-2'));
      await Future.delayed(const Duration(milliseconds: 20));

      expect((convBloc.state as ConversationLoaded).selectedConversationId, 'conv-2');

      // Reload conversations (e.g. after stream done)
      convBloc.add(LoadConversations());
      await Future.delayed(const Duration(milliseconds: 50));

      // Should still be conv-2, NOT reset to conv-1
      expect((convBloc.state as ConversationLoaded).selectedConversationId, 'conv-2');
    });
  });
}
