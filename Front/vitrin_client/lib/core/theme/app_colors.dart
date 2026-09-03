import 'package:flutter/material.dart';
import 'theme_controller.dart';

/// Fixed dark-mode surface & text palette. Consumed directly by
/// [KioskTheme.darkTheme] and indirectly by [AppColors] whenever the kiosk
/// is currently in dark mode.
class AppColorsDark {
  AppColorsDark._();

  static const Color background = Color(0xFF121414);
  static const Color surfaceContainerLow = Color(0xFF1A1C1C);
  static const Color surfaceContainer = Color(0xFF1E2020);
  static const Color surfaceContainerHigh = Color(0xFF292A2A);
  static const Color onSurface = Color(0xFFE3E2E2);
  static const Color onSurfaceVariant = Color(0xFFDDC1B2);
  static const Color outlineVariant = Color(0x1AFFFFFF);
  static const Color emeraldGreen = Color(0xFF219653);
  static const Color emeraldGreenBg = Color(0xFF143823);
  static const Color errorRed = Color(0xFFFFB4AB);
  static const Color inputText = Color(0xFFF2F0EE);
  static const Color inputHint = Color(0xB3F2F0EE);
}

/// Fixed light-mode surface & text palette — a warm "copper on cream"
/// treatment (not a generic Material inversion) so the light theme still
/// reads as the same brand: cream/white surfaces, warm brown-gray text,
/// the same orange accent.
class AppColorsLight {
  AppColorsLight._();

  static const Color background = Color(0xFFFAF6F2);
  static const Color surfaceContainerLow = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFF3ECE4);
  static const Color surfaceContainerHigh = Color(0xFFEAE0D4);
  static const Color onSurface = Color(0xFF2B241F);
  static const Color onSurfaceVariant = Color(0xFF7C6A5C);
  static const Color outlineVariant = Color(0x1F2B241F);
  static const Color emeraldGreen = Color(0xFF1D7A42);
  static const Color emeraldGreenBg = Color(0xFFE1F5E7);
  static const Color errorRed = Color(0xFFB3261E);
  static const Color inputText = Color(0xFF2B241F);
  static const Color inputHint = Color(0xB32B241F);
}

/// Live, theme-aware color tokens. Every widget should read colors from
/// here (never from [AppColorsDark]/[AppColorsLight] directly) so the whole
/// UI repaints consistently the moment [ThemeController] switches modes.
abstract class AppColors {
  static bool get _dark => ThemeController.instance.isDark;

  static Color get background =>
      _dark ? AppColorsDark.background : AppColorsLight.background;
  static Color get surfaceContainerLow =>
      _dark ? AppColorsDark.surfaceContainerLow : AppColorsLight.surfaceContainerLow;
  static Color get surfaceContainer =>
      _dark ? AppColorsDark.surfaceContainer : AppColorsLight.surfaceContainer;
  static Color get surfaceContainerHigh =>
      _dark ? AppColorsDark.surfaceContainerHigh : AppColorsLight.surfaceContainerHigh;
  static Color get onSurface => _dark ? AppColorsDark.onSurface : AppColorsLight.onSurface;
  static Color get onSurfaceVariant =>
      _dark ? AppColorsDark.onSurfaceVariant : AppColorsLight.onSurfaceVariant;
  static Color get outlineVariant =>
      _dark ? AppColorsDark.outlineVariant : AppColorsLight.outlineVariant;
  static Color get emeraldGreen => _dark ? AppColorsDark.emeraldGreen : AppColorsLight.emeraldGreen;
  static Color get emeraldGreenBg =>
      _dark ? AppColorsDark.emeraldGreenBg : AppColorsLight.emeraldGreenBg;
  static Color get errorRed => _dark ? AppColorsDark.errorRed : AppColorsLight.errorRed;
  static Color get inputText => _dark ? AppColorsDark.inputText : AppColorsLight.inputText;
  static Color get inputHint => _dark ? AppColorsDark.inputHint : AppColorsLight.inputHint;

  // Brand colors: identical in both themes so the company identity never changes.
  static const Color primary = Color(0xFFF58232);
  static const Color primaryFixed = Color(0xFFF37321);
  static const Color onPrimary = Color(0xFF522300);

  // Fixed "always dark" chip, independent of the active theme — used by
  // controls meant to look and read the same regardless of mode (admin
  // gate, neutral toast background).
  static const Color slateDark = Color(0xFF1E2028);
  static const Color logoCircleBackground = Color(0xFF383939);

  // The emergency banner intentionally ignores the active theme so it
  // stays instantly recognizable as an alert in either mode.
  static const Color errorContainer = Color(0xFF93000A);
}
