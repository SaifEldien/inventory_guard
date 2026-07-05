import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Based on OA Digital style)
  static const Color primary = Color(0xFF0F172A); // Deep Navy/Black
  static const Color accent = Color(0xFF2563EB);  // Vibrant Blue
  
  // Background & Surface
  static const Color background = Color(0xFFF8FAFC); // Very light slate
  static const Color surface = Colors.white;
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color sidebarBackground = Color(0xFF0F172A); // Dark sidebar is very "modern dashboard"
  
  // Action Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Typography
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  
  // Legacy mappings for compatibility
  static const Color digitalBlue = accent;
  static const Color deepNavy = primary;
  static const Color backgroundDark = background;
  static const Color surfaceDark = surface;
  static const Color errorRed = error;
  static const Color successGreen = success;
  static const Color warningOrange = warning;
}
