import 'dart:io';
import '../entities/document_entity.dart';

abstract class DocumentRepository {
  Future<List<DocumentEntity>> getDocuments();
  Future<DocumentEntity> uploadDocument({
    required File file,
    bool confirmSensitive = false,
  });
  Future<void> deleteDocument(String id);
  Future<void> ingestYoutube(String url);
  Future<String> queryDocument({required String documentId, required String query});
}
