import '../entities/memory_entity.dart';

abstract class MemoryRepository {
  Future<List<MemoryEntity>> getMemories({String? category, String? query});
  Future<MemoryEntity> createMemory({required String content, required String category});
  Future<MemoryEntity> updateMemory({required String id, required String content, required String category});
  Future<void> deleteMemory(String id);
  Future<KnowledgeGraphEntity> getKnowledgeGraph();
}
