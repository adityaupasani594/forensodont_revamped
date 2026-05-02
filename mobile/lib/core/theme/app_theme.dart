import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF00D4FF);
  static const background = Color(0xFF0A0E14);
  static const surface = Color(0xFF131A24);
  static const card = Color(0xFF1A2332);
  static const error = Color(0xFFFF3B30);
  static const warning = Color(0xFFFF9500);
  static const success = Color(0xFF34C759);
  static const textPrimary = Color(0xFFE8EDF5);
  static const textSecondary = Color(0xFF8896AA);
  static const border = Color(0xFF1E2D40);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: Colors.black,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        secondary: AppColors.primary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.getFont('Space Grotesk', color: AppColors.textPrimary),
        displayMedium: GoogleFonts.getFont('Space Grotesk', color: AppColors.textPrimary),
        displaySmall: GoogleFonts.getFont('Space Grotesk', color: AppColors.textPrimary),
        headlineLarge: GoogleFonts.getFont('Space Grotesk', color: AppColors.textPrimary),
        headlineMedium: GoogleFonts.getFont('Space Grotesk', color: AppColors.textPrimary),
        headlineSmall: GoogleFonts.getFont('Space Grotesk', color: AppColors.textPrimary),
        titleLarge: GoogleFonts.getFont('Space Grotesk', color: AppColors.textPrimary),
        titleMedium: GoogleFonts.getFont('Space Grotesk', color: AppColors.textPrimary),
        titleSmall: GoogleFonts.getFont('Space Grotesk', color: AppColors.textPrimary),
        bodyLarge: GoogleFonts.getFont('IBM Plex Mono', color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.getFont('IBM Plex Mono', color: AppColors.textSecondary),
        bodySmall: GoogleFonts.getFont('IBM Plex Mono', color: AppColors.textSecondary),
        labelLarge: GoogleFonts.getFont('IBM Plex Mono', color: AppColors.textPrimary),
        labelMedium: GoogleFonts.getFont('IBM Plex Mono', color: AppColors.textSecondary),
        labelSmall: GoogleFonts.getFont('IBM Plex Mono', color: AppColors.textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Space Grotesk',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          textStyle: GoogleFonts.getFont('Space Grotesk', fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
