import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/utils/haptic_utils.dart';

class AiThinkingAccordion extends StatelessWidget {
  final String thought;
  final int? elapsedSeconds;
  final List<String> steps;
  final bool isExpanded;
  final VoidCallback onToggle;

  const AiThinkingAccordion({
    super.key,
    required this.thought,
    this.elapsedSeconds,
    this.steps = const [],
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (thought.trim().isEmpty && steps.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;
    final durationText = elapsedSeconds != null && elapsedSeconds! > 0
        ? ' (${DateHelpers.formatSecondsToMinutes(elapsedSeconds!)})'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              HapticUtils.selectionClick();
              onToggle();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colors.cardHover,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: colors.border),
                    ),
                    child: Icon(
                      Icons.psychology_outlined,
                      size: 16,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'AI Thought Process$durationText',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Collapsible body
          if (isExpanded) ...[
            Divider(height: 1, color: colors.border),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step trace badges
                  if (steps.isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: steps.map((step) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.card,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: colors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, size: 12, color: colors.success),
                              const SizedBox(width: 4),
                              Text(
                                step,
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Thought markdown / plain text
                  Text(
                    thought,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'monospace',
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
