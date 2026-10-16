import 'package:flutter/material.dart';
import 'app_colors.dart';

export 'app_colors.dart';

class ColorPalette {
  ColorPalette._();

  static AppColors of(BuildContext context) => AppColors.of(context);

  // Solid, clean backgrounds (zero purple, zero neon)
  static const Color obsidianBackground = Color(0xFF0E1116);
  static const Color elevatedSurface = Color(0xFF161920);
  static const Color elevatedCard = Color(0xFF1B1E26);
  static const Color elevatedCardHover = Color(0xFF242833);
  static const Color subtleBorder = Color(0xFF282C37);
  static const Color lighterBorder = Color(0xFF323745);

  // Text colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Clean, neutral accents (replaces fancy neon violet/indigo/cyan)
  static const Color indigoAccent = Color(0xFF3B82F6); // Clean neutral slate blue
  static const Color violetAccent = Color(0xFF64748B); // Clean slate gray
  static const Color emeraldAccent = Color(0xFF22C55E); // Clean emerald
  static const Color amberAccent = Color(0xFFF59E0B); // Clean amber
  static const Color cyanAccent = Color(0xFF0284C7); // Clean sky blue
  static const Color roseAccent = Color(0xFFE11D48); // Clean rose/red

  // Status colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Bubble colors
  static const Color userBubble = Color(0xFF242833);
  static const Color aiBubble = Color(0xFF161920);

  // Clean overlays
  static Color glassBackground = const Color(0xFF161920);
  static Color glassBorder = const Color(0xFF282C37);
}
