import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;
import '../../../../app/theme/app_colors.dart';
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
    final colors = context.colors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Message copied to clipboard!'),
        backgroundColor: colors.cardHover,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Icon(Icons.auto_awesome, size: 12, color: colors.onPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Nexora AI',
                    style: TextStyle(
                      color: colors.textPrimary,
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
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: colors.border),
                      ),
                      child: Text(
                        'BYOK: ${message.byokProvider ?? "Custom"}',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: colors.border),
                      ),
                      child: Text(
                        'Cloud',
                        style: TextStyle(
                          color: colors.textMuted,
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
              color: isUser ? colors.userBubble : colors.aiBubble,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
              border: Border.all(
                color: isUser ? Colors.transparent : colors.border,
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
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isUser ? colors.onUserBubble : colors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        message.status ?? 'Generating...',
                        style: TextStyle(
                          color: isUser ? colors.onUserBubble.withValues(alpha: 0.7) : colors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  _buildContent(context, colors),
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
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.code, size: 16, color: colors.textPrimary),
                      const SizedBox(width: 8),
                      Text(
                        'View ${message.artifact!.title}',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.open_in_new, size: 14, color: colors.textMuted),
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
                    icon: Icon(Icons.copy_outlined, size: 16, color: colors.textMuted),
                    tooltip: 'Copy',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: () => _copyToClipboard(context, message.content),
                  ),
                  const SizedBox(width: 4),
                  if (onRegenerate != null)
                    IconButton(
                      icon: Icon(Icons.refresh, size: 16, color: colors.textMuted),
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

  Widget _buildContent(BuildContext context, AppColors colors) {
    final textColor = isUser ? colors.onUserBubble : colors.onAiBubble;

    return MarkdownBody(
      data: message.content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(
          color: textColor,
          fontSize: 14,
          height: 1.5,
        ),
        h1: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
        h2: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
        h3: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
        code: TextStyle(
          backgroundColor: isUser ? Colors.black.withValues(alpha: 0.2) : colors.surface,
          color: textColor,
          fontFamily: 'monospace',
          fontSize: 12,
        ),
        codeblockPadding: const EdgeInsets.all(12),
        codeblockDecoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.border),
        ),
        blockquote: TextStyle(color: colors.textSecondary),
        blockquoteDecoration: BoxDecoration(
          border: Border(left: BorderSide(color: colors.border, width: 3)),
          color: colors.surface,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      builders: {
        'code': CodeBlockBuilder(context, colors),
      },
      extensionSet: md.ExtensionSet.gitHubFlavored,
    );
  }
}

class CodeBlockBuilder extends MarkdownElementBuilder {
  final BuildContext context;
  final AppColors colors;
  CodeBlockBuilder(this.context, this.colors);

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
          color: colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.border),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Math.tex(
            cleanLatex,
            textStyle: TextStyle(color: colors.textPrimary, fontSize: 16),
            onErrorFallback: (_) => Text(code, style: const TextStyle(fontFamily: 'monospace')),
          ),
        ),
      );
    }

    if (code.contains('\n') || language.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colors.cardHover,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                border: Border(bottom: BorderSide(color: colors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    language.isEmpty ? 'CODE' : language.toUpperCase(),
                    style: TextStyle(
                      color: colors.textMuted,
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
                        SnackBar(
                          content: const Text('Code copied to clipboard!'),
                          backgroundColor: colors.cardHover,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy, size: 12, color: colors.textMuted),
                        const SizedBox(width: 4),
                        Text('Copy', style: TextStyle(color: colors.textMuted, fontSize: 11)),
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
                theme: colors.isDark ? atomOneDarkTheme : atomOneLightTheme,
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
