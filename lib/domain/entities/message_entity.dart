import 'package:equatable/equatable.dart';
import '../../core/network/sse_stream_reader.dart';

class ArtifactMetadata extends Equatable {
  final String title;
  final String language; // html, svg, code, python, etc.
  final String content;

  const ArtifactMetadata({
    required this.title,
    required this.language,
    required this.content,
  });

  @override
  List<Object?> get props => [title, language, content];
}

class MessageEntity extends Equatable {
  final String id;
  final String conversationId;
  final String role; // 'user', 'assistant', 'system'
  final String content;
  final String? thinking;
  final int? elapsedSeconds;
  final List<String> thinkingSteps;
  final String? status;
  final List<SearchCitation> citations;
  final Map<String, dynamic>? uiPayload;
  final bool isByok;
  final String? byokProvider;
  final String? byokModel;
  final bool isStreaming;
  final ArtifactMetadata? artifact;
  final DateTime createdAt;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.thinking,
    this.elapsedSeconds,
    this.thinkingSteps = const [],
    this.status,
    this.citations = const [],
    this.uiPayload,
    this.isByok = false,
    this.byokProvider,
    this.byokModel,
    this.isStreaming = false,
    this.artifact,
    required this.createdAt,
  });

  MessageEntity copyWith({
    String? id,
    String? conversationId,
    String? role,
    String? content,
    String? thinking,
    int? elapsedSeconds,
    List<String>? thinkingSteps,
    String? status,
    List<SearchCitation>? citations,
    Map<String, dynamic>? uiPayload,
    bool? isByok,
    String? byokProvider,
    String? byokModel,
    bool? isStreaming,
    ArtifactMetadata? artifact,
    DateTime? createdAt,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      thinking: thinking ?? this.thinking,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      thinkingSteps: thinkingSteps ?? this.thinkingSteps,
      status: status ?? this.status,
      citations: citations ?? this.citations,
      uiPayload: uiPayload ?? this.uiPayload,
      isByok: isByok ?? this.isByok,
      byokProvider: byokProvider ?? this.byokProvider,
      byokModel: byokModel ?? this.byokModel,
      isStreaming: isStreaming ?? this.isStreaming,
      artifact: artifact ?? this.artifact,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        role,
        content,
        thinking,
        elapsedSeconds,
        thinkingSteps,
        status,
        citations,
        uiPayload,
        isByok,
        byokProvider,
        byokModel,
        isStreaming,
        artifact,
        createdAt,
      ];
}
