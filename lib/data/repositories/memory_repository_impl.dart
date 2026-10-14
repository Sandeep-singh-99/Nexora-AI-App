import '../../domain/entities/memory_entity.dart';
import '../../domain/repositories/memory_repository.dart';
import '../datasources/remote_datasource.dart';

class MemoryRepositoryImpl implements MemoryRepository {
  final RemoteDataSource _remoteDataSource;

  MemoryRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<MemoryEntity>> getMemories({String? category, String? query}) {
    return _remoteDataSource.getMemories(category: category, query: query);
  }

  @override
  Future<MemoryEntity> createMemory({required String content, required String category}) {
    return _remoteDataSource.createMemory(content: content, category: category);
  }

  @override
  Future<MemoryEntity> updateMemory({required String id, required String content, required String category}) {
    return _remoteDataSource.updateMemory(id: id, content: content, category: category);
  }

  @override
  Future<void> deleteMemory(String id) {
    return _remoteDataSource.deleteMemory(id);
  }

  @override
  Future<KnowledgeGraphEntity> getKnowledgeGraph() {
    return _remoteDataSource.getKnowledgeGraph();
  }
}
