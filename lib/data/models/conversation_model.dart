import '../../domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.title,
    required super.model,
    super.isPinned,
    super.isArchived,
    super.documentName,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String? ?? json['conversation_id'] as String? ?? '',
      title: json['title'] as String? ?? 'New Chat',
      model: json['model'] as String? ?? 'gemini-2.0-flash',
      isPinned: json['is_pinned'] as bool? ?? false,
      isArchived: json['is_archived'] as bool? ?? false,
      documentName: json['document_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'model': model,
      'is_pinned': isPinned,
      'is_archived': isArchived,
      'document_name': documentName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
