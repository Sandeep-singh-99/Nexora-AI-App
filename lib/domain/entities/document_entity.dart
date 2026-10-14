import 'package:equatable/equatable.dart';

class SensitiveFinding extends Equatable {
  final String category; // e.g. Credit Card, SSN, API Key
  final int count;
  final List<String> samples;

  const SensitiveFinding({
    required this.category,
    required this.count,
    this.samples = const [],
  });

  factory SensitiveFinding.fromJson(Map<String, dynamic> json) {
    return SensitiveFinding(
      category: json['category'] as String? ?? 'Sensitive Data',
      count: json['count'] as int? ?? 1,
      samples: (json['samples'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [category, count, samples];
}

class DocumentEntity extends Equatable {
  final String id;
  final String name;
  final String fileType;
  final int sizeBytes;
  final int chunksCount;
  final bool isProcessed;
  final DateTime createdAt;

  const DocumentEntity({
    required this.id,
    required this.name,
    required this.fileType,
    required this.sizeBytes,
    required this.chunksCount,
    this.isProcessed = true,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, fileType, sizeBytes, chunksCount, isProcessed, createdAt];
}
