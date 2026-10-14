import 'package:equatable/equatable.dart';

class DailyTokenUsage extends Equatable {
  final String date;
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  const DailyTokenUsage({
    required this.date,
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  @override
  List<Object?> get props => [date, promptTokens, completionTokens, totalTokens];
}

class ProviderBreakdown extends Equatable {
  final String provider;
  final int requestsCount;
  final int totalTokens;

  const ProviderBreakdown({
    required this.provider,
    required this.requestsCount,
    required this.totalTokens,
  });

  @override
  List<Object?> get props => [provider, requestsCount, totalTokens];
}

class AnalyticsEntity extends Equatable {
  final int totalRequests;
  final int totalTokensUsed;
  final List<DailyTokenUsage> dailyUsage;
  final List<ProviderBreakdown> providerBreakdown;

  const AnalyticsEntity({
    required this.totalRequests,
    required this.totalTokensUsed,
    required this.dailyUsage,
    required this.providerBreakdown,
  });

  @override
  List<Object?> get props => [totalRequests, totalTokensUsed, dailyUsage, providerBreakdown];
}
