# Global SnackBar & Notification System in Flutter

## Overview
This document specifies how system messages, connection alerts, and submission feedback are dispatched asynchronously across the application without requiring a valid `BuildContext`.

---

## 1. Global Key Initialization

```dart
// lib/core/utils/global_keys.dart
import 'package:flutter/material.dart';

/// Global key attached to the root MaterialApp scaffoldMessengerKey
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
```

---

## 2. Notification Dispatcher Implementation

```dart
// lib/shared/widgets/global_snackbar.dart
import 'package:flutter/material.dart';
import '../../core/utils/global_keys.dart';
import '../../core/theme/app_colors.dart';

class GlobalSnackBar {
  static void showError(String message) {
    _showCustomSnackBar(
      message: message,
      icon: Icons.error_outline_rounded,
      backgroundColor: AppColors.errorContainer,
    );
  }

  static void showSuccess(String message) {
    _showCustomSnackBar(
      message: message,
      icon: Icons.check_circle_outline_rounded,
      backgroundColor: AppColors.emeraldGreen,
    );
  }

  static void showInfo(String message) {
    _showCustomSnackBar(
      message: message,
      icon: Icons.info_outline_rounded,
      backgroundColor: AppColors.surfaceContainerHigh,
    );
  }

  static void _showCustomSnackBar({
    required String message,
    required IconData icon,
    required Color backgroundColor,
  }) {
    rootScaffoldMessengerKey.currentState?.removeCurrentSnackBar();
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
```
