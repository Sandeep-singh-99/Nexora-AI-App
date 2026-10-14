import 'package:flutter/material.dart';
import '../../../../app/theme/color_palette.dart';

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: ColorPalette.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(color: ColorPalette.textMuted, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              if (status != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ColorPalette.emeraldAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ColorPalette.emeraldAccent.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    status!,
                    style: const TextStyle(
                      color: ColorPalette.emeraldAccent,
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
              style: const TextStyle(
                color: ColorPalette.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
          if (metrics.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: ColorPalette.subtleBorder),
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
                      style: const TextStyle(
                        color: ColorPalette.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.value.toString(),
                      style: const TextStyle(
                        color: ColorPalette.textPrimary,
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
