import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 56),
                const SizedBox(height: 12),
                Text(
                  'شرکت مس درآلو - ویترین',
                  style: TextStyle(
                    fontFamily: 'Peyda',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 32),
                LoginForm(onLoginSuccess: onLoginSuccess),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
