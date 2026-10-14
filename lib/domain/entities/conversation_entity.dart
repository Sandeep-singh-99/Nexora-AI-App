import 'package:equatable/equatable.dart';

class ConversationEntity extends Equatable {
  final String id;
  final String title;
  final String model;
  final bool isPinned;
  final bool isArchived;
  final String? documentName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ConversationEntity({
    required this.id,
    required this.title,
    required this.model,
    this.isPinned = false,
    this.isArchived = false,
    this.documentName,
    required this.createdAt,
    required this.updatedAt,
  });

  ConversationEntity copyWith({
    String? id,
    String? title,
    String? model,
    bool? isPinned,
    bool? isArchived,
    String? documentName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ConversationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      model: model ?? this.model,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      documentName: documentName ?? this.documentName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, title, model, isPinned, isArchived, documentName, createdAt, updatedAt];
}
