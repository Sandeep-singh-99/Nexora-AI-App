import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? status;
  final Map<String, dynamic> metrics;
  final String? summary;

  const InfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.status,
    this.metrics = const {},
    this.summary,
  });

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(color: colors.textMuted, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              if (status != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.border),
                  ),
                  child: Text(
                    status!,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (summary != null) ...[
            const SizedBox(height: 12),
            Text(
              summary!,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
          if (metrics.isNotEmpty) ...[
            const SizedBox(height: 14),
            Divider(height: 1, color: colors.border),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 10,
              children: metrics.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key.toUpperCase(),
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.value.toString(),
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
