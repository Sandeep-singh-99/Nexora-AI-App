import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nexora_ai_app/app/theme/app_colors.dart';
import 'package:nexora_ai_app/core/utils/haptic_utils.dart';
import 'package:nexora_ai_app/domain/entities/message_entity.dart';
import 'package:nexora_ai_app/presentation/blocs/artifacts/artifact_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArtifactViewerModal extends StatefulWidget {
  final ArtifactMetadata artifact;

  const ArtifactViewerModal({super.key, required this.artifact});

  static void show(BuildContext context, ArtifactMetadata artifact) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ArtifactBloc>()..add(OpenArtifactEvent(artifact)),
        child: ArtifactViewerModal(artifact: artifact),
      ),
    );
  }

  @override
  State<ArtifactViewerModal> createState() => _ArtifactViewerModalState();
}

class _ArtifactViewerModalState extends State<ArtifactViewerModal> {
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    if (widget.artifact.language == 'html') {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..loadHtmlString(widget.artifact.content);
    }
  }

  void _copyContent(AppColors colors) {
    HapticUtils.heavyImpact();
    Clipboard.setData(ClipboardData(text: widget.artifact.content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Artifact source copied to clipboard!'),
        backgroundColor: colors.cardHover,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<ArtifactBloc, ArtifactState>(
      builder: (context, state) {
        if (state is! ArtifactOpen) return const SizedBox.shrink();

        final activeTab = state.activeTab;
        final viewport = state.activeViewport;

        double getViewportWidth() {
          switch (viewport) {
            case ArtifactViewport.mobile:
              return 375;
            case ArtifactViewport.desktop:
              return 900;
            case ArtifactViewport.responsive:
              return double.infinity;
          }
        }

        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: colors.border)),
          ),
          child: Column(
            children: [
              // Modal Grab handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.border),
                      ),
                      child: Icon(Icons.code, size: 18, color: colors.textPrimary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.artifact.title,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            widget.artifact.language.toUpperCase(),
                            style: TextStyle(color: colors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy, size: 18, color: colors.textSecondary),
                      tooltip: 'Copy Code',
                      onPressed: () => _copyContent(colors),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 20, color: colors.textMuted),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Mode Tabs & Viewport Selector Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: colors.surface,
                child: Row(
                  children: [
                    // Preview / Code toggle
                    SegmentedButton<ArtifactTab>(
                      segments: const [
                        ButtonSegment(
                          value: ArtifactTab.preview,
                          label: Text('Preview', style: TextStyle(fontSize: 12)),
                          icon: Icon(Icons.visibility_outlined, size: 14),
                        ),
                        ButtonSegment(
                          value: ArtifactTab.code,
                          label: Text('Code', style: TextStyle(fontSize: 12)),
                          icon: Icon(Icons.code, size: 14),
                        ),
                      ],
                      selected: {activeTab},
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: colors.primary,
                        selectedForegroundColor: colors.onPrimary,
                        foregroundColor: colors.textSecondary,
                        backgroundColor: colors.card,
                      ),
                      onSelectionChanged: (val) {
                        HapticUtils.selectionClick();
                        context.read<ArtifactBloc>().add(ChangeArtifactTabEvent(val.first));
                      },
                    ),

                    const Spacer(),

                    // Viewport selector (Mobile / Responsive / Desktop)
                    if (activeTab == ArtifactTab.preview) ...[
                      IconButton(
                        icon: Icon(
                          Icons.smartphone,
                          size: 18,
                          color: viewport == ArtifactViewport.mobile
                              ? colors.primary
                              : colors.textMuted,
                        ),
                        tooltip: 'Mobile Viewport',
                        onPressed: () {
                          HapticUtils.selectionClick();
                          context.read<ArtifactBloc>().add(
                                const ChangeArtifactViewportEvent(ArtifactViewport.mobile),
                              );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.aspect_ratio,
                          size: 18,
                          color: viewport == ArtifactViewport.responsive
                              ? colors.primary
                              : colors.textMuted,
                        ),
                        tooltip: 'Responsive Viewport',
                        onPressed: () {
                          HapticUtils.selectionClick();
                          context.read<ArtifactBloc>().add(
                                const ChangeArtifactViewportEvent(ArtifactViewport.responsive),
                              );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.desktop_windows,
                          size: 18,
                          color: viewport == ArtifactViewport.desktop
                              ? colors.primary
                              : colors.textMuted,
                        ),
                        tooltip: 'Desktop Viewport',
                        onPressed: () {
                          HapticUtils.selectionClick();
                          context.read<ArtifactBloc>().add(
                                const ChangeArtifactViewportEvent(ArtifactViewport.desktop),
                              );
                        },
                      ),
                    ],
                  ],
                ),
              ),

              Divider(height: 1, color: colors.border),

              // Main Canvas
              Expanded(
                child: activeTab == ArtifactTab.code
                    ? _buildCodeView(colors)
                    : _buildPreview(getViewportWidth(), colors),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCodeView(AppColors colors) {
    return Container(
      color: colors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: HighlightView(
          widget.artifact.content,
          language: widget.artifact.language,
          theme: colors.isDark ? atomOneDarkTheme : atomOneLightTheme,
          textStyle: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            height: 1.45,
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(double targetWidth, AppColors colors) {
    Widget content;

    if (widget.artifact.language == 'svg') {
      content = Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SvgPicture.string(widget.artifact.content),
        ),
      );
    } else if (widget.artifact.language == 'html' && _webViewController != null) {
      content = WebViewWidget(controller: _webViewController!);
    } else {
      // Fallback preview
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.code, size: 48, color: colors.textMuted),
            const SizedBox(height: 12),
            Text(
              '${widget.artifact.language.toUpperCase()} file preview',
              style: TextStyle(color: colors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Switch to Code tab to view complete implementation',
              style: TextStyle(color: colors.textMuted, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Container(
      color: colors.background,
      child: Center(
        child: Container(
          width: targetWidth,
          decoration: BoxDecoration(
            border: targetWidth != double.infinity
                ? Border.symmetric(vertical: BorderSide(color: colors.border, width: 2))
                : null,
          ),
          child: content,
        ),
      ),
    );
  }
}
