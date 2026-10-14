import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/sse_stream_reader.dart';
import '../../../data/models/message_model.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/repositories/chat_repository.dart';
import '../../../domain/repositories/conversation_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  final ConversationRepository _conversationRepository;

  StreamSubscription<SseEvent>? _streamSubscription;
  CancelToken? _cancelToken;

  ChatBloc({
    required ChatRepository chatRepository,
    required ConversationRepository conversationRepository,
  })  : _chatRepository = chatRepository,
        _conversationRepository = conversationRepository,
        super(ChatInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<StopGeneration>(_onStopGeneration);
    on<RegenerateLastResponse>(_onRegenerateLastResponse);
    on<ToggleThinkingExpanded>(_onToggleThinkingExpanded);
    on<ClearChatError>(_onClearChatError);

    // Stream event handlers
    on<StreamTokenReceived>(_onStreamTokenReceived);
    on<StreamStatusReceived>(_onStreamStatusReceived);
    on<StreamThinkingReceived>(_onStreamThinkingReceived);
    on<StreamSearchReceived>(_onStreamSearchReceived);
    on<StreamUiReceived>(_onStreamUiReceived);
    on<StreamKeyMetaReceived>(_onStreamKeyMetaReceived);
    on<StreamEndReceived>(_onStreamEndReceived);
    on<StreamErrorReceived>(_onStreamErrorReceived);
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final messages = await _conversationRepository.getMessages(event.conversationId);
      emit(ChatLoaded(messages: messages));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    List<MessageEntity> currentMessages = [];
    Set<String> expandedThinking = {};

    if (state is ChatLoaded) {
      final s = state as ChatLoaded;
      currentMessages = List.from(s.messages);
      expandedThinking = Set.from(s.expandedThinkingMessageIds);
    }

    final userMessage = MessageEntity(
      id: UniqueKeyString.generate(),
      conversationId: event.conversationId,
      role: 'user',
      content: event.content,
      createdAt: DateTime.now(),
    );

    final assistantMessageId = UniqueKeyString.generate();
    final assistantPlaceholder = MessageEntity(
      id: assistantMessageId,
      conversationId: event.conversationId,
      role: 'assistant',
      content: '',
      isStreaming: true,
      createdAt: DateTime.now(),
    );

    currentMessages.add(userMessage);
    currentMessages.add(assistantPlaceholder);

    emit(ChatLoaded(
      messages: currentMessages,
      isStreaming: true,
      activeStatus: 'Starting generation...',
      expandedThinkingMessageIds: expandedThinking,
    ));

    // Cancel existing stream if any
    await _streamSubscription?.cancel();
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    try {
      final stream = _chatRepository.streamChat(
        conversationId: event.conversationId,
        message: event.content,
        model: event.model,
        documentId: event.documentId,
        cancelToken: _cancelToken,
      );

      _streamSubscription = stream.listen(
        (sseEvent) {
          if (sseEvent is SseTokenEvent) {
            add(StreamTokenReceived(sseEvent.token));
          } else if (sseEvent is SseStatusEvent) {
            add(StreamStatusReceived(sseEvent.status, message: sseEvent.message));
          } else if (sseEvent is SseThinkingEvent) {
            add(StreamThinkingReceived(
              sseEvent.thought,
              elapsedSeconds: sseEvent.elapsedSeconds,
              step: sseEvent.step,
            ));
          } else if (sseEvent is SseSearchEvent) {
            add(StreamSearchReceived(sseEvent.query, sseEvent.results));
          } else if (sseEvent is SseUiEvent) {
            add(StreamUiReceived(sseEvent.type, sseEvent.props));
          } else if (sseEvent is SseCustomKeyMetaEvent) {
            add(StreamKeyMetaReceived(
              isByok: sseEvent.isByok,
              provider: sseEvent.provider,
              model: sseEvent.model,
            ));
          } else if (sseEvent is SseEndEvent) {
            add(StreamEndReceived(
              messageId: sseEvent.messageId,
              conversationId: sseEvent.conversationId ?? event.conversationId,
              metadata: sseEvent.metadata,
            ));
          } else if (sseEvent is SseErrorEvent) {
            add(StreamErrorReceived(sseEvent.errorCode, sseEvent.message));
          }
        },
        onError: (err) {
          if (err is DioException && CancelToken.isCancel(err)) {
            // Cancelled by user
            add(const StreamEndReceived());
          } else {
            add(StreamErrorReceived('NETWORK_ERROR', err.toString()));
          }
        },
        onDone: () {
          add(const StreamEndReceived());
        },
        cancelOnError: false,
      );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onStreamTokenReceived(
    StreamTokenReceived event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatLoaded) return;
    final s = state as ChatLoaded;
    if (s.messages.isEmpty) return;

    final updated = List<MessageEntity>.from(s.messages);
    final last = updated.last;
    if (last.role == 'assistant' && last.isStreaming) {
      updated[updated.length - 1] = last.copyWith(
        content: last.content + event.token,
      );
      emit(s.copyWith(messages: updated));
    }
  }

  void _onStreamStatusReceived(
    StreamStatusReceived event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatLoaded) return;
    final s = state as ChatLoaded;
    emit(s.copyWith(activeStatus: event.message ?? event.status));
  }

  void _onStreamThinkingReceived(
    StreamThinkingReceived event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatLoaded) return;
    final s = state as ChatLoaded;
    if (s.messages.isEmpty) return;

    final updated = List<MessageEntity>.from(s.messages);
    final last = updated.last;
    if (last.role == 'assistant') {
      final existingThinking = last.thinking ?? '';
      final newThinking = existingThinking.isEmpty ? event.thought : '$existingThinking\n${event.thought}';
      final steps = List<String>.from(last.thinkingSteps);
      if (event.step != null && !steps.contains(event.step)) {
        steps.add(event.step!);
      }

      updated[updated.length - 1] = last.copyWith(
        thinking: newThinking,
        elapsedSeconds: event.elapsedSeconds ?? last.elapsedSeconds,
        thinkingSteps: steps,
      );
      emit(s.copyWith(messages: updated));
    }
  }

  void _onStreamSearchReceived(
    StreamSearchReceived event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatLoaded) return;
    final s = state as ChatLoaded;
    if (s.messages.isEmpty) return;

    final updated = List<MessageEntity>.from(s.messages);
    final last = updated.last;
    if (last.role == 'assistant') {
      updated[updated.length - 1] = last.copyWith(
        citations: [...last.citations, ...event.results],
      );
      emit(s.copyWith(messages: updated));
    }
  }

  void _onStreamUiReceived(
    StreamUiReceived event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatLoaded) return;
    final s = state as ChatLoaded;
    if (s.messages.isEmpty) return;

    final updated = List<MessageEntity>.from(s.messages);
    final last = updated.last;
    if (last.role == 'assistant') {
      updated[updated.length - 1] = last.copyWith(
        uiPayload: {'type': event.type, 'props': event.propsMap},
      );
      emit(s.copyWith(messages: updated));
    }
  }

  void _onStreamKeyMetaReceived(
    StreamKeyMetaReceived event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatLoaded) return;
    final s = state as ChatLoaded;
    if (s.messages.isEmpty) return;

    final updated = List<MessageEntity>.from(s.messages);
    final last = updated.last;
    if (last.role == 'assistant') {
      updated[updated.length - 1] = last.copyWith(
        isByok: event.isByok,
        byokProvider: event.provider,
        byokModel: event.model,
      );
      emit(s.copyWith(messages: updated));
    }
  }

  Future<void> _onStreamEndReceived(
    StreamEndReceived event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;
    final s = state as ChatLoaded;
    if (s.messages.isEmpty) return;

    final updated = List<MessageEntity>.from(s.messages);
    final last = updated.last;
    if (last.role == 'assistant') {
      // Check for code/HTML/SVG artifacts in markdown content
      final artifact = MessageModel.fromJson({'content': last.content}).artifact;

      updated[updated.length - 1] = last.copyWith(
        isStreaming: false,
        artifact: artifact,
      );
    }

    emit(s.copyWith(
      messages: updated,
      isStreaming: false,
      clearActiveStatus: true,
    ));

    // If first message in conversation, trigger automatic title generation
    if (updated.length == 2 && event.conversationId != null) {
      try {
        await _conversationRepository.autoGenerateTitle(event.conversationId!);
      } catch (_) {}
    }
  }

  void _onStreamErrorReceived(
    StreamErrorReceived event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatLoaded) return;
    final s = state as ChatLoaded;
    final isQuota = event.errorCode.contains('QUOTA_EXCEEDED') ||
        event.errorMessage.toLowerCase().contains('quota');

    emit(s.copyWith(
      isStreaming: false,
      clearActiveStatus: true,
      errorMessage: event.errorMessage,
      isQuotaExceeded: isQuota,
    ));
  }

  Future<void> _onStopGeneration(
    StopGeneration event,
    Emitter<ChatState> emit,
  ) async {
    _cancelToken?.cancel('User requested stop');
    await _streamSubscription?.cancel();

    if (state is ChatLoaded) {
      final s = state as ChatLoaded;
      final updated = List<MessageEntity>.from(s.messages);
      if (updated.isNotEmpty && updated.last.role == 'assistant') {
        updated[updated.length - 1] = updated.last.copyWith(isStreaming: false);
      }
      emit(s.copyWith(messages: updated, isStreaming: false, clearActiveStatus: true));
    }
  }

  void _onRegenerateLastResponse(
    RegenerateLastResponse event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatLoaded) return;
    final s = state as ChatLoaded;
    if (s.messages.length < 2) return;

    // Find last user message
    final messages = List<MessageEntity>.from(s.messages);
    final lastMessage = messages.last;
    if (lastMessage.role == 'assistant') {
      messages.removeLast(); // Remove assistant response
    }
    final userMessage = messages.lastWhere((m) => m.role == 'user', orElse: () => messages.first);

    emit(s.copyWith(messages: messages));
    add(SendMessage(
      conversationId: event.conversationId,
      content: userMessage.content,
      model: event.model,
    ));
  }

  void _onToggleThinkingExpanded(
    ToggleThinkingExpanded event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatLoaded) return;
    final s = state as ChatLoaded;
    final set = Set<String>.from(s.expandedThinkingMessageIds);
    if (set.contains(event.messageId)) {
      set.remove(event.messageId);
    } else {
      set.add(event.messageId);
    }
    emit(s.copyWith(expandedThinkingMessageIds: set));
  }

  void _onClearChatError(
    ClearChatError event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatLoaded) {
      final s = state as ChatLoaded;
      emit(s.copyWith(clearErrorMessage: true, isQuotaExceeded: false));
    }
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    _cancelToken?.cancel();
    return super.close();
  }
}
