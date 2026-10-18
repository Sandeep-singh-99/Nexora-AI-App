import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';

class ChatInputBar extends StatefulWidget {
  final TextEditingController controller;
  final bool isStreaming;
  final String? activeModel;
  final void Function(String text) onSend;
  final VoidCallback onStop;
  final void Function(String model)? onModelChanged;
  final VoidCallback onAttachmentTap;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.isStreaming,
    this.activeModel,
    required this.onSend,
    required this.onStop,
    this.onModelChanged,
    required this.onAttachmentTap,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    final has = widget.controller.text.trim().isNotEmpty;
    if (has != _hasText) {
      setState(() => _hasText = has);
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus != _isFocused) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
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
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.fromLTRB(
        14,
        8,
        14,
        10 + MediaQuery.of(context).viewInsets.bottom / 4,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          top: BorderSide(color: colors.border.withValues(alpha: 0.5)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: _isFocused
                  ? colors.primary.withValues(alpha: 0.35)
                  : colors.border,
              width: 1.2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Attachment button
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: IconButton(
                  icon: Icon(
                    Icons.add_circle_outline_rounded,
                    color: colors.textSecondary,
                    size: 22,
                  ),
                  tooltip: 'Attach Document',
                  splashRadius: 20,
                  onPressed: () {
                    HapticUtils.lightImpact();
                    widget.onAttachmentTap();
                  },
                ),
              ),

              // Auto-resizing textfield
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    maxLines: 5,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 15,
                      height: 1.35,
                    ),
                    cursorColor: colors.primary,
                    cursorRadius: const Radius.circular(2),
                    decoration: InputDecoration(
                      hintText: 'Message Nexora AI...',
                      hintStyle: TextStyle(
                        color: colors.textMuted,
                        fontSize: 15,
                        height: 1.35,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
              ),

              // Send or Stop button
              Padding(
                padding: const EdgeInsets.only(bottom: 4, right: 2),
                child: GestureDetector(
                  onTap: _handleSend,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.isStreaming
                          ? colors.error
                          : (_hasText ? colors.primary : colors.cardHover),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        widget.isStreaming
                            ? Icons.stop_rounded
                            : Icons.arrow_upward_rounded,
                        color: widget.isStreaming
                            ? Colors.white
                            : (_hasText ? colors.onPrimary : colors.textMuted),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
