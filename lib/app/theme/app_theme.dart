import 'package:flutter/material.dart';
import 'app_colors.dart';

export 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    const c = AppColors.light;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: c.background,
      primaryColor: c.primary,
      canvasColor: c.surface,
      cardColor: c.card,
      dividerColor: c.border,
      fontFamily: 'Inter',
      extensions: const [c],
      colorScheme: ColorScheme.light(
        primary: c.primary,
        onPrimary: c.onPrimary,
        secondary: c.textSecondary,
        onSecondary: Colors.white,
        surface: c.card,
        onSurface: c.textPrimary,
        error: c.error,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: c.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: c.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: c.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: c.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: c.textPrimary,
          fontSize: 15,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: c.textSecondary,
          fontSize: 13,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          color: c.textMuted,
          fontSize: 11,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: c.textPrimary),
        titleTextStyle: TextStyle(
          color: c.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: c.background,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.card,
        modalBackgroundColor: c.card,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: c.border),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.primary,
        contentTextStyle: TextStyle(color: c.onPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        hintStyle: TextStyle(color: c.textMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.error),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    const c = AppColors.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: c.background,
      primaryColor: c.primary,
      canvasColor: c.surface,
      cardColor: c.card,
      dividerColor: c.border,
      fontFamily: 'Inter',
      extensions: const [c],
      colorScheme: ColorScheme.dark(
        primary: c.primary,
        onPrimary: c.onPrimary,
        secondary: c.textSecondary,
        onSecondary: Colors.black,
        surface: c.surface,
        onSurface: c.textPrimary,
        error: c.error,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: c.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: c.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: c.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: c.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: c.textPrimary,
          fontSize: 15,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: c.textSecondary,
          fontSize: 13,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          color: c.textMuted,
          fontSize: 11,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: c.textPrimary),
        titleTextStyle: TextStyle(
          color: c.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: c.background,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        modalBackgroundColor: c.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: c.border),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.cardHover,
        contentTextStyle: TextStyle(color: c.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: c.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        hintStyle: TextStyle(color: c.textMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.error),
        ),
      ),
    );
  }
}
