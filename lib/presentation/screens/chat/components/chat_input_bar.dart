import 'package:flutter/material.dart';
import '../../../../app/theme/color_palette.dart';
import '../../../../core/utils/haptic_utils.dart';

class ChatInputBar extends StatefulWidget {
  final TextEditingController controller;
  final bool isStreaming;
  final String activeModel;
  final void Function(String text) onSend;
  final VoidCallback onStop;
  final void Function(String model) onModelChanged;
  final VoidCallback onAttachmentTap;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.isStreaming,
    required this.activeModel,
    required this.onSend,
    required this.onStop,
    required this.onModelChanged,
    required this.onAttachmentTap,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  bool _hasText = false;

  final List<Map<String, String>> _models = const [
    {'id': 'gemini-2.0-flash', 'name': 'Gemini 2.0 Flash', 'badge': 'Fast'},
    {'id': 'groq-llama-3.3-70b', 'name': 'Llama 3.3 70B (Groq)', 'badge': 'Speed'},
    {'id': 'claude-3-5-sonnet', 'name': 'Claude 3.5 Sonnet', 'badge': 'Pro'},
    {'id': 'gpt-4o', 'name': 'GPT-4o', 'badge': 'OpenAI'},
    {'id': 'deepseek-r1', 'name': 'DeepSeek R1', 'badge': 'Reasoning'},
  ];

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final has = widget.controller.text.trim().isNotEmpty;
    if (has != _hasText) {
      setState(() => _hasText = has);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _handleSend() {
    if (widget.isStreaming) {
      HapticUtils.heavyImpact();
      widget.onStop();
      return;
    }
    final text = widget.controller.text.trim();
    if (text.isNotEmpty) {
      HapticUtils.mediumImpact();
      widget.onSend(text);
      widget.controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        8 + MediaQuery.of(context).viewInsets.bottom / 4,
      ),
      decoration: const BoxDecoration(
        color: ColorPalette.obsidianBackground,
        border: Border(top: BorderSide(color: ColorPalette.subtleBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top mini bar: Model selector dropdown + Clear button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: ColorPalette.elevatedSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ColorPalette.subtleBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _models.any((m) => m['id'] == widget.activeModel)
                          ? widget.activeModel
                          : 'gemini-2.0-flash',
                      dropdownColor: ColorPalette.elevatedSurface,
                      icon: const Icon(Icons.arrow_drop_down, color: ColorPalette.textMuted, size: 18),
                      isDense: true,
                      style: const TextStyle(
                        color: ColorPalette.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          HapticUtils.selectionClick();
                          widget.onModelChanged(val);
                        }
                      },
                      items: _models.map((m) {
                        return DropdownMenuItem<String>(
                          value: m['id'],
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(m['name']!),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: ColorPalette.indigoAccent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  m['badge']!,
                                  style: const TextStyle(
                                    color: ColorPalette.indigoAccent,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Input Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Attachments button
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: ColorPalette.textSecondary),
                  tooltip: 'Attach Document',
                  onPressed: () {
                    HapticUtils.lightImpact();
                    widget.onAttachmentTap();
                  },
                ),

                // Auto-resizing textfield
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: ColorPalette.elevatedSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ColorPalette.subtleBorder),
                    ),
                    child: TextField(
                      controller: widget.controller,
                      maxLines: 5,
                      minLines: 1,
                      style: const TextStyle(color: ColorPalette.textPrimary, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Message Nexora AI...',
                        hintStyle: TextStyle(color: ColorPalette.textMuted, fontSize: 14),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Send or Stop button
                GestureDetector(
                  onTap: _handleSend,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: widget.isStreaming
                          ? ColorPalette.error
                          : (_hasText ? ColorPalette.indigoAccent : ColorPalette.elevatedCardHover),
                      shape: BoxShape.circle,
                      boxShadow: (_hasText || widget.isStreaming)
                          ? [
                              BoxShadow(
                                color: (widget.isStreaming ? ColorPalette.error : ColorPalette.indigoAccent)
                                    .withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Icon(
                        widget.isStreaming ? Icons.stop_rounded : Icons.arrow_upward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
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
