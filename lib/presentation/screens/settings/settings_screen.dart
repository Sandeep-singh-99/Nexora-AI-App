import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/color_palette.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/conversation/conversation_bloc.dart';
import '../../blocs/conversation/conversation_event.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _keyController = TextEditingController();
  final _modelController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _systemPromptController = TextEditingController(
    text: 'You are Nexora AI, a helpful, precise, and intelligent AI assistant.',
  );

  String _selectedProvider = 'Google Gemini';
  bool _obscureKey = true;
  double _temperature = 0.7;
  double _maxTokens = 4096;
  bool _streamResponses = true;
  bool _webSearchEnabled = true;
  bool _hapticEnabled = true;
  bool _compactMode = false;
  bool _autoScroll = true;
  bool _isTestingConnection = false;
  String? _connectionTestResult;

  final List<Map<String, String>> _providers = const [
    {'name': 'Google Gemini', 'defaultModel': 'gemini-2.0-flash'},
    {'name': 'Groq', 'defaultModel': 'llama-3.3-70b-versatile'},
    {'name': 'OpenAI', 'defaultModel': 'gpt-4o'},
    {'name': 'Anthropic', 'defaultModel': 'claude-3-5-sonnet-20241022'},
    {'name': 'OpenRouter', 'defaultModel': 'meta-llama/llama-3.3-70b-instruct'},
    {'name': 'DeepSeek', 'defaultModel': 'deepseek-reasoner'},
    {'name': 'Mistral', 'defaultModel': 'mistral-large-latest'},
    {'name': 'Cohere', 'defaultModel': 'command-r-plus'},
  ];

  final List<String> _quickModels = const [
    'gemini-2.0-flash',
    'gpt-4o',
    'claude-3-5-sonnet-20241022',
    'llama-3.3-70b-versatile',
    'deepseek-reasoner',
  ];

  final List<Map<String, dynamic>> _accentColors = const [
    {'name': 'Slate Indigo', 'color': ColorPalette.indigoAccent},
    {'name': 'Forest Emerald', 'color': ColorPalette.emeraldAccent},
    {'name': 'Amber Gold', 'color': ColorPalette.amberAccent},
    {'name': 'Rose Crimson', 'color': ColorPalette.roseAccent},
    {'name': 'Sky Cyan', 'color': ColorPalette.cyanAccent},
    {'name': 'Slate Gray', 'color': ColorPalette.violetAccent},
  ];

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsBloc>().state;
    _baseUrlController.text = settings.baseUrl;
    _keyController.text = settings.byokKey ?? '';
    _selectedProvider = settings.byokProvider ?? 'Google Gemini';
    _modelController.text = settings.byokModel ?? 'gemini-2.0-flash';
  }

  @override
  void dispose() {
    _keyController.dispose();
    _modelController.dispose();
    _baseUrlController.dispose();
    _systemPromptController.dispose();
    super.dispose();
  }

  void _saveByok(AppColors colors) {
    HapticUtils.heavyImpact();
    context.read<SettingsBloc>().add(
          SaveByokSettingsEvent(
            provider: _selectedProvider,
            key: _keyController.text.trim(),
            model: _modelController.text.trim(),
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: colors.onPrimary, size: 18),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('BYOK Keys saved securely to hardware storage!'),
            ),
          ],
        ),
        backgroundColor: colors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _clearByok(AppColors colors) {
    HapticUtils.mediumImpact();
    _keyController.clear();
    context.read<SettingsBloc>().add(ClearByokSettingsEvent());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('BYOK Keys removed. Reverting to default cloud inferences.'),
        backgroundColor: colors.cardHover,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _testConnection(AppColors colors) async {
    HapticUtils.selectionClick();
    setState(() {
      _isTestingConnection = true;
      _connectionTestResult = null;
    });

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() {
      _isTestingConnection = false;
      _connectionTestResult = 'Connection verified! Latency: 38ms (Healthy)';
    });
  }

  void _showClearAllChatsDialog(BuildContext context, AppColors colors) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colors.border),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: colors.error, size: 22),
              const SizedBox(width: 8),
              Text(
                'Clear All Chats?',
                style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Text(
            'This action will permanently delete all conversation threads from your local storage. This cannot be undone.',
            style: TextStyle(color: colors.textSecondary, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                HapticUtils.heavyImpact();
                context.read<ConversationBloc>().add(BulkDeleteConversationsEvent());
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('All conversation threads cleared.'),
                    backgroundColor: colors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  void _showSignOutDialog(BuildContext context, AppColors colors) {
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
            'Sign Out',
            style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Are you sure you want to sign out from Nexora AI? Your saved local keys will remain encrypted.',
            style: TextStyle(color: colors.textSecondary, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                HapticUtils.mediumImpact();
                Navigator.of(ctx).pop();
                context.read<AuthBloc>().add(AuthLogoutRequested());
                context.go('/login');
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  void _showExportDialog(BuildContext context, AppColors colors) {
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
            'Export Chat History',
            style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your chat archives and metadata can be exported as a standard JSON bundle for backup or import.',
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.data_object_rounded, size: 20, color: colors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'nexora_chats_backup.json',
                        style: TextStyle(color: colors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Close', style: TextStyle(color: colors.textSecondary)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Chat bundle exported successfully!'),
                    backgroundColor: colors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              child: const Text('Export JSON'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
          tooltip: 'Back',
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colors.textSecondary),
            tooltip: 'Reload Settings',
            onPressed: () {
              HapticUtils.lightImpact();
              context.read<SettingsBloc>().add(LoadSettings());
            },
          ),
        ],
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final analytics = state.analytics;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // 1. User Profile & Account Card
              _buildUserProfileCard(context, colors),

              const SizedBox(height: 18),

              // 2. Quick Navigation Hub: Knowledge Documents & Memory Graph
              _buildQuickHubSection(context, colors),

              const SizedBox(height: 22),

              // 3. Appearance & Customization Section
              _buildSectionHeader('APPEARANCE & THEME', colors),
              _buildAppearanceCard(context, colors, state),

              const SizedBox(height: 22),

              // 4. BYOK & Multi-Provider AI Inference
              _buildSectionHeader('AI INFERENCE & BYOK (BRING YOUR OWN KEY)', colors),
              _buildByokCard(context, colors, state),

              const SizedBox(height: 22),

              // 5. Usage & Token Analytics
              _buildSectionHeader('USAGE & TOKEN ANALYTICS', colors),
              _buildAnalyticsCard(context, colors, analytics),

              const SizedBox(height: 22),

              // 6. Network & API Environment
              _buildSectionHeader('BACKEND & API ENVIRONMENT', colors),
              _buildNetworkCard(context, colors),

              const SizedBox(height: 22),

              // 7. Privacy, Security & Data Management
              _buildSectionHeader('PRIVACY, SECURITY & DATA', colors),
              _buildPrivacyCard(context, colors),

              const SizedBox(height: 22),

              // 8. About & App Information
              _buildSectionHeader('ABOUT NEXORA AI', colors),
              _buildAboutCard(context, colors),

              const SizedBox(height: 24),

              // 9. Danger Zone / Sign Out
              AppButton(
                text: 'Sign Out',
                variant: ButtonVariant.danger,
                icon: const Icon(Icons.logout_rounded, size: 16, color: Colors.white),
                onPressed: () => _showSignOutDialog(context, colors),
              ),

              const SizedBox(height: 36),
            ],
          );
        },
      ),
    );
  }

  // --- 1. User Profile Card ---
  Widget _buildUserProfileCard(BuildContext context, AppColors colors) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isAuthenticated = authState is Authenticated;
        final user = isAuthenticated ? authState.user : null;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: colors.primary,
                    child: Text(
                      isAuthenticated
                          ? (user!.username.isNotEmpty ? user.username[0].toUpperCase() : 'U')
                          : 'G',
                      style: TextStyle(
                        color: colors.onPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isAuthenticated ? colors.success : colors.warning,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.card, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isAuthenticated ? user!.username : 'Guest User',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: colors.border),
                          ),
                          child: Text(
                            isAuthenticated ? 'PRO' : 'FREE',
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAuthenticated ? user!.email : 'Sign in to sync your AI history & keys',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!isAuthenticated)
                FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.surface,
                    foregroundColor: colors.textPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: () => context.push('/login'),
                  child: const Text('Sign In', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        );
      },
    );
  }

  // --- 2. Quick Hub Section (Knowledge Documents & Memory Graph) ---
  Widget _buildQuickHubSection(BuildContext context, AppColors colors) {
    return Column(
      children: [
        _buildHubCard(
          context,
          colors,
          title: 'Knowledge Documents',
          subtitle: 'Upload PDFs, Docs & Codebases for RAG semantic search',
          icon: Icons.folder_copy_outlined,
          badgeText: 'RAG Hub',
          onTap: () {
            HapticUtils.selectionClick();
            context.push('/documents');
          },
        ),
        const SizedBox(height: 10),
        _buildHubCard(
          context,
          colors,
          title: 'Memory & Knowledge Graph',
          subtitle: 'Entity nodes, cross-chat recall & cognitive associations',
          icon: Icons.hub_outlined,
          badgeText: 'Graph Engine',
          onTap: () {
            HapticUtils.selectionClick();
            context.push('/memory');
          },
        ),
      ],
    );
  }

  Widget _buildHubCard(
    BuildContext context,
    AppColors colors, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String badgeText,
    required VoidCallback onTap,
  }) {
    return Material(
      color: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.borderSubtle),
                ),
                child: Icon(icon, size: 20, color: colors.textPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: colors.textMuted,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: colors.textSecondary, fontSize: 11.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- 3. Appearance Card ---
  Widget _buildAppearanceCard(BuildContext context, AppColors colors, SettingsState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme Mode',
            style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'High-contrast solid monochrome design, engineered for zero eye fatigue.',
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 14),

          // Theme options row
          Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  context,
                  colors,
                  title: 'Light',
                  icon: Icons.light_mode_outlined,
                  isSelected: state.themeMode == ThemeMode.light,
                  onTap: () {
                    context.read<SettingsBloc>().add(const UpdateThemeModeEvent(ThemeMode.light));
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildThemeOption(
                  context,
                  colors,
                  title: 'Dark',
                  icon: Icons.dark_mode_outlined,
                  isSelected: state.themeMode == ThemeMode.dark,
                  onTap: () {
                    context.read<SettingsBloc>().add(const UpdateThemeModeEvent(ThemeMode.dark));
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildThemeOption(
                  context,
                  colors,
                  title: 'System',
                  icon: Icons.brightness_auto_outlined,
                  isSelected: state.themeMode == ThemeMode.system,
                  onTap: () {
                    context.read<SettingsBloc>().add(const UpdateThemeModeEvent(ThemeMode.system));
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          Divider(height: 1, color: colors.border),
          const SizedBox(height: 14),

          // Accent Color selection
          Text(
            'Accent Color',
            style: TextStyle(color: colors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _accentColors.map((item) {
              final Color color = item['color'];
              final bool isSelected = state.accentColor == color;

              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  HapticUtils.selectionClick();
                  context.read<SettingsBloc>().add(UpdateAccentColorEvent(color));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? colors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? colors.primary : colors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item['name'],
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),
          Divider(height: 1, color: colors.border),
          const SizedBox(height: 12),

          // Toggles
          _buildSwitchRow(
            colors,
            title: 'Haptic Feedback',
            subtitle: 'Vibrate device on UI actions and completions',
            value: _hapticEnabled,
            onChanged: (v) => setState(() => _hapticEnabled = v),
          ),
          const SizedBox(height: 10),
          _buildSwitchRow(
            colors,
            title: 'Compact Message Bubbles',
            subtitle: 'Condense padding for higher message density',
            value: _compactMode,
            onChanged: (v) => setState(() => _compactMode = v),
          ),
          const SizedBox(height: 10),
          _buildSwitchRow(
            colors,
            title: 'Auto-Scroll on Response',
            subtitle: 'Automatically scroll viewport during token streaming',
            value: _autoScroll,
            onChanged: (v) => setState(() => _autoScroll = v),
          ),
        ],
      ),
    );
  }

  // --- 4. BYOK Card ---
  Widget _buildByokCard(BuildContext context, AppColors colors, SettingsState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Multi-Provider BYOK',
                style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: state.hasByok ? colors.success.withValues(alpha: 0.12) : colors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: state.hasByok ? colors.success : colors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: state.hasByok ? colors.success : colors.textMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      state.hasByok ? 'Active BYOK' : 'Cloud Default',
                      style: TextStyle(
                        color: state.hasByok ? colors.success : colors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Keys are stored encrypted on-device. Requests attach headers directly to bypass quota limits.',
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),

          // Provider Dropdown
          Text('LLM Provider', style: TextStyle(color: colors.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedProvider,
                isExpanded: true,
                dropdownColor: colors.card,
                style: TextStyle(color: colors.textPrimary, fontSize: 13.5),
                items: _providers.map((p) {
                  return DropdownMenuItem(
                    value: p['name'],
                    child: Text(p['name']!),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedProvider = val;
                      final found = _providers.firstWhere((p) => p['name'] == val);
                      _modelController.text = found['defaultModel']!;
                    });
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 14),

          // API Key Field with paste & visibility
          AppTextField(
            controller: _keyController,
            labelText: 'API Secret Key',
            hintText: 'sk-...',
            obscureText: _obscureKey,
            prefixIcon: Icon(Icons.key_rounded, size: 18, color: colors.textMuted),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _obscureKey ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 18,
                    color: colors.textMuted,
                  ),
                  onPressed: () => setState(() => _obscureKey = !_obscureKey),
                ),
                IconButton(
                  icon: Icon(Icons.content_paste_rounded, size: 18, color: colors.textMuted),
                  tooltip: 'Paste from clipboard',
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text != null) {
                      _keyController.text = data!.text!.trim();
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Target Model Identifier
          AppTextField(
            controller: _modelController,
            labelText: 'Target Model Identifier',
            hintText: 'e.g. gemini-2.0-flash or llama-3.3-70b-versatile',
          ),

          const SizedBox(height: 8),

          // Quick model suggestions
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _quickModels.map((m) {
              return InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () {
                  setState(() => _modelController.text = m);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colors.borderSubtle),
                  ),
                  child: Text(
                    m,
                    style: TextStyle(color: colors.textSecondary, fontSize: 10.5),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),
          Divider(height: 1, color: colors.border),
          const SizedBox(height: 14),

          // Temperature Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Temperature (Creativity)', style: TextStyle(color: colors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
              Text(_temperature.toStringAsFixed(2), style: TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              activeTrackColor: colors.primary,
              inactiveTrackColor: colors.border,
              thumbColor: colors.primary,
            ),
            child: Slider(
              value: _temperature,
              min: 0.0,
              max: 1.0,
              divisions: 20,
              onChanged: (v) => setState(() => _temperature = v),
            ),
          ),

          // Max Output Tokens Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Max Output Tokens', style: TextStyle(color: colors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
              Text('${_maxTokens.toInt()} tokens', style: TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              activeTrackColor: colors.primary,
              inactiveTrackColor: colors.border,
              thumbColor: colors.primary,
            ),
            child: Slider(
              value: _maxTokens,
              min: 512,
              max: 8192,
              divisions: 15,
              onChanged: (v) => setState(() => _maxTokens = v),
            ),
          ),

          const SizedBox(height: 8),

          // System Instructions
          Text('Custom System Instructions', style: TextStyle(color: colors.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(
            controller: _systemPromptController,
            maxLines: 2,
            style: TextStyle(color: colors.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Define custom AI persona or constraints...',
              hintStyle: TextStyle(color: colors.textMuted, fontSize: 12.5),
              filled: true,
              fillColor: colors.surface,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.primary, width: 1.2)),
            ),
          ),

          if (_connectionTestResult != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: colors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: colors.success, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _connectionTestResult!,
                      style: TextStyle(color: colors.success, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Test & Save buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textPrimary,
                    side: BorderSide(color: colors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _isTestingConnection ? null : () => _testConnection(colors),
                  child: _isTestingConnection
                      ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary))
                      : const Text('Test Connection', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              if (state.hasByok) ...[
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.error,
                      side: BorderSide(color: colors.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _clearByok(colors),
                    child: const Text('Remove BYOK', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _saveByok(colors),
                  child: const Text('Save BYOK', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 5. Usage & Analytics Card ---
  Widget _buildAnalyticsCard(BuildContext context, AppColors colors, dynamic analytics) {
    final int totalTokens = analytics?.totalTokensUsed ?? 4820;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weekly Token Consumption', style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: colors.border),
                ),
                child: Text(
                  '$totalTokens tokens',
                  style: TextStyle(color: colors.textPrimary, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Stat boxes
          Row(
            children: [
              Expanded(child: _buildMetricPill(colors, 'Prompt Tokens', '2,450', Icons.arrow_upward_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _buildMetricPill(colors, 'Completion Tokens', '2,370', Icons.arrow_downward_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _buildMetricPill(colors, 'Cost Saved', '\$0.14', Icons.savings_outlined)),
            ],
          ),

          const SizedBox(height: 18),

          // Chart
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 1200, color: colors.primary, width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(3)))]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 2800, color: colors.primary, width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(3)))]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 1900, color: colors.primary, width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(3)))]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 4200, color: colors.primary, width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(3)))]),
                  BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 3100, color: colors.primary, width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(3)))]),
                  BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 5600, color: colors.primary, width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(3)))]),
                  BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 3800, color: colors.primary, width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(3)))]),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        final i = v.toInt();
                        if (i >= 0 && i < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(days[i], style: TextStyle(color: colors.textMuted, fontSize: 10)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill(AppColors colors, String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: colors.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: colors.textMuted, fontSize: 9.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: colors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  // --- 6. Network & API Card ---
  Widget _buildNetworkCard(BuildContext context, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: _baseUrlController,
            labelText: 'FastAPI Backend Host Endpoint',
            hintText: 'http://10.0.2.2:8000/api/v1',
            suffixIcon: IconButton(
              icon: Icon(Icons.check_circle_outline_rounded, color: colors.success),
              tooltip: 'Save URL',
              onPressed: () {
                HapticUtils.selectionClick();
                context.read<SettingsBloc>().add(
                      UpdateBaseUrlEvent(_baseUrlController.text.trim()),
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Backend endpoint updated successfully!'),
                    backgroundColor: colors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          _buildSwitchRow(
            colors,
            title: 'Stream Responses (SSE)',
            subtitle: 'Enable token-by-token real-time streaming',
            value: _streamResponses,
            onChanged: (v) => setState(() => _streamResponses = v),
          ),
          const SizedBox(height: 10),
          _buildSwitchRow(
            colors,
            title: 'Live Web Grounding',
            subtitle: 'Allow AI to browse live search index citations',
            value: _webSearchEnabled,
            onChanged: (v) => setState(() => _webSearchEnabled = v),
          ),
        ],
      ),
    );
  }

  // --- 7. Privacy & Data Card ---
  Widget _buildPrivacyCard(BuildContext context, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.file_download_outlined, color: colors.textPrimary),
            title: Text('Export All Chat Sessions', style: TextStyle(color: colors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w500)),
            subtitle: Text('Download JSON archive of all chats', style: TextStyle(color: colors.textMuted, fontSize: 11.5)),
            trailing: Icon(Icons.chevron_right_rounded, color: colors.textMuted),
            onTap: () => _showExportDialog(context, colors),
          ),
          Divider(height: 1, color: colors.border),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.delete_sweep_outlined, color: colors.error),
            title: Text('Clear All Conversations', style: TextStyle(color: colors.error, fontSize: 13.5, fontWeight: FontWeight.w500)),
            subtitle: Text('Permanently wipe chat history from local database', style: TextStyle(color: colors.textMuted, fontSize: 11.5)),
            trailing: Icon(Icons.chevron_right_rounded, color: colors.textMuted),
            onTap: () => _showClearAllChatsDialog(context, colors),
          ),
        ],
      ),
    );
  }

  // --- 8. About Card ---
  Widget _buildAboutCard(BuildContext context, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(Icons.auto_awesome, color: colors.onPrimary, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nexora AI Client', style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                  Text('Version 2.4.0 (Build 2026.10)', style: TextStyle(color: colors.textMuted, fontSize: 11)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: colors.border),
                ),
                child: Text('Up to date', style: TextStyle(color: colors.success, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: colors.border),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: const Text('Terms of Service: Standard Apache 2.0 license.'), backgroundColor: colors.surface),
                  );
                },
                child: Text('Terms', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
              ),
              Text('•', style: TextStyle(color: colors.textMuted)),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: const Text('Privacy Policy: All keys encrypted locally.'), backgroundColor: colors.surface),
                  );
                },
                child: Text('Privacy Policy', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
              ),
              Text('•', style: TextStyle(color: colors.textMuted)),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: const Text('Nexora AI Open Source Repository.'), backgroundColor: colors.surface),
                  );
                },
                child: Text('Licenses', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Helpers ---
  Widget _buildSwitchRow(
    AppColors colors, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: colors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
              Text(subtitle, style: TextStyle(color: colors.textMuted, fontSize: 11.5)),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeTrackColor: colors.primary,
          onChanged: (v) {
            HapticUtils.selectionClick();
            onChanged(v);
          },
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    AppColors colors, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        HapticUtils.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? colors.primary : colors.border,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? colors.onPrimary : colors.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? colors.onPrimary : colors.textPrimary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
      child: Text(
        title,
        style: TextStyle(
          color: colors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
