import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../../../../app/theme/app_colors.dart';
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

  void _copyLatex(BuildContext context, AppColors colors) {
    HapticUtils.heavyImpact();
    Clipboard.setData(ClipboardData(text: latex));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('LaTeX expression copied to clipboard!'),
        backgroundColor: colors.cardHover,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
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
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.border),
                    ),
                    child: Icon(Icons.functions, size: 18, color: colors.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title ?? 'Mathematical Equation',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.copy, size: 18, color: colors.textSecondary),
                tooltip: 'Copy LaTeX',
                onPressed: () => _copyLatex(context, colors),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Render Math Equation using flutter_math_fork
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Center(
                child: Math.tex(
                  latex,
                  textStyle: TextStyle(
                    fontSize: 18,
                    color: colors.textPrimary,
                  ),
                  onErrorFallback: (err) => Text(
                    latex,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Derivation Steps
          if (steps.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Derivation & Explanation:',
              style: TextStyle(
                color: colors.textSecondary,
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
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          color: colors.textPrimary,
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
