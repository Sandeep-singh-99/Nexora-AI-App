import 'package:equatable/equatable.dart';

class MemoryEntity extends Equatable {
  final String id;
  final String content;
  final String category;
  final DateTime createdAt;

  const MemoryEntity({
    required this.id,
    required this.content,
    required this.category,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, content, category, createdAt];
}

class GraphNode extends Equatable {
  final String id;
  final String label;
  final String type; // entity, topic, person, tool

  const GraphNode({
    required this.id,
    required this.label,
    required this.type,
  });

  @override
  List<Object?> get props => [id, label, type];
}

class GraphEdge extends Equatable {
  final String sourceId;
  final String targetId;
  final String relationship;

  const GraphEdge({
    required this.sourceId,
    required this.targetId,
    required this.relationship,
  });

  @override
  List<Object?> get props => [sourceId, targetId, relationship];
}

class KnowledgeGraphEntity extends Equatable {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;

  const KnowledgeGraphEntity({
    required this.nodes,
    required this.edges,
  });

  @override
  List<Object?> get props => [nodes, edges];
}
