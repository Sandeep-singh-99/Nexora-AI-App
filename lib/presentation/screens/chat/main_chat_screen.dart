import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/color_palette.dart';
import '../../../core/utils/haptic_utils.dart';
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

  void _handleSendMessage(String text, String activeModel, String? conversationId) {
    if (conversationId == null) {
      // Create new conversation first
      context.read<ConversationBloc>().add(
            CreateConversation(
              title: text.length > 30 ? '${text.substring(0, 30)}...' : text,
              initialMessage: text,
              model: activeModel,
            ),
          );
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
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConversationBloc, ConversationState>(
      listener: (context, convState) {
        if (convState is ConversationLoaded && convState.selectedConversationId != null) {
          context.read<ChatBloc>().add(LoadMessages(convState.selectedConversationId!));
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
                backgroundColor: ColorPalette.obsidianBackground,
                drawer: ConversationDrawer(
                  onSelect: (id) {
                    context.read<ConversationBloc>().add(SelectConversation(id));
                  },
                  onNewChat: () {
                    context.read<ConversationBloc>().add(
                          CreateConversation(
                            title: 'New Chat',
                            model: activeModel,
                          ),
                        );
                  },
                ),
                appBar: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.menu, color: ColorPalette.textPrimary),
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
                        style: const TextStyle(
                          color: ColorPalette.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        activeModel,
                        style: const TextStyle(
                          color: ColorPalette.textMuted,
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
                            color: ColorPalette.emeraldAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: ColorPalette.emeraldAccent.withValues(alpha: 0.4)),
                          ),
                          child: const Text(
                            'BYOK Active',
                            style: TextStyle(
                              color: ColorPalette.emeraldAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit_note, color: ColorPalette.textSecondary),
                      tooltip: 'New Conversation',
                      onPressed: () {
                        HapticUtils.lightImpact();
                        context.read<ConversationBloc>().add(
                              CreateConversation(
                                title: 'New Chat',
                                model: activeModel,
                              ),
                            );
                      },
                    ),
                  ],
                ),
                body: BlocConsumer<ChatBloc, ChatState>(
                  listener: (context, chatState) {
                    if (chatState is ChatLoaded) {
                      if (chatState.isStreaming) {
                        _scrollToBottom();
                      }
                      if (chatState.errorMessage != null && !chatState.isQuotaExceeded) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(chatState.errorMessage!),
                            backgroundColor: ColorPalette.error,
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
                            color: ColorPalette.warning.withValues(alpha: 0.15),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: ColorPalette.warning, size: 20),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Shared cloud quota exceeded. Set your custom BYOK key to continue uninterrupted.',
                                    style: TextStyle(color: ColorPalette.warning, fontSize: 12),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => context.push('/settings'),
                                  child: const Text('Add BYOK', style: TextStyle(color: Colors.white, fontSize: 12)),
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
                                  ? _buildEmptyState()
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
                                    backgroundColor: ColorPalette.elevatedSurface,
                                    foregroundColor: ColorPalette.textPrimary,
                                    shape: const CircleBorder(
                                      side: BorderSide(color: ColorPalette.subtleBorder),
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

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ColorPalette.indigoAccent, ColorPalette.violetAccent],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'How can Nexora assist you today?',
              style: TextStyle(
                color: ColorPalette.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Autonomous multi-agent workflows, deep research, code generation, and RAG document grounding.',
              style: TextStyle(color: ColorPalette.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Starter Prompts
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildPromptChip('Analyze latest AI breakthroughs'),
                _buildPromptChip('Write a clean Dart 3 BLoC pattern'),
                _buildPromptChip('Derive the Euler-Lagrange equation'),
                _buildPromptChip('Summarize video transcript into notes'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptChip(String prompt) {
    return ActionChip(
      backgroundColor: ColorPalette.elevatedSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: ColorPalette.subtleBorder),
      ),
      label: Text(
        prompt,
        style: const TextStyle(color: ColorPalette.textPrimary, fontSize: 12),
      ),
      onPressed: () {
        HapticUtils.lightImpact();
        _textController.text = prompt;
      },
    );
  }
}
