import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color card;
  final Color cardHover;
  final Color border;
  final Color borderSubtle;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color primary;
  final Color onPrimary;
  final Color userBubble;
  final Color onUserBubble;
  final Color aiBubble;
  final Color onAiBubble;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  const AppColors({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.card,
    required this.cardHover,
    required this.border,
    required this.borderSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.primary,
    required this.onPrimary,
    required this.userBubble,
    required this.onUserBubble,
    required this.aiBubble,
    required this.onAiBubble,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  bool get isDark => brightness == Brightness.dark;

  static AppColors of(BuildContext context) {
    return Theme.of(context).extension<AppColors>() ??
        (Theme.of(context).brightness == Brightness.dark ? dark : light);
  }

  /// Clean, modern light theme - crisp, solid, zero gradients, zero neon colors
  static const AppColors light = AppColors(
    brightness: Brightness.light,
    background: Color(0xFFF9FAFB), // Clean off-white
    surface: Color(0xFFF3F4F6),    // Cool subtle gray
    card: Color(0xFFFFFFFF),       // Pure white card
    cardHover: Color(0xFFE5E7EB),  // Subtle hover gray
    border: Color(0xFFE2E8F0),     // Clean 1px solid border
    borderSubtle: Color(0xFFF1F5F9),
    textPrimary: Color(0xFF0F172A), // Crisp slate-900 black
    textSecondary: Color(0xFF475569), // Slate-600
    textMuted: Color(0xFF94A3B8),     // Slate-400
    primary: Color(0xFF0F172A),       // Solid slate charcoal
    onPrimary: Color(0xFFFFFFFF),     // Pure white
    userBubble: Color(0xFF0F172A),    // Clean dark slate user bubble
    onUserBubble: Color(0xFFFFFFFF),
    aiBubble: Color(0xFFFFFFFF),      // Clean white AI card bubble
    onAiBubble: Color(0xFF0F172A),
    success: Color(0xFF16A34A),       // Functional forest emerald
    warning: Color(0xFFD97706),       // Functional amber
    error: Color(0xFFDC2626),         // Functional crimson
    info: Color(0xFF2563EB),          // Functional deep blue
  );

  /// Clean, modern dark theme - matte charcoal/graphite, zero gradients, zero neon colors
  static const AppColors dark = AppColors(
    brightness: Brightness.dark,
    background: Color(0xFF0E1116), // Solid deep charcoal black
    surface: Color(0xFF161920),    // Solid dark surface
    card: Color(0xFF1B1E26),       // Solid container card
    cardHover: Color(0xFF242833),  // Solid hover/active state
    border: Color(0xFF282C37),     // Clean subtle border
    borderSubtle: Color(0xFF1E212B),
    textPrimary: Color(0xFFF8FAFC), // Pure crisp white
    textSecondary: Color(0xFF94A3B8), // Slate-400
    textMuted: Color(0xFF64748B),     // Slate-500
    primary: Color(0xFFF8FAFC),       // Clean solid white primary
    onPrimary: Color(0xFF0E1116),     // Deep contrast text
    userBubble: Color(0xFF242833),    // Solid graphite user bubble
    onUserBubble: Color(0xFFF8FAFC),
    aiBubble: Color(0xFF161920),      // Solid dark surface AI bubble
    onAiBubble: Color(0xFFF8FAFC),
    success: Color(0xFF22C55E),       // Functional emerald
    warning: Color(0xFFF59E0B),       // Functional amber
    error: Color(0xFFEF4444),         // Functional red
    info: Color(0xFF3B82F6),          // Functional blue
  );

  @override
  ThemeExtension<AppColors> copyWith({
    Brightness? brightness,
    Color? background,
    Color? surface,
    Color? card,
    Color? cardHover,
    Color? border,
    Color? borderSubtle,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? primary,
    Color? onPrimary,
    Color? userBubble,
    Color? onUserBubble,
    Color? aiBubble,
    Color? onAiBubble,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
  }) {
    return AppColors(
      brightness: brightness ?? this.brightness,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      cardHover: cardHover ?? this.cardHover,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      userBubble: userBubble ?? this.userBubble,
      onUserBubble: onUserBubble ?? this.onUserBubble,
      aiBubble: aiBubble ?? this.aiBubble,
      onAiBubble: onAiBubble ?? this.onAiBubble,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardHover: Color.lerp(cardHover, other.cardHover, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      userBubble: Color.lerp(userBubble, other.userBubble, t)!,
      onUserBubble: Color.lerp(onUserBubble, other.onUserBubble, t)!,
      aiBubble: Color.lerp(aiBubble, other.aiBubble, t)!,
      onAiBubble: Color.lerp(onAiBubble, other.onAiBubble, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

extension AppColorsBuildContextExtension on BuildContext {
  AppColors get colors => AppColors.of(this);
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
