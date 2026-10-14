import 'package:flutter/material.dart';
import '../../../../app/theme/color_palette.dart';
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

    final durationText = elapsedSeconds != null && elapsedSeconds! > 0
        ? ' (${DateHelpers.formatSecondsToMinutes(elapsedSeconds!)})'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ColorPalette.elevatedSurface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.subtleBorder),
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
                      color: ColorPalette.violetAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.psychology_outlined,
                      size: 16,
                      color: ColorPalette.violetAccent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'AI Thought Process$durationText',
                      style: const TextStyle(
                        color: ColorPalette.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: ColorPalette.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Collapsible body
          if (isExpanded) ...[
            const Divider(height: 1, color: ColorPalette.subtleBorder),
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
                            color: ColorPalette.elevatedCardHover,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: ColorPalette.lighterBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle, size: 12, color: ColorPalette.emeraldAccent),
                              const SizedBox(width: 4),
                              Text(
                                step,
                                style: const TextStyle(
                                  color: ColorPalette.textSecondary,
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
                    style: const TextStyle(
                      color: ColorPalette.textSecondary,
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
