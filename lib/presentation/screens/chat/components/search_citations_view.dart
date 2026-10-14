import 'package:flutter/material.dart';
import '../../../../app/theme/color_palette.dart';
import '../../../../core/network/sse_stream_reader.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/utils/link_utils.dart';

class SearchCitationsView extends StatelessWidget {
  final List<SearchCitation> citations;

  const SearchCitationsView({super.key, required this.citations});

  @override
  Widget build(BuildContext context) {
    if (citations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.travel_explore, size: 14, color: ColorPalette.cyanAccent),
            const SizedBox(width: 6),
            Text(
              'Sources (${citations.length})',
              style: const TextStyle(
                color: ColorPalette.cyanAccent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: citations.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = citations[index];
              final host = Uri.tryParse(item.url)?.host ?? 'Web Source';

              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  HapticUtils.selectionClick();
                  LinkUtils.openUrl(item.url);
                },
                child: Container(
                  width: 180,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorPalette.elevatedSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ColorPalette.subtleBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: ColorPalette.cyanAccent,
                            ),
                            child: const Center(
                              child: Icon(Icons.public, size: 10, color: Colors.black),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              host,
                              style: const TextStyle(
                                color: ColorPalette.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: ColorPalette.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
