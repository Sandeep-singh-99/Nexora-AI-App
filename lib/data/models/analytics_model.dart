import '../../domain/entities/analytics_entity.dart';

class AnalyticsModel extends AnalyticsEntity {
  const AnalyticsModel({
    required super.totalRequests,
    required super.totalTokensUsed,
    required super.dailyUsage,
    required super.providerBreakdown,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    final daily = ((json['daily_usage'] ?? json['daily']) as List?)?.map((d) {
          final m = d as Map<String, dynamic>;
          return DailyTokenUsage(
            date: m['date'] as String? ?? '',
            promptTokens: m['prompt_tokens'] as int? ?? 0,
            completionTokens: m['completion_tokens'] as int? ?? 0,
            totalTokens: m['total_tokens'] as int? ??
                ((m['prompt_tokens'] as int? ?? 0) + (m['completion_tokens'] as int? ?? 0)),
          );
        }).toList() ??
        [];

    final providers = ((json['provider_breakdown'] ?? json['providers']) as List?)?.map((p) {
          final m = p as Map<String, dynamic>;
          return ProviderBreakdown(
            provider: m['provider'] as String? ?? 'Gemini',
            requestsCount: m['requests_count'] as int? ?? 0,
            totalTokens: m['total_tokens'] as int? ?? 0,
          );
        }).toList() ??
        [];

    return AnalyticsModel(
      totalRequests: json['total_requests'] as int? ?? 0,
      totalTokensUsed: json['total_tokens_used'] as int? ?? json['total_tokens'] as int? ?? 0,
      dailyUsage: daily,
      providerBreakdown: providers,
    );
  }
}
