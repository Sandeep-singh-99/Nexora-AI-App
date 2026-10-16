import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/utils/link_utils.dart';

class SearchResultsCard extends StatelessWidget {
  final String query;
  final List<Map<String, dynamic>> results;

  const SearchResultsCard({
    super.key,
    required this.query,
    required this.results,
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
            children: [
              Icon(Icons.search, size: 18, color: colors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Web Search: "$query"',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...results.map((item) {
            final title = item['title'] as String? ?? 'Citation';
            final url = item['url'] as String? ?? '';
            final snippet = item['snippet'] as String? ?? '';
            final host = Uri.tryParse(url)?.host ?? 'Web link';

            return InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                HapticUtils.selectionClick();
                LinkUtils.openUrl(url);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      host,
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (snippet.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        snippet,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
