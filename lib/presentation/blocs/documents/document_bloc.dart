import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/document_entity.dart';
import '../../../domain/repositories/document_repository.dart';

abstract class DocumentEvent extends Equatable {
  const DocumentEvent();
  @override
  List<Object?> get props => [];
}

class LoadDocuments extends DocumentEvent {}

class UploadDocumentEvent extends DocumentEvent {
  final File file;
  final bool confirmSensitive;
  const UploadDocumentEvent({required this.file, this.confirmSensitive = false});
  @override
  List<Object?> get props => [file, confirmSensitive];
}

class DeleteDocumentEvent extends DocumentEvent {
  final String id;
  const DeleteDocumentEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class IngestYoutubeEvent extends DocumentEvent {
  final String url;
  const IngestYoutubeEvent(this.url);
  @override
  List<Object?> get props => [url];
}

class ClearSensitiveWarningEvent extends DocumentEvent {}

abstract class DocumentState extends Equatable {
  const DocumentState();
  @override
  List<Object?> get props => [];
}

class DocumentInitial extends DocumentState {}

class DocumentLoading extends DocumentState {}

class DocumentLoaded extends DocumentState {
  final List<DocumentEntity> documents;
  const DocumentLoaded(this.documents);
  @override
  List<Object?> get props => [documents];
}

class DocumentSensitiveWarningState extends DocumentState {
  final File file;
  final String message;
  final List<SensitiveFinding> findings;

  const DocumentSensitiveWarningState({
    required this.file,
    required this.message,
    required this.findings,
  });

  @override
  List<Object?> get props => [file, message, findings];
}

class DocumentError extends DocumentState {
  final String message;
  const DocumentError(this.message);
  @override
  List<Object?> get props => [message];
}

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final DocumentRepository _documentRepository;

  DocumentBloc(this._documentRepository) : super(DocumentInitial()) {
    on<LoadDocuments>(_onLoadDocuments);
    on<UploadDocumentEvent>(_onUploadDocument);
    on<DeleteDocumentEvent>(_onDeleteDocument);
    on<IngestYoutubeEvent>(_onIngestYoutube);
    on<ClearSensitiveWarningEvent>(_onClearSensitiveWarning);
  }

  Future<void> _onLoadDocuments(
    LoadDocuments event,
    Emitter<DocumentState> emit,
  ) async {
    emit(DocumentLoading());
    try {
      final docs = await _documentRepository.getDocuments();
      emit(DocumentLoaded(docs));
    } catch (e) {
      emit(DocumentError(e.toString()));
    }
  }

  Future<void> _onUploadDocument(
    UploadDocumentEvent event,
    Emitter<DocumentState> emit,
  ) async {
    final currentDocs = state is DocumentLoaded ? (state as DocumentLoaded).documents : <DocumentEntity>[];
    emit(DocumentLoading());

    try {
      final newDoc = await _documentRepository.uploadDocument(
        file: event.file,
        confirmSensitive: event.confirmSensitive,
      );
      emit(DocumentLoaded([newDoc, ...currentDocs]));
    } on SensitiveDataException catch (e) {
      final rawFindings = (e.piiDetails['findings'] as List?) ?? [];
      final findings = rawFindings
          .map((item) => SensitiveFinding.fromJson(item as Map<String, dynamic>))
          .toList();

      emit(DocumentSensitiveWarningState(
        file: event.file,
        message: e.message,
        findings: findings.isNotEmpty
            ? findings
            : [
                SensitiveFinding(
                  category: e.piiDetails['category'] ?? 'PII / Secrets Detected',
                  count: e.piiDetails['count'] ?? 1,
                  samples: (e.piiDetails['samples'] as List?)?.map((s) => s.toString()).toList() ?? [],
                ),
              ],
      ));
    } catch (e) {
      emit(DocumentError(e.toString()));
    }
  }

  Future<void> _onDeleteDocument(
    DeleteDocumentEvent event,
    Emitter<DocumentState> emit,
  ) async {
    if (state is DocumentLoaded) {
      final s = state as DocumentLoaded;
      try {
        await _documentRepository.deleteDocument(event.id);
        final updated = s.documents.where((d) => d.id != event.id).toList();
        emit(DocumentLoaded(updated));
      } catch (e) {
        emit(DocumentError(e.toString()));
      }
    }
  }

  Future<void> _onIngestYoutube(
    IngestYoutubeEvent event,
    Emitter<DocumentState> emit,
  ) async {
    emit(DocumentLoading());
    try {
      await _documentRepository.ingestYoutube(event.url);
      final docs = await _documentRepository.getDocuments();
      emit(DocumentLoaded(docs));
    } catch (e) {
      emit(DocumentError(e.toString()));
    }
  }

  void _onClearSensitiveWarning(
    ClearSensitiveWarningEvent event,
    Emitter<DocumentState> emit,
  ) {
    add(LoadDocuments());
  }
}
