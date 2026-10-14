import '../../domain/entities/document_entity.dart';

class DocumentModel extends DocumentEntity {
  const DocumentModel({
    required super.id,
    required super.name,
    required super.fileType,
    required super.sizeBytes,
    required super.chunksCount,
    super.isProcessed,
    required super.createdAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String? ?? json['document_id'] as String? ?? '',
      name: json['name'] as String? ?? json['filename'] as String? ?? 'Untitled',
      fileType: json['file_type'] as String? ?? 'pdf',
      sizeBytes: json['size_bytes'] as int? ?? json['size'] as int? ?? 0,
      chunksCount: json['chunks_count'] as int? ?? 0,
      isProcessed: json['is_processed'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'file_type': fileType,
      'size_bytes': sizeBytes,
      'chunks_count': chunksCount,
      'is_processed': isProcessed,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
