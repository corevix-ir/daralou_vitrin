import 'package:flutter/material.dart';
import 'app_colors.dart';

class KioskTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.background,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.primaryFixed,
        error: AppColors.errorRed,
      ),
      fontFamily: 'Vazirmatn',
    );
  }
}
