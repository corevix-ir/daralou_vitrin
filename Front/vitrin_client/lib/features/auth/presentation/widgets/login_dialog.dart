import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/global_snackbar.dart';
import '../../../../shared/widgets/kiosk_primary_button.dart';
import '../../data/services/auth_service.dart';

class LoginDialog extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginDialog({super.key, required this.onLoginSuccess});

  static Future<void> show(BuildContext context, {required VoidCallback onLoginSuccess}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: LoginDialog(onLoginSuccess: onLoginSuccess),
      ),
    );
  }

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      GlobalSnackBar.showError('لطفاً نام کاربری و رمز عبور را وارد کنید.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _authService.login(username, password);
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          GlobalSnackBar.showSuccess('ورود دستگاه با موفقیت انجام شد.');
          Navigator.of(context).pop();
          widget.onLoginSuccess();
        } else {
          GlobalSnackBar.showError('اطلاعات ورود نادرست است.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 440,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'ورود به سیستم کیوسک',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'برای برقراری ارتباط فعال دستگاه با سرور، نام کاربری و رمز عبور را وارد کنید.',
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _usernameController,
            style: const TextStyle(color: Colors.white, fontFamily: 'Vazirmatn'),
            decoration: InputDecoration(
              labelText: 'نام کاربری',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
              filled: true,
              fillColor: AppColors.surfaceContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white, fontFamily: 'Vazirmatn'),
            decoration: InputDecoration(
              labelText: 'رمز عبور',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
              filled: true,
              fillColor: AppColors.surfaceContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 28),
          KioskPrimaryButton(
            label: 'ورود دستگاه',
            icon: Icons.login_rounded,
            isLoading: _isLoading,
            onPressed: _handleLogin,
          ),
        ],
      ),
    );
  }
}
