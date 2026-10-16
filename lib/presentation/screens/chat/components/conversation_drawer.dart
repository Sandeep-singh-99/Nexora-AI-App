import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../domain/entities/conversation_entity.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../blocs/conversation/conversation_bloc.dart';
import '../../../blocs/conversation/conversation_event.dart';
import '../../../blocs/conversation/conversation_state.dart';

class ConversationDrawer extends StatefulWidget {
  final void Function(String id)? onSelect;
  final VoidCallback? onNewChat;

  const ConversationDrawer({
    super.key,
    this.onSelect,
    this.onNewChat,
  });

  @override
  State<ConversationDrawer> createState() => _ConversationDrawerState();
}

class _ConversationDrawerState extends State<ConversationDrawer> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasSearchText = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final hasText = _searchController.text.trim().isNotEmpty;
      if (hasText != _hasSearchText) {
        setState(() => _hasSearchText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showRenameDialog(BuildContext context, ConversationEntity conversation, AppColors colors) {
    final textController = TextEditingController(text: conversation.title);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colors.border),
          ),
          title: Text(
            'Rename Chat',
            style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          content: TextField(
            controller: textController,
            autofocus: true,
            style: TextStyle(color: colors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Enter new conversation title',
              hintStyle: TextStyle(color: colors.textMuted, fontSize: 13),
              filled: true,
              fillColor: colors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final newTitle = textController.text.trim();
                if (newTitle.isNotEmpty) {
                  context.read<ConversationBloc>().add(
                        UpdateConversationDetails(
                          id: conversation.id,
                          title: newTitle,
                        ),
                      );
                }
                Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Drawer(
      backgroundColor: colors.background,
      elevation: 0,
      child: SafeArea(
        child: BlocBuilder<ConversationBloc, ConversationState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Brand & Header Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withValues(alpha: 0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.auto_awesome,
                            color: colors.onPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Nexora AI',
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: colors.surface,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: colors.border),
                                  ),
                                  child: Text(
                                    'v2.4',
                                    style: TextStyle(
                                      color: colors.textMuted,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Intelligent Studio',
                              style: TextStyle(
                                color: colors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.keyboard_double_arrow_left_rounded, color: colors.textSecondary, size: 20),
                        tooltip: 'Close Sidebar',
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          HapticUtils.lightImpact();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),

                // "New Chat" Prominent Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: Material(
                    color: colors.card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colors.border),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        HapticUtils.mediumImpact();
                        Navigator.of(context).pop();
                        widget.onNewChat?.call();
                      },
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(Icons.add_rounded, color: colors.onPrimary, size: 16),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'New Chat',
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: colors.borderSubtle),
                              ),
                              child: Text(
                                'Ctrl+N',
                                style: TextStyle(
                                  color: colors.textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Search Box
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      context.read<ConversationBloc>().add(SearchConversations(val));
                    },
                    style: TextStyle(color: colors.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Search chats...',
                      hintStyle: TextStyle(color: colors.textMuted, fontSize: 12.5),
                      prefixIcon: Icon(Icons.search_rounded, size: 17, color: colors.textMuted),
                      suffixIcon: _hasSearchText
                          ? IconButton(
                              icon: Icon(Icons.close_rounded, size: 16, color: colors.textMuted),
                              onPressed: () {
                                _searchController.clear();
                                context.read<ConversationBloc>().add(const SearchConversations(''));
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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
                        borderSide: BorderSide(color: colors.primary, width: 1.2),
                      ),
                    ),
                  ),
                ),

                Divider(height: 1, color: colors.border),

                // Conversation List
                Expanded(
                  child: _buildConversationList(context, state, colors),
                ),

                Divider(height: 1, color: colors.border),

                // Modern Footer: User Login / Profile + Setting Icon
                _buildModernFooter(context, colors),
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
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
          ),
        ),
      );
    }

    if (state is! ConversationLoaded) {
      return const SizedBox.shrink();
    }

    final pinned = state.pinnedConversations;
    final categorized = state.categorizedUnpinned;
    final selectedId = state.selectedConversationId;

    final totalCount = pinned.length +
        categorized.values.fold<int>(0, (sum, list) => sum + list.length);

    if (totalCount == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_bubble_outline_rounded, size: 38, color: colors.textMuted.withValues(alpha: 0.5)),
              const SizedBox(height: 10),
              Text(
                _hasSearchText ? 'No matching chats found' : 'No conversations yet',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                _hasSearchText ? 'Try a different search term' : 'Start a new conversation above',
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      children: [
        // Pinned Section
        if (pinned.isNotEmpty) ...[
          _buildCategoryHeader('PINNED', pinned.length, colors),
          ...pinned.map((c) => _buildConversationTile(context, c, colors, isSelected: c.id == selectedId)),
          const SizedBox(height: 6),
        ],

        // Date Categories
        ...categorized.entries.map((entry) {
          if (entry.value.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategoryHeader(entry.key.toUpperCase(), entry.value.length, colors),
              ...entry.value.map((c) => _buildConversationTile(context, c, colors, isSelected: c.id == selectedId)),
              const SizedBox(height: 6),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildCategoryHeader(String title, int count, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              color: colors.textMuted.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 14),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 18),
      ),
      confirmDismiss: (_) async {
        context.read<ConversationBloc>().add(DeleteConversationEvent(conversation.id));
        return true;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? colors.cardHover : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: colors.border, width: 1)
              : Border.all(color: Colors.transparent, width: 1),
        ),
        child: ListTile(
          dense: true,
          visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.only(left: 10, right: 4),
          leading: Icon(
            conversation.isPinned ? Icons.push_pin_rounded : Icons.chat_bubble_outline_rounded,
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
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz, size: 16, color: isSelected ? colors.textSecondary : colors.textMuted),
            color: colors.card,
            padding: EdgeInsets.zero,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colors.border),
            ),
            onSelected: (action) {
              final bloc = context.read<ConversationBloc>();
              if (action == 'rename') {
                _showRenameDialog(context, conversation, colors);
              } else if (action == 'pin') {
                bloc.add(UpdateConversationDetails(id: conversation.id, isPinned: !conversation.isPinned));
              } else if (action == 'archive') {
                bloc.add(UpdateConversationDetails(id: conversation.id, isArchived: !conversation.isArchived));
              } else if (action == 'delete') {
                bloc.add(DeleteConversationEvent(conversation.id));
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'rename',
                height: 38,
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 16, color: colors.textPrimary),
                    const SizedBox(width: 8),
                    Text('Rename', style: TextStyle(color: colors.textPrimary, fontSize: 13)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'pin',
                height: 38,
                child: Row(
                  children: [
                    Icon(
                      conversation.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      size: 16,
                      color: colors.textPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      conversation.isPinned ? 'Unpin' : 'Pin',
                      style: TextStyle(color: colors.textPrimary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'archive',
                height: 38,
                child: Row(
                  children: [
                    Icon(Icons.archive_outlined, size: 16, color: colors.textPrimary),
                    const SizedBox(width: 8),
                    Text(
                      conversation.isArchived ? 'Unarchive' : 'Archive',
                      style: TextStyle(color: colors.textPrimary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),
              PopupMenuItem(
                value: 'delete',
                height: 38,
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 16, color: colors.error),
                    const SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: colors.error, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          onTap: () {
            HapticUtils.selectionClick();
            Navigator.of(context).pop();
            widget.onSelect?.call(conversation.id);
          },
        ),
      ),
    );
  }

  /// Modern Footer: User Login/Profile + Settings Icon
  Widget _buildModernFooter(BuildContext context, AppColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      color: colors.surface,
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final isAuthenticated = authState is Authenticated;
          final user = isAuthenticated ? authState.user : null;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                // User Avatar / Login Action
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      HapticUtils.lightImpact();
                      Navigator.of(context).pop();
                      if (isAuthenticated) {
                        context.push('/settings');
                      } else {
                        context.push('/login');
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 17,
                                backgroundColor: isAuthenticated ? colors.primary : colors.surface,
                                child: Text(
                                  isAuthenticated
                                      ? (user!.username.isNotEmpty ? user.username[0].toUpperCase() : 'U')
                                      : '?',
                                  style: TextStyle(
                                    color: isAuthenticated ? colors.onPrimary : colors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (isAuthenticated)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 9,
                                    height: 9,
                                    decoration: BoxDecoration(
                                      color: colors.success,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: colors.card, width: 1.5),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isAuthenticated ? user!.username : 'Sign In',
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  isAuthenticated
                                      ? (user!.email.isNotEmpty ? user.email : 'Nexora Pro')
                                      : 'Tap to log in',
                                  style: TextStyle(
                                    color: colors.textMuted,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                // Dedicated Settings Icon Button
                Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.borderSubtle),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.settings_outlined,
                      size: 20,
                      color: colors.textSecondary,
                    ),
                    tooltip: 'Settings',
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      HapticUtils.selectionClick();
                      Navigator.of(context).pop();
                      context.push('/settings');
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
