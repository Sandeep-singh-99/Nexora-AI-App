import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/color_palette.dart';
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

  void _saveByok() {
    HapticUtils.heavyImpact();
    context.read<SettingsBloc>().add(
          SaveByokSettingsEvent(
            provider: _selectedProvider,
            key: _keyController.text.trim(),
            model: _modelController.text.trim(),
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('BYOK Keys saved securely! Headers will be attached to AI requests.'),
        backgroundColor: ColorPalette.emeraldAccent,
      ),
    );
  }

  void _clearByok() {
    HapticUtils.mediumImpact();
    _keyController.clear();
    context.read<SettingsBloc>().add(ClearByokSettingsEvent());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('BYOK Keys removed. Reverting to prebuilt cloud inferences.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.obsidianBackground,
      appBar: AppBar(
        title: const Text('Settings & BYOK'),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final analytics = state.analytics;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // BYOK (Bring Your Own Key) Section
              _buildSectionHeader('BRING YOUR OWN KEY (BYOK)'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorPalette.elevatedSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ColorPalette.subtleBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Multi-Provider Custom Inference',
                      style: TextStyle(
                        color: ColorPalette.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Store keys encrypted in secure hardware storage. Bypasses shared cloud quotas.',
                      style: TextStyle(color: ColorPalette.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 16),

                    // Provider Dropdown
                    const Text('LLM Provider', style: TextStyle(color: ColorPalette.textSecondary, fontSize: 13)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: ColorPalette.obsidianBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ColorPalette.subtleBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedProvider,
                          isExpanded: true,
                          dropdownColor: ColorPalette.elevatedSurface,
                          style: const TextStyle(color: ColorPalette.textPrimary, fontSize: 14),
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
                      prefixIcon: const Icon(Icons.key, size: 18, color: ColorPalette.textMuted),
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
                              onPressed: _clearByok,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: AppButton(
                            text: 'Save BYOK',
                            icon: const Icon(Icons.lock_outline, size: 16, color: Colors.white),
                            onPressed: _saveByok,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Usage Analytics Section
              _buildSectionHeader('USAGE & TOKEN ANALYTICS'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorPalette.elevatedSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ColorPalette.subtleBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Weekly Token Consumption',
                          style: TextStyle(
                            color: ColorPalette.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: ColorPalette.indigoAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${analytics?.totalTokensUsed ?? 0} tokens',
                            style: const TextStyle(
                              color: ColorPalette.indigoAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Chart
                    SizedBox(
                      height: 160,
                      child: BarChart(
                        BarChartData(
                          barGroups: [
                            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 1200, color: ColorPalette.indigoAccent, width: 12)]),
                            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 2800, color: ColorPalette.indigoAccent, width: 12)]),
                            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 1900, color: ColorPalette.indigoAccent, width: 12)]),
                            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 4200, color: ColorPalette.indigoAccent, width: 12)]),
                            BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 3100, color: ColorPalette.indigoAccent, width: 12)]),
                            BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 5600, color: ColorPalette.indigoAccent, width: 12)]),
                            BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 3800, color: ColorPalette.indigoAccent, width: 12)]),
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
                                      child: Text(days[i], style: const TextStyle(color: ColorPalette.textMuted, fontSize: 10)),
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
              _buildSectionHeader('API ENVIRONMENT'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorPalette.elevatedSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ColorPalette.subtleBorder),
                ),
                child: Column(
                  children: [
                    AppTextField(
                      controller: _baseUrlController,
                      labelText: 'FastAPI Backend URL',
                      hintText: 'http://10.0.2.2:8000/api/v1',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.check, color: ColorPalette.emeraldAccent),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
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
}
