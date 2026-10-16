import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
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
    final colors = context.colors;

    return Drawer(
      backgroundColor: colors.background,
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
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, color: colors.onPrimary, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'New Chat',
                                  style: TextStyle(
                                    color: colors.onPrimary,
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
                    style: TextStyle(color: colors.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Search conversations...',
                      hintStyle: TextStyle(color: colors.textMuted, fontSize: 13),
                      prefixIcon: Icon(Icons.search, size: 18, color: colors.textMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      fillColor: colors.surface,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colors.primary, width: 1.5),
                      ),
                    ),
                  ),
                ),

                Divider(height: 1, color: colors.border),

                // List of conversations
                Expanded(
                  child: _buildConversationList(context, state, colors),
                ),

                Divider(height: 1, color: colors.border),

                // Bottom Navigation Links: Documents, Memory, Settings - Neutral icons, zero fancy neon
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      ListTile(
                        dense: true,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        leading: Icon(Icons.folder_copy_outlined, size: 20, color: colors.textSecondary),
                        title: Text('Knowledge Documents', style: TextStyle(color: colors.textPrimary, fontSize: 13)),
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push('/documents');
                        },
                      ),
                      ListTile(
                        dense: true,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        leading: Icon(Icons.hub_outlined, size: 20, color: colors.textSecondary),
                        title: Text('Memory & Graph', style: TextStyle(color: colors.textPrimary, fontSize: 13)),
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push('/memory');
                        },
                      ),
                      ListTile(
                        dense: true,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        leading: Icon(Icons.settings_outlined, size: 20, color: colors.textSecondary),
                        title: Text('Settings & Theme', style: TextStyle(color: colors.textPrimary, fontSize: 13)),
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

  Widget _buildConversationList(BuildContext context, ConversationState state, AppColors colors) {
    if (state is ConversationLoading) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
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
          _buildCategoryHeader('PINNED', colors),
          ...pinned.map((c) => _buildConversationTile(context, c, colors, isSelected: c.id == selectedId)),
          const SizedBox(height: 8),
        ],

        // Date Categories
        ...categorized.entries.map((entry) {
          if (entry.value.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategoryHeader(entry.key.toUpperCase(), colors),
              ...entry.value.map((c) => _buildConversationTile(context, c, colors, isSelected: c.id == selectedId)),
              const SizedBox(height: 8),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildCategoryHeader(String title, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          color: colors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildConversationTile(
    BuildContext context,
    ConversationEntity conversation,
    AppColors colors, {
    required bool isSelected,
  }) {
    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: colors.error,
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
        selectedTileColor: colors.cardHover,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        leading: Icon(
          conversation.isPinned ? Icons.push_pin : Icons.chat_bubble_outline,
          size: 16,
          color: isSelected
              ? colors.primary
              : (conversation.isPinned ? colors.warning : colors.textMuted),
        ),
        title: Text(
          conversation.title,
          style: TextStyle(
            color: isSelected ? colors.textPrimary : colors.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_horiz, size: 16, color: colors.textMuted),
          color: colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: colors.border),
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
                style: TextStyle(color: colors.textPrimary, fontSize: 13),
              ),
            ),
            PopupMenuItem(
              value: 'archive',
              child: Text(
                conversation.isArchived ? 'Unarchive' : 'Archive',
                style: TextStyle(color: colors.textPrimary, fontSize: 13),
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text(
                'Delete',
                style: TextStyle(color: colors.error, fontSize: 13),
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
