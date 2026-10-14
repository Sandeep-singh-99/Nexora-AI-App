import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../../../../app/theme/color_palette.dart';
import '../../../../core/utils/haptic_utils.dart';

class MathCard extends StatelessWidget {
  final String latex;
  final String? title;
  final List<String> steps;

  const MathCard({
    super.key,
    required this.latex,
    this.title,
    this.steps = const [],
  });

  void _copyLatex(BuildContext context) {
    HapticUtils.heavyImpact();
    Clipboard.setData(ClipboardData(text: latex));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('LaTeX expression copied to clipboard!'),
        backgroundColor: ColorPalette.emeraldAccent,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorPalette.elevatedSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorPalette.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: ColorPalette.emeraldAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.functions, size: 18, color: ColorPalette.emeraldAccent),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title ?? 'Mathematical Equation',
                    style: const TextStyle(
                      color: ColorPalette.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18, color: ColorPalette.textSecondary),
                tooltip: 'Copy LaTeX',
                onPressed: () => _copyLatex(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Render Math Equation using flutter_math_fork
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: ColorPalette.obsidianBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorPalette.subtleBorder),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Center(
                child: Math.tex(
                  latex,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: ColorPalette.textPrimary,
                  ),
                  onErrorFallback: (err) => Text(
                    latex,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: ColorPalette.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Derivation Steps
          if (steps.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Derivation & Explanation:',
              style: TextStyle(
                color: ColorPalette.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...steps.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key + 1}. ',
                      style: const TextStyle(
                        color: ColorPalette.emeraldAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          color: ColorPalette.textPrimary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
