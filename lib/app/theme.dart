import 'package:flutter/material.dart';

/// AppColors defines the color tokens for MediKiosk (Light Theme only).
/// Developed for Smart India Hackathon (SIH) in an Indian public-health context.
abstract class AppColors {
  // Light Mode Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color surfaceBorder = Color(0xFFE2E8F0);

  static const Color navyPrimary = Color(0xFF0A192F);
  static const Color navyDark = Color(0xFF040D1A);
  static const Color navyLight = Color(0xFF1E3A8A);
  static const Color textPrimary = Color(0xFF0A192F);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  // Saffron / Orange Accent (Primary actions & AYUSH Identity)
  static const Color saffronPrimary = Color(0xFFFF671F);
  static const Color saffronDark = Color(0xFFE0530B);
  static const Color saffronLight = Color(0xFFFFF2EC);

  // India Green Accent (Health, verified status)
  static const Color greenSuccess = Color(0xFF046A38);
  static const Color greenLight = Color(0xFFEDF7F2);

  // General Neutrals
  static const Color divider = Color(0xFFE2E8F0);
  static const Color cardShadow = Color(0x0F0A192F);
}

/// AppTheme provides the Light ThemeData for Flutter Material 3.
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.saffronPrimary,
        onPrimary: Colors.white,
        secondary: AppColors.navyPrimary,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: Color(0xFFDC2626),
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.navyPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.background,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.saffronPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navyPrimary,
          side: const BorderSide(color: AppColors.surfaceBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.saffronPrimary, width: 1.5),
        ),
      ),
    );
  }
}
