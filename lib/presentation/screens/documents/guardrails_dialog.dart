import 'dart:io';
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../domain/entities/document_entity.dart';
import '../../widgets/app_button.dart';

class GuardrailsDialog extends StatelessWidget {
  final File file;
  final String message;
  final List<SensitiveFinding> findings;
  final VoidCallback onCancel;
  final VoidCallback onProceedAnyway;

  const GuardrailsDialog({
    super.key,
    required this.file,
    required this.message,
    required this.findings,
    required this.onCancel,
    required this.onProceedAnyway,
  });

  static Future<void> show({
    required BuildContext context,
    required File file,
    required String message,
    required List<SensitiveFinding> findings,
    required VoidCallback onProceedAnyway,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GuardrailsDialog(
        file: file,
        message: message,
        findings: findings,
        onCancel: () => Navigator.of(context).pop(),
        onProceedAnyway: () {
          Navigator.of(context).pop();
          onProceedAnyway();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Dialog(
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warning Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.border),
                  ),
                  child: Icon(Icons.shield_outlined, color: colors.warning, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sensitive Data Detected',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Nexora Guardrails Alert',
                        style: TextStyle(color: colors.warning, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              message.isNotEmpty
                  ? message
                  : 'Automated PII scanner detected potential credentials or personal data in this document.',
              style: TextStyle(color: colors.textSecondary, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),

            // Findings list
            Container(
              constraints: const BoxConstraints(maxHeight: 180),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.border),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: findings.length,
                separatorBuilder: (_, __) => Divider(height: 12, color: colors.border),
                itemBuilder: (context, index) {
                  final item = findings[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.category,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.cardHover,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: colors.border),
                            ),
                            child: Text(
                              '${item.count} found',
                              style: TextStyle(color: colors.textMuted, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      if (item.samples.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Samples: ${item.samples.join(", ")}',
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Cancel Upload',
                    variant: ButtonVariant.secondary,
                    onPressed: () {
                      HapticUtils.lightImpact();
                      onCancel();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'Proceed Anyway',
                    variant: ButtonVariant.danger,
                    onPressed: () {
                      HapticUtils.heavyImpact();
                      onProceedAnyway();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
