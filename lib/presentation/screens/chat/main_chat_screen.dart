import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../domain/entities/conversation_entity.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';
import '../../blocs/chat/chat_state.dart';
import '../../blocs/conversation/conversation_bloc.dart';
import '../../blocs/conversation/conversation_event.dart';
import '../../blocs/conversation/conversation_state.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../artifacts/artifact_viewer_modal.dart';
import 'components/chat_input_bar.dart';
import 'components/conversation_drawer.dart';
import 'components/message_bubble.dart';

class MainChatScreen extends StatefulWidget {
  const MainChatScreen({super.key});

  @override
  State<MainChatScreen> createState() => _MainChatScreenState();
}

class _MainChatScreenState extends State<MainChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _showScrollToBottom = false;
  bool _wasStreaming = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    context.read<ConversationBloc>().add(LoadConversations());
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final show = (maxScroll - currentScroll) > 300;
    if (show != _showScrollToBottom) {
      setState(() => _showScrollToBottom = show);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSendMessage(String text, String activeModel, String? conversationId) async {
    if (_isSubmitting) return;
    _isSubmitting = true;

    try {
      if (conversationId == null) {
        // Draft mode: create new conversation on first prompt
        final completer = Completer<ConversationEntity>();
        context.read<ConversationBloc>().add(
              CreateConversation(
                title: 'New Chat',
                initialMessage: text,
                model: activeModel,
                completer: completer,
              ),
            );
        final newConv = await completer.future;
        if (!mounted) return;
        context.read<ChatBloc>().add(
              SendMessage(
                conversationId: newConv.id,
                content: text,
                model: activeModel,
              ),
            );
        Future.delayed(const Duration(milliseconds: 150), _scrollToBottom);
      } else {
        context.read<ChatBloc>().add(
              SendMessage(
                conversationId: conversationId,
                content: text,
                model: activeModel,
              ),
            );
        Future.delayed(const Duration(milliseconds: 150), _scrollToBottom);
      }
    } catch (_) {
    } finally {
      _isSubmitting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<ConversationBloc, ConversationState>(
      listener: (context, convState) {
        if (convState is ConversationLoaded) {
          final selectedId = convState.selectedConversationId;
          if (selectedId != null) {
            final chatState = context.read<ChatBloc>().state;
            final currentConvId = (chatState is ChatLoaded && chatState.messages.isNotEmpty)
                ? chatState.messages.first.conversationId
                : null;
            // Only reload messages if switching to a different conversation
            if (selectedId != currentConvId) {
              context.read<ChatBloc>().add(LoadMessages(selectedId));
            }
          } else {
            // New chat draft mode
            context.read<ChatBloc>().add(ResetChat());
          }
        }
      },
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          final activeModel = settingsState.activeModel;

          return BlocBuilder<ConversationBloc, ConversationState>(
            builder: (context, convState) {
              final currentConv = convState is ConversationLoaded ? convState.currentConversation : null;
              final convId = convState is ConversationLoaded ? convState.selectedConversationId : null;

              return Scaffold(
                key: _scaffoldKey,
                backgroundColor: colors.background,
                drawer: ConversationDrawer(
                  onSelect: (id) {
                    context.read<ConversationBloc>().add(SelectConversation(id));
                  },
                  onNewChat: () {
                    HapticUtils.lightImpact();
                    context.read<ConversationBloc>().add(ResetToNewChat());
                    context.read<ChatBloc>().add(ResetChat());
                  },
                ),
                appBar: AppBar(
                  backgroundColor: colors.background,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.menu, color: colors.textPrimary),
                    onPressed: () {
                      HapticUtils.lightImpact();
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentConv?.title ?? 'Nexora AI',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        activeModel,
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    if (settingsState.hasByok)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: colors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: colors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'BYOK',
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    IconButton(
                      icon: Icon(Icons.edit_note, color: colors.textSecondary),
                      tooltip: 'New Conversation',
                      onPressed: () {
                        HapticUtils.lightImpact();
                        context.read<ConversationBloc>().add(ResetToNewChat());
                        context.read<ChatBloc>().add(ResetChat());
                      },
                    ),
                  ],
                ),
                body: BlocConsumer<ChatBloc, ChatState>(
                  listener: (context, chatState) {
                    if (chatState is ChatLoaded) {
                      if (chatState.isStreaming) {
                        _scrollToBottom();
                      } else if (_wasStreaming) {
                        // Generation just finished! Refresh conversations so sidebar shows new title and messages
                        context.read<ConversationBloc>().add(LoadConversations());
                      }
                      _wasStreaming = chatState.isStreaming;

                      if (chatState.errorMessage != null && !chatState.isQuotaExceeded) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(chatState.errorMessage!),
                            backgroundColor: colors.error,
                          ),
                        );
                        context.read<ChatBloc>().add(ClearChatError());
                      }
                    }
                  },
                  builder: (context, chatState) {
                    final messages = chatState is ChatLoaded ? chatState.messages : [];
                    final isStreaming = chatState is ChatLoaded ? chatState.isStreaming : false;
                    final isQuotaExceeded = chatState is ChatLoaded ? chatState.isQuotaExceeded : false;

                    return Column(
                      children: [
                        // Quota Exceeded Banner
                        if (isQuotaExceeded) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              border: Border(
                                bottom: BorderSide(color: colors.border),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: colors.warning, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Shared cloud quota reached. Add your BYOK key in settings to continue.',
                                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => context.push('/settings'),
                                  child: Text(
                                    'Add Key',
                                    style: TextStyle(
                                      color: colors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Main Messages List
                        Expanded(
                          child: Stack(
                            children: [
                              messages.isEmpty
                                  ? _buildEmptyState(colors)
                                  : ListView.builder(
                                      controller: _scrollController,
                                      padding: const EdgeInsets.only(top: 12, bottom: 20),
                                      itemCount: messages.length,
                                      itemBuilder: (context, index) {
                                        final msg = messages[index];
                                        final isExpanded = chatState is ChatLoaded &&
                                            chatState.isThinkingExpanded(msg.id);

                                        return MessageBubble(
                                          message: msg,
                                          isThinkingExpanded: isExpanded,
                                          onToggleThinking: () {
                                            context.read<ChatBloc>().add(ToggleThinkingExpanded(msg.id));
                                          },
                                          onRegenerate: () {
                                            if (convId != null) {
                                              context.read<ChatBloc>().add(
                                                    RegenerateLastResponse(
                                                      conversationId: convId,
                                                      model: activeModel,
                                                    ),
                                                  );
                                            }
                                          },
                                          onViewArtifact: (artifact) {
                                            ArtifactViewerModal.show(context, artifact);
                                          },
                                          onPromptTap: (prompt) {
                                            _textController.text = prompt;
                                            _handleSendMessage(prompt, activeModel, convId);
                                          },
                                        );
                                      },
                                    ),

                              // Scroll to bottom floating button
                              if (_showScrollToBottom)
                                Positioned(
                                  right: 16,
                                  bottom: 16,
                                  child: FloatingActionButton.small(
                                    backgroundColor: colors.card,
                                    foregroundColor: colors.textPrimary,
                                    elevation: 2,
                                    shape: CircleBorder(
                                      side: BorderSide(color: colors.border),
                                    ),
                                    onPressed: _scrollToBottom,
                                    child: const Icon(Icons.keyboard_arrow_down, size: 20),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Chat Input Bar
                        ChatInputBar(
                          controller: _textController,
                          isStreaming: isStreaming,
                          activeModel: activeModel,
                          onSend: (text) => _handleSendMessage(text, activeModel, convId),
                          onStop: () {
                            context.read<ChatBloc>().add(StopGeneration());
                          },
                          onModelChanged: (newModel) {
                            context.read<SettingsBloc>().add(UpdateActiveModelEvent(newModel));
                          },
                          onAttachmentTap: () => context.push('/documents'),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Solid minimalist icon badge - Zero gradients
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.auto_awesome, color: colors.onPrimary, size: 26),
            ),
            const SizedBox(height: 16),
            Text(
              'How can Nexora assist you today?',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Autonomous multi-agent workflows, research, code synthesis, and document grounding.',
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Starter Prompts
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildPromptChip(colors, 'Analyze latest AI breakthroughs'),
                _buildPromptChip(colors, 'Write a clean Dart 3 BLoC pattern'),
                _buildPromptChip(colors, 'Derive the Euler-Lagrange equation'),
                _buildPromptChip(colors, 'Summarize video transcript into notes'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptChip(AppColors colors, String prompt) {
    return ActionChip(
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.border),
      ),
      label: Text(
        prompt,
        style: TextStyle(color: colors.textPrimary, fontSize: 12),
      ),
      onPressed: () {
        HapticUtils.lightImpact();
        _textController.text = prompt;
      },
    );
  }
}
