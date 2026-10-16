import 'package:equatable/equatable.dart';
import '../../../core/network/sse_stream_reader.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadMessages extends ChatEvent {
  final String conversationId;
  const LoadMessages(this.conversationId);
  @override
  List<Object?> get props => [conversationId];
}

class SendMessage extends ChatEvent {
  final String conversationId;
  final String content;
  final String model;
  final String? documentId;

  const SendMessage({
    required this.conversationId,
    required this.content,
    required this.model,
    this.documentId,
  });

  @override
  List<Object?> get props => [conversationId, content, model, documentId];
}

class StopGeneration extends ChatEvent {}

class RegenerateLastResponse extends ChatEvent {
  final String conversationId;
  final String model;
  const RegenerateLastResponse({required this.conversationId, required this.model});
  @override
  List<Object?> get props => [conversationId, model];
}

class ToggleThinkingExpanded extends ChatEvent {
  final String messageId;
  const ToggleThinkingExpanded(this.messageId);
  @override
  List<Object?> get props => [messageId];
}

class ClearChatError extends ChatEvent {}

// Stream events dispatched from SSE subscription
class StreamTokenReceived extends ChatEvent {
  final String token;
  const StreamTokenReceived(this.token);
  @override
  List<Object?> get props => [token];
}

class StreamStatusReceived extends ChatEvent {
  final String status;
  final String? message;
  const StreamStatusReceived(this.status, {this.message});
  @override
  List<Object?> get props => [status, message];
}

class StreamThinkingReceived extends ChatEvent {
  final String thought;
  final int? elapsedSeconds;
  final String? step;
  const StreamThinkingReceived(this.thought, {this.elapsedSeconds, this.step});
  @override
  List<Object?> get props => [thought, elapsedSeconds, step];
}

class StreamSearchReceived extends ChatEvent {
  final String query;
  final List<SearchCitation> results;
  const StreamSearchReceived(this.query, this.results);
  @override
  List<Object?> get props => [query, results];
}

class StreamUiReceived extends ChatEvent {
  final String type;
  final Map<String, dynamic> propsMap;
  const StreamUiReceived(this.type, this.propsMap);
  @override
  List<Object?> get props => [type, propsMap];
}

class StreamKeyMetaReceived extends ChatEvent {
  final bool isByok;
  final String? provider;
  final String? model;
  const StreamKeyMetaReceived({required this.isByok, this.provider, this.model});
  @override
  List<Object?> get props => [isByok, provider, model];
}

class StreamEndReceived extends ChatEvent {
  final String? messageId;
  final String? conversationId;
  final Map<String, dynamic>? metadata;
  const StreamEndReceived({this.messageId, this.conversationId, this.metadata});
  @override
  List<Object?> get props => [messageId, conversationId, metadata];
}

class StreamErrorReceived extends ChatEvent {
  final String errorCode;
  final String errorMessage;
  const StreamErrorReceived(this.errorCode, this.errorMessage);
  @override
  List<Object?> get props => [errorCode, errorMessage];
}

class ResetChat extends ChatEvent {
  const ResetChat();
}
