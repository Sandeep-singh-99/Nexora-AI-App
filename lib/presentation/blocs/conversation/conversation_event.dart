import 'dart:async';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/conversation_entity.dart';

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();
  @override
  List<Object?> get props => [];
}

class LoadConversations extends ConversationEvent {
  final bool autoSelectLatest;
  const LoadConversations({this.autoSelectLatest = false});

  @override
  List<Object?> get props => [autoSelectLatest];
}

class ResetToNewChat extends ConversationEvent {}

class SelectConversation extends ConversationEvent {
  final String id;
  const SelectConversation(this.id);
  @override
  List<Object?> get props => [id];
}

class CreateConversation extends ConversationEvent {
  final String title;
  final String? initialMessage;
  final String model;
  final String? documentName;
  final Completer<ConversationEntity>? completer;

  const CreateConversation({
    this.title = 'New Chat',
    this.initialMessage,
    required this.model,
    this.documentName,
    this.completer,
  });

  @override
  List<Object?> get props => [title, initialMessage, model, documentName, completer];
}

class UpdateConversationDetails extends ConversationEvent {
  final String id;
  final String? title;
  final bool? isPinned;
  final bool? isArchived;
  final String? model;

  const UpdateConversationDetails({
    required this.id,
    this.title,
    this.isPinned,
    this.isArchived,
    this.model,
  });

  @override
  List<Object?> get props => [id, title, isPinned, isArchived, model];
}

class DeleteConversationEvent extends ConversationEvent {
  final String id;
  const DeleteConversationEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class BulkDeleteConversationsEvent extends ConversationEvent {}

class SearchConversations extends ConversationEvent {
  final String query;
  const SearchConversations(this.query);
  @override
  List<Object?> get props => [query];
}

class AutoGenerateTitleEvent extends ConversationEvent {
  final String conversationId;
  final String? message;
  final String? assistantResponse;
  final String? documentName;

  const AutoGenerateTitleEvent(
    this.conversationId, {
    this.message,
    this.assistantResponse,
    this.documentName,
  });

  @override
  List<Object?> get props => [conversationId, message, assistantResponse, documentName];
}
