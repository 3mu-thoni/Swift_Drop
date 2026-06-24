import 'package:flutter/material.dart';

/// Provides semantic colors that automatically adapt to light/dark mode.
/// Use these instead of hardcoded Color(0xFF...) values in screens.
extension AppThemeColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // Backgrounds
  Color get bgPrimary =>
      isDark ? const Color(0xFF12121A) : const Color(0xFFF8F9FA);

  Color get bgSurface =>
      isDark ? const Color(0xFF1E1E2C) : Colors.white;

  Color get bgSurfaceVariant =>
      isDark ? const Color(0xFF2A2A3C) : const Color(0xFFF3F4F6);

  // Text
  Color get textPrimary =>
      isDark ? Colors.white : const Color(0xFF1A1A2E);

  Color get textSecondary =>
      isDark ? const Color(0xFFB0B7C3) : const Color(0xFF6B7280);

  // Borders
  Color get borderColor =>
      isDark ? const Color(0xFF2A2A3C) : const Color(0xFFEEEFF2);

  Color get borderColorLight =>
      isDark ? const Color(0xFF2A2A3C) : const Color(0xFFE5E7EB);

  // Brand (same in both modes)
  Color get brandPrimary => const Color(0xFFFF6B35);
  Color get brandSecondary => const Color(0xFF2EC4B6);

  // Status colors (same in both modes)
  Color get statusSuccess => const Color(0xFF22C55E);
  Color get statusError => const Color(0xFFEF4444);
  Color get statusWarning => const Color(0xFFF59E0B);
  Color get statusInfo => const Color(0xFF3B82F6);
}