import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
    );

    return baseTheme.copyWith(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),

      textTheme: GoogleFonts.plusJakartaSansTextTheme(baseTheme.textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 48,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
        ),
        displayMedium: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
        titleLarge: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          color: AppColors.textSecondary,
          fontSize: 16,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.6,
        ),
      ),
    );
  }

  // Legacy support - map darkTheme to lightTheme for now to avoid breaking changes
  static ThemeData get darkTheme => lightTheme;
}
