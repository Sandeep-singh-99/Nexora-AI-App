import 'dart:io';
import '../../domain/entities/document_entity.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/remote_datasource.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final RemoteDataSource _remoteDataSource;

  DocumentRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<DocumentEntity>> getDocuments() {
    return _remoteDataSource.getDocuments();
  }

  @override
  Future<DocumentEntity> uploadDocument({
    required File file,
    bool confirmSensitive = false,
  }) {
    return _remoteDataSource.uploadDocument(
      file: file,
      confirmSensitive: confirmSensitive,
    );
  }

  @override
  Future<void> deleteDocument(String id) {
    return _remoteDataSource.deleteDocument(id);
  }

  @override
  Future<void> ingestYoutube(String url) {
    return _remoteDataSource.ingestYoutube(url);
  }

  @override
  Future<String> queryDocument({required String documentId, required String query}) {
    return _remoteDataSource.queryDocument(documentId: documentId, query: query);
  }
}
