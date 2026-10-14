import 'package:flutter/material.dart';

class ColorPalette {
  ColorPalette._();

  // Dark obsidian backgrounds
  static const Color obsidianBackground = Color(0xFF0A0D14);
  static const Color elevatedSurface = Color(0xFF121826);
  static const Color elevatedCard = Color(0xFF161E30);
  static const Color elevatedCardHover = Color(0xFF1E283F);
  static const Color subtleBorder = Color(0xFF1F293D);
  static const Color lighterBorder = Color(0xFF2C3953);

  // Text colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Custom Primary Accents
  static const Color indigoAccent = Color(0xFF6366F1);
  static const Color violetAccent = Color(0xFF8B5CF6);
  static const Color emeraldAccent = Color(0xFF10B981);
  static const Color amberAccent = Color(0xFFF59E0B);
  static const Color cyanAccent = Color(0xFF06B6D4);
  static const Color roseAccent = Color(0xFFF43F5E);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Bubble colors
  static const Color userBubble = Color(0xFF2E3856);
  static const Color aiBubble = Color(0xFF121826);

  // Glassmorphic overlays
  static Color glassBackground = const Color(0xFF121826).withValues(alpha: 0.75);
  static Color glassBorder = Colors.white.withValues(alpha: 0.08);
}
