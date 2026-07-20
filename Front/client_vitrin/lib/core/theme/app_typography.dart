import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized RTL Persian Typography specification using Vazirmatn font family
class AppTypography {
  AppTypography._();

  /// Title Large (Hero headlines)
  static TextStyle get titleLarge => GoogleFonts.vazirmatn(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  /// Title Medium (Card section titles)
  static TextStyle get titleMedium => GoogleFonts.vazirmatn(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.35,
      );

  /// Title Small (Subheaders / Card titles)
  static TextStyle get titleSmall => GoogleFonts.vazirmatn(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  /// Body Large (Prominent text)
  static TextStyle get bodyLarge => GoogleFonts.vazirmatn(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  /// Body Medium (Standard description text)
  static TextStyle get bodyMedium => GoogleFonts.vazirmatn(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  /// Body Small (Small text / subtitles)
  static TextStyle get bodySmall => GoogleFonts.vazirmatn(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        height: 1.4,
      );

  /// Label Large (Buttons / Badges)
  static TextStyle get labelLarge => GoogleFonts.vazirmatn(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  /// Label Medium (Pill badges, stat indicators)
  static TextStyle get labelMedium => GoogleFonts.vazirmatn(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  /// Ticker Marquee text
  static TextStyle get tickerText => GoogleFonts.vazirmatn(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 0.5,
      );

  /// Get standard RTL TextTheme
  static TextTheme get textTheme {
    return TextTheme(
      displayLarge: titleLarge,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
    );
  }
}
