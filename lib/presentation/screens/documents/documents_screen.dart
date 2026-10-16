import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../blocs/documents/document_bloc.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import 'guardrails_dialog.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DocumentBloc>().add(LoadDocuments());
  }

  Future<void> _pickAndUploadFile() async {
    HapticUtils.lightImpact();
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt', 'md'],
    );

    if (result.isNotEmpty && result.first.path != null) {
      final file = File(result.first.path!);
      if (mounted) {
        context.read<DocumentBloc>().add(
              UploadDocumentEvent(file: file, confirmSensitive: false),
            );
      }
    }
  }

  void _showYouTubeIngestModal(AppColors colors) {
    final urlController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetCtx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(bottomSheetCtx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.video_library_outlined, color: colors.textPrimary),
                  const SizedBox(width: 8),
                  Text(
                    'Ingest YouTube Video',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.textMuted, size: 20),
                    onPressed: () => Navigator.of(bottomSheetCtx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Extract transcripts and index content into your RAG knowledge base.',
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: urlController,
                hintText: 'https://www.youtube.com/watch?v=...',
                keyboardType: TextInputType.url,
                prefixIcon: Icon(Icons.link, size: 18, color: colors.textMuted),
              ),
              const SizedBox(height: 20),
              AppButton(
                text: 'Ingest Transcript',
                onPressed: () {
                  final url = urlController.text.trim();
                  if (url.isNotEmpty) {
                    Navigator.of(bottomSheetCtx).pop();
                    context.read<DocumentBloc>().add(IngestYoutubeEvent(url));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Knowledge Documents (RAG)',
          style: TextStyle(color: colors.textPrimary),
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
        actions: [
          IconButton(
            icon: Icon(Icons.video_call_outlined, color: colors.textSecondary),
            tooltip: 'Ingest YouTube',
            onPressed: () => _showYouTubeIngestModal(colors),
          ),
          IconButton(
            icon: Icon(Icons.upload_file_outlined, color: colors.textSecondary),
            tooltip: 'Upload Document',
            onPressed: _pickAndUploadFile,
          ),
        ],
      ),
      body: BlocConsumer<DocumentBloc, DocumentState>(
        listener: (context, state) {
          if (state is DocumentSensitiveWarningState) {
            GuardrailsDialog.show(
              context: context,
              file: state.file,
              message: state.message,
              findings: state.findings,
              onProceedAnyway: () {
                context.read<DocumentBloc>().add(
                      UploadDocumentEvent(
                        file: state.file,
                        confirmSensitive: true,
                      ),
                    );
              },
            );
          } else if (state is DocumentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DocumentLoading) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              ),
            );
          }

          if (state is DocumentLoaded) {
            final docs = state.documents;
            if (docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: colors.border),
                      ),
                      child: Icon(Icons.folder_open, size: 48, color: colors.textMuted),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Knowledge Documents',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Upload PDF, DOCX or YouTube transcripts for RAG query context.',
                      style: TextStyle(color: colors.textSecondary, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppButton(
                          text: 'Upload File',
                          icon: Icon(Icons.upload_file, size: 16, color: colors.onPrimary),
                          onPressed: _pickAndUploadFile,
                        ),
                        const SizedBox(width: 12),
                        AppButton(
                          text: 'YouTube Ingest',
                          variant: ButtonVariant.secondary,
                          icon: Icon(Icons.video_library, size: 16, color: colors.textPrimary),
                          onPressed: () => _showYouTubeIngestModal(colors),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final doc = docs[index];
                final sizeKb = (doc.sizeBytes / 1024).toStringAsFixed(1);

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colors.border),
                        ),
                        child: Icon(
                          doc.fileType.toLowerCase().contains('pdf')
                              ? Icons.picture_as_pdf
                              : Icons.description,
                          color: colors.textPrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.name,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${doc.chunksCount} chunks • ${sizeKb}KB • ${DateHelpers.formatShortDate(doc.createdAt)}',
                              style: TextStyle(color: colors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: colors.textMuted, size: 20),
                        onPressed: () {
                          HapticUtils.lightImpact();
                          context.read<DocumentBloc>().add(DeleteDocumentEvent(doc.id));
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
