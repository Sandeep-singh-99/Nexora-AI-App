import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/color_palette.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../domain/entities/conversation_entity.dart';
import '../../../blocs/conversation/conversation_bloc.dart';
import '../../../blocs/conversation/conversation_event.dart';
import '../../../blocs/conversation/conversation_state.dart';

class ConversationDrawer extends StatelessWidget {
  final void Function(String id)? onSelect;
  final VoidCallback? onNewChat;

  const ConversationDrawer({
    super.key,
    this.onSelect,
    this.onNewChat,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ColorPalette.obsidianBackground,
      child: SafeArea(
        child: BlocBuilder<ConversationBloc, ConversationState>(
          builder: (context, state) {
            return Column(
              children: [
                // Top Header: New Chat Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            HapticUtils.mediumImpact();
                            Navigator.of(context).pop();
                            onNewChat?.call();
                          },
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: ColorPalette.indigoAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: ColorPalette.indigoAccent.withValues(alpha: 0.4)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.add, color: ColorPalette.indigoAccent, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'New Chat',
                                  style: TextStyle(
                                    color: ColorPalette.indigoAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Filter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    onChanged: (val) {
                      context.read<ConversationBloc>().add(SearchConversations(val));
                    },
                    style: const TextStyle(color: ColorPalette.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Search conversations...',
                      prefixIcon: const Icon(Icons.search, size: 18, color: ColorPalette.textMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      fillColor: ColorPalette.elevatedSurface,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: ColorPalette.subtleBorder),
                      ),
                    ),
                  ),
                ),

                const Divider(height: 1, color: ColorPalette.subtleBorder),

                // List of conversations
                Expanded(
                  child: _buildConversationList(context, state),
                ),

                const Divider(height: 1, color: ColorPalette.subtleBorder),

                // Bottom Navigation Links: Documents, Memory, Settings
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      ListTile(
                        dense: true,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        leading: const Icon(Icons.folder_copy_outlined, size: 20, color: ColorPalette.cyanAccent),
                        title: const Text('Knowledge Documents', style: TextStyle(color: ColorPalette.textPrimary, fontSize: 13)),
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push('/documents');
                        },
                      ),
                      ListTile(
                        dense: true,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        leading: const Icon(Icons.hub_outlined, size: 20, color: ColorPalette.violetAccent),
                        title: const Text('Memory & Graph', style: TextStyle(color: ColorPalette.textPrimary, fontSize: 13)),
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push('/memory');
                        },
                      ),
                      ListTile(
                        dense: true,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        leading: const Icon(Icons.settings_outlined, size: 20, color: ColorPalette.textSecondary),
                        title: const Text('BYOK & Settings', style: TextStyle(color: ColorPalette.textPrimary, fontSize: 13)),
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push('/settings');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildConversationList(BuildContext context, ConversationState state) {
    if (state is ConversationLoading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.indigoAccent),
        ),
      );
    }

    if (state is! ConversationLoaded) {
      return const SizedBox.shrink();
    }

    final pinned = state.pinnedConversations;
    final categorized = state.categorizedUnpinned;
    final selectedId = state.selectedConversationId;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Pinned Section
        if (pinned.isNotEmpty) ...[
          _buildCategoryHeader('PINNED'),
          ...pinned.map((c) => _buildConversationTile(context, c, isSelected: c.id == selectedId)),
          const SizedBox(height: 8),
        ],

        // Date Categories
        ...categorized.entries.map((entry) {
          if (entry.value.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategoryHeader(entry.key.toUpperCase()),
              ...entry.value.map((c) => _buildConversationTile(context, c, isSelected: c.id == selectedId)),
              const SizedBox(height: 8),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          color: ColorPalette.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildConversationTile(
    BuildContext context,
    ConversationEntity conversation, {
    required bool isSelected,
  }) {
    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: ColorPalette.error.withValues(alpha: 0.8),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
      ),
      confirmDismiss: (_) async {
        context.read<ConversationBloc>().add(DeleteConversationEvent(conversation.id));
        return true;
      },
      child: ListTile(
        dense: true,
        selected: isSelected,
        selectedTileColor: ColorPalette.elevatedSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        leading: Icon(
          conversation.isPinned ? Icons.push_pin : Icons.chat_bubble_outline,
          size: 16,
          color: isSelected
              ? ColorPalette.indigoAccent
              : (conversation.isPinned ? ColorPalette.amberAccent : ColorPalette.textMuted),
        ),
        title: Text(
          conversation.title,
          style: TextStyle(
            color: isSelected ? ColorPalette.textPrimary : ColorPalette.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz, size: 16, color: ColorPalette.textMuted),
          color: ColorPalette.elevatedSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: ColorPalette.subtleBorder),
          ),
          onSelected: (action) {
            final bloc = context.read<ConversationBloc>();
            if (action == 'pin') {
              bloc.add(UpdateConversationDetails(id: conversation.id, isPinned: !conversation.isPinned));
            } else if (action == 'archive') {
              bloc.add(UpdateConversationDetails(id: conversation.id, isArchived: !conversation.isArchived));
            } else if (action == 'delete') {
              bloc.add(DeleteConversationEvent(conversation.id));
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'pin',
              child: Text(
                conversation.isPinned ? 'Unpin Chat' : 'Pin Chat',
                style: const TextStyle(color: ColorPalette.textPrimary, fontSize: 13),
              ),
            ),
            PopupMenuItem(
              value: 'archive',
              child: Text(
                conversation.isArchived ? 'Unarchive' : 'Archive',
                style: const TextStyle(color: ColorPalette.textPrimary, fontSize: 13),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text(
                'Delete',
                style: TextStyle(color: ColorPalette.error, fontSize: 13),
              ),
            ),
          ],
        ),
        onTap: () {
          HapticUtils.selectionClick();
          Navigator.of(context).pop();
          onSelect?.call(conversation.id);
        },
      ),
    );
  }
}
