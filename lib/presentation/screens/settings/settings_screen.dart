import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
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

  String _selectedProvider = 'Google Gemini';

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
        content: const Text('BYOK Keys saved securely! Headers will be attached to AI requests.'),
        backgroundColor: colors.success,
      ),
    );
  }

  void _clearByok(AppColors colors) {
    HapticUtils.mediumImpact();
    _keyController.clear();
    context.read<SettingsBloc>().add(ClearByokSettingsEvent());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('BYOK Keys removed. Reverting to prebuilt cloud inferences.'),
        backgroundColor: colors.cardHover,
      ),
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
        title: Text(
          'Settings & Appearance',
          style: TextStyle(color: colors.textPrimary),
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final analytics = state.analytics;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Appearance & Theme Section
              _buildSectionHeader('APPEARANCE & THEME', colors),
              Container(
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
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Solid, clean, high-contrast monochrome design with zero gradients.',
                      style: TextStyle(color: colors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
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
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // BYOK (Bring Your Own Key) Section
              _buildSectionHeader('BRING YOUR OWN KEY (BYOK)', colors),
              Container(
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
                      'Multi-Provider Custom Inference',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Store keys encrypted in secure hardware storage. Bypasses shared cloud quotas.',
                      style: TextStyle(color: colors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 16),

                    // Provider Dropdown
                    Text('LLM Provider', style: TextStyle(color: colors.textSecondary, fontSize: 13)),
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
                          style: TextStyle(color: colors.textPrimary, fontSize: 14),
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

                    AppTextField(
                      controller: _keyController,
                      labelText: 'API Secret Key',
                      hintText: 'sk-...',
                      obscureText: true,
                      prefixIcon: Icon(Icons.key, size: 18, color: colors.textMuted),
                    ),
                    const SizedBox(height: 14),

                    AppTextField(
                      controller: _modelController,
                      labelText: 'Target Model Identifier',
                      hintText: 'e.g. llama-3.3-70b-versatile',
                    ),
                    const SizedBox(height: 18),

                    Row(
                      children: [
                        if (state.hasByok) ...[
                          Expanded(
                            child: AppButton(
                              text: 'Remove BYOK',
                              variant: ButtonVariant.danger,
                              onPressed: () => _clearByok(colors),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: AppButton(
                            text: 'Save BYOK',
                            icon: Icon(Icons.lock_outline, size: 16, color: colors.onPrimary),
                            onPressed: () => _saveByok(colors),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Usage Analytics Section
              _buildSectionHeader('USAGE & TOKEN ANALYTICS', colors),
              Container(
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
                          'Weekly Token Consumption',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: colors.border),
                          ),
                          child: Text(
                            '${analytics?.totalTokensUsed ?? 0} tokens',
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Chart - Clean monochromatic bars, no gradients
                    SizedBox(
                      height: 160,
                      child: BarChart(
                        BarChartData(
                          barGroups: [
                            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 1200, color: colors.primary, width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(3)))]),
                            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 2800, color: colors.primary, width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(3)))]),
                            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 1900, color: colors.primary, width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(3)))]),
                            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 4200, color: colors.primary, width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(3)))]),
                            BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 3100, color: colors.primary, width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(3)))]),
                            BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 5600, color: colors.primary, width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(3)))]),
                            BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 3800, color: colors.primary, width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(3)))]),
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
              ),

              const SizedBox(height: 24),

              // Network & Environment
              _buildSectionHeader('API ENVIRONMENT', colors),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  children: [
                    AppTextField(
                      controller: _baseUrlController,
                      labelText: 'FastAPI Backend URL',
                      hintText: 'http://10.0.2.2:8000/api/v1',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.check, color: colors.success),
                        onPressed: () {
                          context.read<SettingsBloc>().add(
                                UpdateBaseUrlEvent(_baseUrlController.text.trim()),
                              );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Account & Logout
              AppButton(
                text: 'Sign Out',
                variant: ButtonVariant.danger,
                icon: const Icon(Icons.logout, size: 16, color: Colors.white),
                onPressed: () {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                },
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
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
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
