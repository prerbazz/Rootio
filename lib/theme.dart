import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF2D6A2D);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B4D1B);
  static const Color background = Color(0xFFF5FFF5);
  static const Color surface = Colors.white;
  static const Color cardBorder = Color(0xFFE0E0E0);
  static const Color selectedBorder = Color(0xFF2D6A2D);
  static const Color selectedBg = Color(0xFFEEF7EE);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF999999);
  static const Color greenStreak = Color(0xFF2D6A2D);
  static const Color gold = Color(0xFFF5A623);
  static const Color progressBg = Color(0xFFE8F5E9);
  static const Color tagEasy = Color(0xFF4CAF50);
  static const Color tagMedium = Color(0xFFFF9800);
  static const Color tagHard = Color(0xFFE53935);

  // Goal card colors
  static const Color goalBlue = Color(0xFFEEF2FF);
  static const Color goalGreen = Color(0xFFEEF7EE);
  static const Color goalYellow = Color(0xFFFFFBEE);
  static const Color goalPurple = Color(0xFFF5EEFF);
  static const Color goalTeal = Color(0xFFEEFBF8);

  static const Color goalBlueBorder = Color(0xFFBBCCFF);
  static const Color goalGreenBorder = Color(0xFFB2DFDB);
  static const Color goalYellowBorder = Color(0xFFFFE082);
  static const Color goalPurpleBorder = Color(0xFFD1B3FF);
  static const Color goalTealBorder = Color(0xFFB2EBE0);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        background: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.interTextTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      useMaterial3: true,
    );
  }
}
