import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../../app/theme/color_palette.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/utils/haptic_utils.dart';

class YouTubeCard extends StatefulWidget {
  final String videoUrl;
  final String? title;
  final List<Map<String, dynamic>> transcripts; // [{'seconds': 120, 'text': '...'}]
  final List<String> followUpPrompts;
  final void Function(String prompt)? onPromptTap;

  const YouTubeCard({
    super.key,
    required this.videoUrl,
    this.title,
    this.transcripts = const [],
    this.followUpPrompts = const [],
    this.onPromptTap,
  });

  @override
  State<YouTubeCard> createState() => _YouTubeCardState();
}

class _YouTubeCardState extends State<YouTubeCard> {
  late final YoutubePlayerController _controller;
  bool _isTranscriptExpanded = false;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayerController.convertUrlToId(widget.videoUrl) ?? '';
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );
  }

  @override
  void deactivate() {
    _controller.pauseVideo();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  void _seekToSecond(int seconds) {
    HapticUtils.lightImpact();
    _controller.seekTo(seconds: seconds.toDouble(), allowSeekAhead: true);
    _controller.playVideo();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: ColorPalette.elevatedSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorPalette.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          if (widget.title != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.play_circle_fill, color: ColorPalette.roseAccent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title!,
                      style: const TextStyle(
                        color: ColorPalette.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Video Player
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: YoutubePlayer(
              controller: _controller,
              aspectRatio: 16 / 9,
            ),
          ),

          // Transcripts section
          if (widget.transcripts.isNotEmpty) ...[
            InkWell(
              onTap: () {
                HapticUtils.selectionClick();
                setState(() => _isTranscriptExpanded = !_isTranscriptExpanded);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.subtitles_outlined, size: 16, color: ColorPalette.indigoAccent),
                    const SizedBox(width: 8),
                    Text(
                      'Video Transcript (${widget.transcripts.length} cues)',
                      style: const TextStyle(
                        color: ColorPalette.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _isTranscriptExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 18,
                      color: ColorPalette.textMuted,
                    ),
                  ],
                ),
              ),
            ),
            if (_isTranscriptExpanded) ...[
              const Divider(height: 1, color: ColorPalette.subtleBorder),
              Container(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: widget.transcripts.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: ColorPalette.subtleBorder),
                  itemBuilder: (context, index) {
                    final item = widget.transcripts[index];
                    final seconds = (item['seconds'] as num?)?.toInt() ?? 0;
                    final text = item['text'] as String? ?? '';

                    return InkWell(
                      onTap: () => _seekToSecond(seconds),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: ColorPalette.indigoAccent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                DateHelpers.formatSecondsToMinutes(seconds),
                                style: const TextStyle(
                                  color: ColorPalette.indigoAccent,
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                text,
                                style: const TextStyle(
                                  color: ColorPalette.textSecondary,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],

          // Follow-up Prompt Chips
          if (widget.followUpPrompts.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: widget.followUpPrompts.map((prompt) {
                  return ActionChip(
                    backgroundColor: ColorPalette.elevatedCardHover,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: ColorPalette.subtleBorder),
                    ),
                    label: Text(
                      prompt,
                      style: const TextStyle(
                        color: ColorPalette.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                    onPressed: () {
                      HapticUtils.lightImpact();
                      widget.onPromptTap?.call(prompt);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
