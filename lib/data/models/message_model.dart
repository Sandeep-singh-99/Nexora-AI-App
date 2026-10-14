import '../../core/network/sse_stream_reader.dart';
import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.role,
    required super.content,
    super.thinking,
    super.elapsedSeconds,
    super.thinkingSteps,
    super.status,
    super.citations,
    super.uiPayload,
    super.isByok,
    super.byokProvider,
    super.byokModel,
    super.isStreaming,
    super.artifact,
    required super.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final citationsList = (json['citations'] as List?)
            ?.map((e) => SearchCitation.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final thinkingStepsList = (json['thinking_steps'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final content = json['content'] as String? ?? '';
    final artifact = _extractArtifact(content);

    return MessageModel(
      id: json['id'] as String? ?? UniqueKeyString.generate(),
      conversationId: json['conversation_id'] as String? ?? '',
      role: json['role'] as String? ?? 'assistant',
      content: content,
      thinking: json['thinking'] as String?,
      elapsedSeconds: json['elapsed_seconds'] as int?,
      thinkingSteps: thinkingStepsList,
      status: json['status'] as String?,
      citations: citationsList,
      uiPayload: json['ui'] as Map<String, dynamic>?,
      isByok: json['is_byok'] as bool? ?? false,
      byokProvider: json['byok_provider'] as String?,
      byokModel: json['byok_model'] as String?,
      isStreaming: json['is_streaming'] as bool? ?? false,
      artifact: artifact,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'role': role,
      'content': content,
      'thinking': thinking,
      'elapsed_seconds': elapsedSeconds,
      'thinking_steps': thinkingSteps,
      'status': status,
      'citations': citations
          .map((c) => {
                'title': c.title,
                'url': c.url,
                'snippet': c.snippet,
                'favicon': c.favicon,
              })
          .toList(),
      'ui': uiPayload,
      'is_byok': isByok,
      'byok_provider': byokProvider,
      'byok_model': byokModel,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static ArtifactMetadata? _extractArtifact(String markdown) {
    // Detect html, svg, or large code blocks
    final codeBlockRegex = RegExp(r'```([a-zA-Z0-9_-]+)?\n([\s\S]*?)```');
    final match = codeBlockRegex.firstMatch(markdown);
    if (match != null) {
      final lang = (match.group(1) ?? 'code').toLowerCase();
      final code = match.group(2) ?? '';
      if (lang == 'html' || lang == 'svg' || lang == 'python' || lang == 'javascript' || lang == 'dart' || lang == 'jsx' || lang == 'tsx') {
        return ArtifactMetadata(
          title: '${lang.toUpperCase()} Artifact',
          language: lang,
          content: code,
        );
      }
    }
    return null;
  }
}

class UniqueKeyString {
  static int _counter = 0;
  static String generate() {
    _counter++;
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_$_counter';
  }
}
