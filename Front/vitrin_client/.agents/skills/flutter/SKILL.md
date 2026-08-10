# Skill: Flutter Kiosk UI Architecture & Component Framework

## Overview
This skill specifies widget architecture, bento layout engines, responsive scaling, typography binding, and state management for building the 55-inch portrait Kiosk display in Flutter.

## Core Rules for Flutter Development

1. **Const Everything:** Mandatory use of `const` constructors on all immutable UI subtrees to maximize Flutter widget reuse and maintain 60 FPS rendering.
2. **Strict RTL First:** Wrap root application in `Directionality(textDirection: TextDirection.rtl, ...)`.
3. **No Direct Hardcoded Dimensions:** Use layout primitives (`BentoCard`, `GlassmorphicContainer`) and ratio-based specs aligned with 1080x1920 layout system.
4. **Touch Target Size:** All interactive buttons must have a height of at least 56dp and touch area of 64x64 dp to support physical kiosk touch accuracy.

---

## Code Example: Root Kiosk App Wrapper

```dart
import 'package:flutter/material.dart';
import '../../core/theme/kiosk_theme.dart';
import '../../core/utils/global_keys.dart';
import '../../features/home/presentation/screens/home_kiosk_screen.dart';

class VitrinKioskApp extends StatelessWidget {
  const VitrinKioskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'شرکت مس درآلو - ویترین',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      theme: KioskTheme.darkTheme,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const HomeKioskScreen(),
    );
  }
}
```

---

## Detailed References
- [Bento Grid Layout Engine](references/bento-grid-kiosk.md)
- [Feature-First Directory Pattern](references/feature-first.md)
- [Global SnackBar & Toast System](references/global-snackbar.md)
- [State Management Paradigm](references/state-management.md)
- [Typography & ThemeData Configuration](references/typography-theme.md)
