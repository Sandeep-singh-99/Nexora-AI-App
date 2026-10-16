import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/conversation_repository.dart';
import 'conversation_event.dart';
import 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final ConversationRepository _conversationRepository;

  ConversationBloc(this._conversationRepository) : super(ConversationInitial()) {
    on<LoadConversations>(_onLoadConversations);
    on<ResetToNewChat>(_onResetToNewChat);
    on<SelectConversation>(_onSelectConversation);
    on<CreateConversation>(_onCreateConversation);
    on<UpdateConversationDetails>(_onUpdateConversationDetails);
    on<DeleteConversationEvent>(_onDeleteConversation);
    on<BulkDeleteConversationsEvent>(_onBulkDeleteConversations);
    on<SearchConversations>(_onSearchConversations);
    on<AutoGenerateTitleEvent>(_onAutoGenerateTitle);
  }

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ConversationState> emit,
  ) async {
    final currentSelectedId = state is ConversationLoaded
        ? (state as ConversationLoaded).selectedConversationId
        : null;

    if (state is! ConversationLoaded) {
      emit(ConversationLoading());
    }

    try {
      final list = await _conversationRepository.getConversations();
      final targetSelectedId = (currentSelectedId != null && list.any((c) => c.id == currentSelectedId))
          ? currentSelectedId
          : (list.isNotEmpty ? list.first.id : null);

      emit(ConversationLoaded(
        allConversations: list,
        selectedConversationId: targetSelectedId,
      ));
    } catch (e) {
      if (state is! ConversationLoaded) {
        emit(ConversationError(e.toString()));
      }
    }
  }

  void _onResetToNewChat(
    ResetToNewChat event,
    Emitter<ConversationState> emit,
  ) {
    if (state is ConversationLoaded) {
      final s = state as ConversationLoaded;
      emit(s.copyWith(clearSelectedId: true));
    }
  }

  void _onSelectConversation(
    SelectConversation event,
    Emitter<ConversationState> emit,
  ) {
    if (state is ConversationLoaded) {
      final s = state as ConversationLoaded;
      emit(s.copyWith(selectedConversationId: event.id));
    }
  }

  Future<void> _onCreateConversation(
    CreateConversation event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      final newConv = await _conversationRepository.createConversation(
        title: event.title,
        message: event.initialMessage,
        model: event.model,
        documentName: event.documentName,
      );

      if (state is ConversationLoaded) {
        final s = state as ConversationLoaded;
        final updatedList = [newConv, ...s.allConversations.where((c) => c.id != newConv.id)];
        emit(s.copyWith(
          allConversations: updatedList,
          selectedConversationId: newConv.id,
        ));
      } else {
        emit(ConversationLoaded(
          allConversations: [newConv],
          selectedConversationId: newConv.id,
        ));
      }
      event.completer?.complete(newConv);
    } catch (e) {
      event.completer?.completeError(e);
      emit(ConversationError(e.toString()));
    }
  }

  Future<void> _onUpdateConversationDetails(
    UpdateConversationDetails event,
    Emitter<ConversationState> emit,
  ) async {
    if (state is ConversationLoaded) {
      final s = state as ConversationLoaded;
      try {
        final updated = await _conversationRepository.updateConversation(
          id: event.id,
          title: event.title,
          isPinned: event.isPinned,
          isArchived: event.isArchived,
          model: event.model,
        );
        final list = s.allConversations.map((c) => c.id == event.id ? updated : c).toList();
        emit(s.copyWith(allConversations: list));
      } catch (_) {}
    }
  }

  Future<void> _onDeleteConversation(
    DeleteConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    if (state is ConversationLoaded) {
      final s = state as ConversationLoaded;
      try {
        await _conversationRepository.deleteConversation(event.id);
        final list = s.allConversations.where((c) => c.id != event.id).toList();
        final newSelectedId = s.selectedConversationId == event.id
            ? (list.isNotEmpty ? list.first.id : null)
            : s.selectedConversationId;

        emit(s.copyWith(
          allConversations: list,
          selectedConversationId: newSelectedId,
        ));
      } catch (_) {}
    }
  }

  Future<void> _onBulkDeleteConversations(
    BulkDeleteConversationsEvent event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      await _conversationRepository.bulkDeleteConversations();
      emit(const ConversationLoaded(allConversations: [], selectedConversationId: null));
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  void _onSearchConversations(
    SearchConversations event,
    Emitter<ConversationState> emit,
  ) {
    if (state is ConversationLoaded) {
      final s = state as ConversationLoaded;
      emit(s.copyWith(searchQuery: event.query));
    }
  }

  Future<void> _onAutoGenerateTitle(
    AutoGenerateTitleEvent event,
    Emitter<ConversationState> emit,
  ) async {
    if (state is ConversationLoaded) {
      final s = state as ConversationLoaded;
      try {
        final newTitle = await _conversationRepository.autoGenerateTitle(
          event.conversationId,
          message: event.message,
          assistantResponse: event.assistantResponse,
          documentName: event.documentName,
        );
        final list = s.allConversations.map((c) {
          if (c.id == event.conversationId) {
            return c.copyWith(title: newTitle);
          }
          return c;
        }).toList();
        emit(s.copyWith(allConversations: list));
      } catch (_) {}
    }
  }
}
