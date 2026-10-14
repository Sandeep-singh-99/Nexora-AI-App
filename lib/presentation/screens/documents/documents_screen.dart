import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/color_palette.dart';
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

  void _showYouTubeIngestModal() {
    final urlController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorPalette.elevatedSurface,
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
                  const Icon(Icons.video_library_outlined, color: ColorPalette.roseAccent),
                  const SizedBox(width: 8),
                  const Text(
                    'Ingest YouTube Video',
                    style: TextStyle(
                      color: ColorPalette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: ColorPalette.textMuted, size: 20),
                    onPressed: () => Navigator.of(bottomSheetCtx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Extract transcripts and index content into your RAG knowledge base.',
                style: TextStyle(color: ColorPalette.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: urlController,
                hintText: 'https://www.youtube.com/watch?v=...',
                keyboardType: TextInputType.url,
                prefixIcon: const Icon(Icons.link, size: 18, color: ColorPalette.textMuted),
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
    return Scaffold(
      backgroundColor: ColorPalette.obsidianBackground,
      appBar: AppBar(
        title: const Text('Knowledge Documents (RAG)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call_outlined, color: ColorPalette.roseAccent),
            tooltip: 'Ingest YouTube',
            onPressed: _showYouTubeIngestModal,
          ),
          IconButton(
            icon: const Icon(Icons.upload_file_outlined, color: ColorPalette.indigoAccent),
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
                backgroundColor: ColorPalette.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DocumentLoading) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.indigoAccent),
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
                        color: ColorPalette.elevatedSurface,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.folder_open, size: 48, color: ColorPalette.textMuted),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Knowledge Documents',
                      style: TextStyle(
                        color: ColorPalette.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Upload PDF, DOCX or YouTube transcripts for RAG query context.',
                      style: TextStyle(color: ColorPalette.textSecondary, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppButton(
                          text: 'Upload File',
                          icon: const Icon(Icons.upload_file, size: 16, color: Colors.white),
                          onPressed: _pickAndUploadFile,
                        ),
                        const SizedBox(width: 12),
                        AppButton(
                          text: 'YouTube Ingest',
                          variant: ButtonVariant.secondary,
                          icon: const Icon(Icons.video_library, size: 16, color: ColorPalette.roseAccent),
                          onPressed: _showYouTubeIngestModal,
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
                    color: ColorPalette.elevatedSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: ColorPalette.subtleBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ColorPalette.indigoAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          doc.fileType.toLowerCase().contains('pdf')
                              ? Icons.picture_as_pdf
                              : Icons.description,
                          color: ColorPalette.indigoAccent,
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
                              style: const TextStyle(
                                color: ColorPalette.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${doc.chunksCount} chunks • ${sizeKb}KB • ${DateHelpers.formatShortDate(doc.createdAt)}',
                              style: const TextStyle(color: ColorPalette.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: ColorPalette.textMuted, size: 20),
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
