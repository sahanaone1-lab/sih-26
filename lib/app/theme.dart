import 'package:flutter/material.dart';

/// AppColors defines the color system for the Medical App.
/// 
/// Developed for Smart India Hackathon (SIH) in an Indian public-health context.
/// Visual identity features:
/// - Primary background: Pure White
/// - Text & structural elements: Deep Navy Blue
/// - Action & highlight accent: Saffron / Orange
/// - Verified & health status accent: India Green
abstract class AppColors {
  // Primary Backgrounds
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color surfaceBorder = Color(0xFFE2E8F0);

  // Deep Navy Colors (Primary text, branding & structural identity)
  static const Color navyPrimary = Color(0xFF0A192F);
  static const Color navyDark = Color(0xFF040D1A);
  static const Color navyLight = Color(0xFF1E3A8A);
  static const Color textPrimary = Color(0xFF0A192F);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  // Saffron / Orange Accent Colors (Primary actions & highlights)
  static const Color saffronPrimary = Color(0xFFFF671F);
  static const Color saffronDark = Color(0xFFE0530B);
  static const Color saffronLight = Color(0xFFFFF2EC);

  // Green Accent Colors (Positive, verified, health status)
  static const Color greenSuccess = Color(0xFF046A38);
  static const Color greenLight = Color(0xFFEDF7F2);

  // Neutral Tints & Decorative Elements
  static const Color divider = Color(0xFFE2E8F0);
  static const Color cardShadow = Color(0x0F0A192F);
}
