import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../../app/theme/app_colors.dart';
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
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
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
                  Icon(Icons.play_circle_fill, color: colors.textSecondary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title!,
                      style: TextStyle(
                        color: colors.textPrimary,
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
                    Icon(Icons.subtitles_outlined, size: 16, color: colors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      'Video Transcript (${widget.transcripts.length} cues)',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _isTranscriptExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 18,
                      color: colors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
            if (_isTranscriptExpanded) ...[
              Divider(height: 1, color: colors.border),
              Container(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: widget.transcripts.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: colors.border),
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
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: colors.border),
                              ),
                              child: Text(
                                DateHelpers.formatSecondsToMinutes(seconds),
                                style: TextStyle(
                                  color: colors.textPrimary,
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
                                style: TextStyle(
                                  color: colors.textSecondary,
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
                    backgroundColor: colors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: colors.border),
                    ),
                    label: Text(
                      prompt,
                      style: TextStyle(
                        color: colors.textPrimary,
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
