import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_palette.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ColorPalette.obsidianBackground,
      primaryColor: ColorPalette.indigoAccent,
      canvasColor: ColorPalette.elevatedSurface,
      cardColor: ColorPalette.elevatedCard,
      dividerColor: ColorPalette.subtleBorder,
      colorScheme: const ColorScheme.dark(
        primary: ColorPalette.indigoAccent,
        secondary: ColorPalette.violetAccent,
        surface: ColorPalette.elevatedSurface,
        error: ColorPalette.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: ColorPalette.textPrimary,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
              displayLarge: const TextStyle(
                color: ColorPalette.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
              headlineMedium: const TextStyle(
                color: ColorPalette.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              titleLarge: const TextStyle(
                color: ColorPalette.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              titleMedium: const TextStyle(
                color: ColorPalette.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              bodyLarge: const TextStyle(
                color: ColorPalette.textPrimary,
                fontSize: 15,
                height: 1.5,
              ),
              bodyMedium: const TextStyle(
                color: ColorPalette.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
              bodySmall: const TextStyle(
                color: ColorPalette.textMuted,
                fontSize: 11,
              ),
            ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorPalette.obsidianBackground,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: ColorPalette.textPrimary),
        titleTextStyle: TextStyle(
          color: ColorPalette.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: ColorPalette.obsidianBackground,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ColorPalette.elevatedSurface,
        modalBackgroundColor: ColorPalette.elevatedSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: ColorPalette.elevatedSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ColorPalette.subtleBorder),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ColorPalette.elevatedCardHover,
        contentTextStyle: const TextStyle(color: ColorPalette.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: ColorPalette.subtleBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorPalette.elevatedSurface,
        hintStyle: const TextStyle(color: ColorPalette.textMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.subtleBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.subtleBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.indigoAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.error),
        ),
      ),
    );
  }
}
