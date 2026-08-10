# Typography & Kiosk ThemeData Integration

## Overview
This reference specifies ThemeData binding, text style declarations, and font family fallback configurations for the **vitrin_client** application.

---

## 1. Complete `KioskTheme` ThemeData Builder

```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Geist',
          fontSize: 32,
          fontWeight: FontWeight.w600,
          height: 1.25,
          letterSpacing: -0.64,
          color: AppColors.onSurface,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: AppColors.onSurface,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: AppColors.onSurface,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: AppColors.onSurfaceVariant,
        ),
        labelLarge: TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.65,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
```

---

## 2. Dynamic Font Fallback Rules

For numerical tickers and timestamps embedded in Persian text blocks, apply `JetBrains Mono` specifically to numbers or wrap numerical widgets in explicit text styles:

```dart
class MonospaceTickerText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;

  const MonospaceTickerText({
    super.key,
    required this.text,
    this.fontSize = 24,
    this.color = AppColors.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'JetBrains Mono',
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}
```
