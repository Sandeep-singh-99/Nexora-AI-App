import '../../domain/entities/memory_entity.dart';

class MemoryModel extends MemoryEntity {
  const MemoryModel({
    required super.id,
    required super.content,
    required super.category,
    required super.createdAt,
  });

  factory MemoryModel.fromJson(Map<String, dynamic> json) {
    return MemoryModel(
      id: json['id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class KnowledgeGraphModel extends KnowledgeGraphEntity {
  const KnowledgeGraphModel({
    required super.nodes,
    required super.edges,
  });

  factory KnowledgeGraphModel.fromJson(Map<String, dynamic> json) {
    final rawNodes = (json['nodes'] as List?) ?? [];
    final rawEdges = (json['edges'] as List?) ?? [];

    final nodes = rawNodes.map((n) {
      final map = n as Map<String, dynamic>;
      return GraphNode(
        id: map['id'] as String? ?? '',
        label: map['label'] as String? ?? map['name'] as String? ?? '',
        type: map['type'] as String? ?? 'entity',
      );
    }).toList();

    final edges = rawEdges.map((e) {
      final map = e as Map<String, dynamic>;
      return GraphEdge(
        sourceId: map['source'] as String? ?? map['source_id'] as String? ?? '',
        targetId: map['target'] as String? ?? map['target_id'] as String? ?? '',
        relationship: map['relationship'] as String? ?? map['label'] as String? ?? 'relates_to',
      );
    }).toList();

    return KnowledgeGraphModel(nodes: nodes, edges: edges);
  }
}
