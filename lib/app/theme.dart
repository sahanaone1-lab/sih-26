import 'package:flutter/material.dart';

/// AppColors defines the color tokens for MediKiosk across Light and Dark themes.
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

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0B132B);
  static const Color darkSurface = Color(0xFF111E38);
  static const Color darkSurfaceBorder = Color(0xFF1E2E4F);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);
  static const Color darkNavyLight = Color(0xFF2563EB);

  // Saffron / Orange Accent (Primary actions & AYUSH Identity)
  static const Color saffronPrimary = Color(0xFFFF671F);
  static const Color saffronDark = Color(0xFFE0530B);
  static const Color saffronLight = Color(0xFFFFF2EC);
  static const Color darkSaffronLight = Color(0xFF381A0A);

  // India Green Accent (Health, verified status)
  static const Color greenSuccess = Color(0xFF046A38);
  static const Color greenLight = Color(0xFFEDF7F2);
  static const Color darkGreenLight = Color(0xFF0D331D);

  // General Neutrals
  static const Color divider = Color(0xFFE2E8F0);
  static const Color darkDivider = Color(0xFF1E2E4F);
  static const Color cardShadow = Color(0x0F0A192F);
}

/// AppTheme provides complete Light and Dark ThemeData for Flutter Material 3.
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

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.saffronPrimary,
        onPrimary: Colors.white,
        secondary: AppColors.navyLight,
        onSecondary: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: Color(0xFFEF4444),
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(color: AppColors.darkSurfaceBorder),
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
          foregroundColor: AppColors.darkTextPrimary,
          side: const BorderSide(color: AppColors.darkSurfaceBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.darkSurfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.darkSurfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.saffronPrimary, width: 1.5),
        ),
      ),
    );
  }
}

/// Dynamic Theme Mode Manager (supports System default + manual toggle)
class ThemeController extends ChangeNotifier {
  static final ThemeController instance = ThemeController._internal();
  factory ThemeController() => instance;
  ThemeController._internal();

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void toggleTheme(BuildContext context) {
    final isCurrentDark = _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);
    setThemeMode(isCurrentDark ? ThemeMode.light : ThemeMode.dark);
  }
}
