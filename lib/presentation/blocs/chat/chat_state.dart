import 'package:equatable/equatable.dart';
import '../../../domain/entities/message_entity.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<MessageEntity> messages;
  final bool isStreaming;
  final String? activeStatus;
  final String? errorMessage;
  final bool isQuotaExceeded;
  final Set<String> expandedThinkingMessageIds;

  const ChatLoaded({
    required this.messages,
    this.isStreaming = false,
    this.activeStatus,
    this.errorMessage,
    this.isQuotaExceeded = false,
    this.expandedThinkingMessageIds = const {},
  });

  bool isThinkingExpanded(String messageId) => expandedThinkingMessageIds.contains(messageId);

  ChatLoaded copyWith({
    List<MessageEntity>? messages,
    bool? isStreaming,
    String? activeStatus,
    String? errorMessage,
    bool? isQuotaExceeded,
    Set<String>? expandedThinkingMessageIds,
    bool clearActiveStatus = false,
    bool clearErrorMessage = false,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      activeStatus: clearActiveStatus ? null : (activeStatus ?? this.activeStatus),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      isQuotaExceeded: isQuotaExceeded ?? this.isQuotaExceeded,
      expandedThinkingMessageIds: expandedThinkingMessageIds ?? this.expandedThinkingMessageIds,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        isStreaming,
        activeStatus,
        errorMessage,
        isQuotaExceeded,
        expandedThinkingMessageIds,
      ];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object?> get props => [message];
}
