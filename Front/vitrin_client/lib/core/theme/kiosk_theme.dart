import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class KioskTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColorsDark.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColorsDark.background,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.primaryFixed,
        error: AppColorsDark.errorRed,
      ),
      fontFamily: 'Peyda',
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColorsLight.background,
      colorScheme: const ColorScheme.light(
        surface: AppColorsLight.background,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.primaryFixed,
        error: AppColorsLight.errorRed,
      ),
      fontFamily: 'Peyda',
    );
  }
}
