import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Placeholder destination behind the admin password gate. The actual
/// admin panel UI has not been designed/built yet.
class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLow,
        foregroundColor: AppColors.onSurface,
        title: const Text(
          'پنل ادمین',
          style: TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction_rounded, color: AppColors.primary, size: 48),
              SizedBox(height: 16),
              Text(
                'این بخش به‌زودی تکمیل می‌شود.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Peyda',
                  fontSize: 18,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
