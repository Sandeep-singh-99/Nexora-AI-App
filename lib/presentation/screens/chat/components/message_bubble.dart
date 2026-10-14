import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;
import '../../../../app/theme/color_palette.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../domain/entities/message_entity.dart';
import '../generative/generative_ui_renderer.dart';
import 'ai_thinking_accordion.dart';
import 'search_citations_view.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isThinkingExpanded;
  final VoidCallback onToggleThinking;
  final VoidCallback? onRegenerate;
  final void Function(ArtifactMetadata artifact)? onViewArtifact;
  final void Function(String prompt)? onPromptTap;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isThinkingExpanded,
    required this.onToggleThinking,
    this.onRegenerate,
    this.onViewArtifact,
    this.onPromptTap,
  });

  bool get isUser => message.role == 'user';

  void _copyToClipboard(BuildContext context, String text) {
    HapticUtils.selectionClick();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied to clipboard!'),
        backgroundColor: ColorPalette.elevatedCardHover,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Role header / BYOK tag
          if (!isUser) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [ColorPalette.indigoAccent, ColorPalette.violetAccent],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Icon(Icons.auto_awesome, size: 12, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Nexora AI',
                    style: TextStyle(
                      color: ColorPalette.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // BYOK indicator badge
                  if (message.isByok) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: ColorPalette.emeraldAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: ColorPalette.emeraldAccent.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        'BYOK: ${message.byokProvider ?? "Custom"}',
                        style: const TextStyle(
                          color: ColorPalette.emeraldAccent,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: ColorPalette.elevatedSurface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: ColorPalette.subtleBorder),
                      ),
                      child: const Text(
                        'Cloud',
                        style: TextStyle(
                          color: ColorPalette.textMuted,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // AI Thinking Accordion
          if (!isUser && ((message.thinking != null && message.thinking!.isNotEmpty) || message.thinkingSteps.isNotEmpty)) ...[
            AiThinkingAccordion(
              thought: message.thinking ?? '',
              elapsedSeconds: message.elapsedSeconds,
              steps: message.thinkingSteps,
              isExpanded: isThinkingExpanded,
              onToggle: onToggleThinking,
            ),
          ],

          // Search Citations View
          if (!isUser && message.citations.isNotEmpty) ...[
            SearchCitationsView(citations: message.citations),
          ],

          // Message Bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * (isUser ? 0.75 : 0.88),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? ColorPalette.userBubble : ColorPalette.aiBubble,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
              border: Border.all(
                color: isUser ? ColorPalette.indigoAccent.withValues(alpha: 0.3) : ColorPalette.subtleBorder,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.content.isEmpty && message.isStreaming) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.indigoAccent),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        message.status ?? 'Generating...',
                        style: const TextStyle(color: ColorPalette.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ] else ...[
                  _buildContent(context),
                ],
              ],
            ),
          ),

          // Generative UI card (if present)
          if (message.uiPayload != null) ...[
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              child: GenerativeUIRenderer(
                uiPayload: message.uiPayload!,
                onPromptTap: onPromptTap,
              ),
            ),
          ],

          // View Artifact Button (if artifact detected)
          if (message.artifact != null && onViewArtifact != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  HapticUtils.selectionClick();
                  onViewArtifact!(message.artifact!);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: ColorPalette.indigoAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ColorPalette.indigoAccent.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.code, size: 16, color: ColorPalette.indigoAccent),
                      const SizedBox(width: 8),
                      Text(
                        'View ${message.artifact!.title}',
                        style: const TextStyle(
                          color: ColorPalette.indigoAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.open_in_new, size: 14, color: ColorPalette.indigoAccent),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // Bottom Action Bar (Copy, Regenerate)
          if (!isUser && !message.isStreaming && message.content.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy_outlined, size: 16, color: ColorPalette.textMuted),
                    tooltip: 'Copy',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: () => _copyToClipboard(context, message.content),
                  ),
                  const SizedBox(width: 4),
                  if (onRegenerate != null)
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 16, color: ColorPalette.textMuted),
                      tooltip: 'Regenerate',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      onPressed: onRegenerate,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    // If message contains LaTeX markers like $$ or \(, format with math
    return MarkdownBody(
      data: message.content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(
          color: ColorPalette.textPrimary,
          fontSize: 14,
          height: 1.5,
        ),
        h1: const TextStyle(color: ColorPalette.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        h2: const TextStyle(color: ColorPalette.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        h3: const TextStyle(color: ColorPalette.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        code: const TextStyle(
          backgroundColor: Color(0xFF1E293D),
          color: ColorPalette.cyanAccent,
          fontFamily: 'monospace',
          fontSize: 12,
        ),
        codeblockPadding: const EdgeInsets.all(12),
        codeblockDecoration: BoxDecoration(
          color: ColorPalette.obsidianBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColorPalette.subtleBorder),
        ),
        blockquote: const TextStyle(color: ColorPalette.textSecondary),
        blockquoteDecoration: BoxDecoration(
          border: const Border(left: BorderSide(color: ColorPalette.indigoAccent, width: 3)),
          color: ColorPalette.elevatedCardHover,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      builders: {
        'code': CodeBlockBuilder(context),
      },
      extensionSet: md.ExtensionSet.gitHubFlavored,
    );
  }
}

class CodeBlockBuilder extends MarkdownElementBuilder {
  final BuildContext context;
  CodeBlockBuilder(this.context);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final language = element.attributes['class']?.replaceFirst('language-', '') ?? '';
    final code = element.textContent;

    // Check if it's a LaTeX block
    if (language == 'latex' || language == 'math' || (code.startsWith(r'$$') && code.endsWith(r'$$'))) {
      final cleanLatex = code.replaceAll(r'$$', '').trim();
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ColorPalette.obsidianBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Math.tex(
            cleanLatex,
            textStyle: const TextStyle(color: ColorPalette.textPrimary, fontSize: 16),
            onErrorFallback: (_) => Text(code, style: const TextStyle(fontFamily: 'monospace')),
          ),
        ),
      );
    }

    if (code.contains('\n') || language.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: ColorPalette.obsidianBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColorPalette.subtleBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: const BoxDecoration(
                color: ColorPalette.elevatedSurface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    language.isEmpty ? 'CODE' : language.toUpperCase(),
                    style: const TextStyle(
                      color: ColorPalette.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      HapticUtils.selectionClick();
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Code copied to clipboard!'),
                          backgroundColor: ColorPalette.emeraldAccent,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy, size: 12, color: ColorPalette.textMuted),
                        SizedBox(width: 4),
                        Text('Copy', style: TextStyle(color: ColorPalette.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              child: HighlightView(
                code,
                language: language.isNotEmpty ? language : 'plaintext',
                theme: atomOneDarkTheme,
                textStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return null;
  }
}
