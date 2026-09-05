import 'package:flutter/material.dart';
import '../../core/utils/global_keys.dart';
import '../../core/theme/app_colors.dart';

class GlobalSnackBar {
  static void showError(String message) {
    _show(
      message: message,
      icon: Icons.error_outline_rounded,
      backgroundColor: AppColors.errorContainer,
    );
  }

  static void showSuccess(String message) {
    _show(
      message: message,
      icon: Icons.check_circle_outline_rounded,
      backgroundColor: AppColors.emeraldGreen,
    );
  }

  static void showInfo(String message) {
    _show(
      message: message,
      icon: Icons.info_outline_rounded,
      backgroundColor: AppColors.surfaceContainerHigh,
      foregroundColor: AppColors.onSurface,
    );
  }

  static void _show({
    required String message,
    required IconData icon,
    required Color backgroundColor,
    Color foregroundColor = AppColors.onDark,
  }) {
    rootScaffoldMessengerKey.currentState?.removeCurrentSnackBar();
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: foregroundColor, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: 'Peyda',
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: foregroundColor,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
