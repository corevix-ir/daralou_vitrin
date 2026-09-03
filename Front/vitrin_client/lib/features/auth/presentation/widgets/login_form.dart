import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/global_snackbar.dart';
import '../../../../shared/widgets/kiosk_primary_button.dart';
import '../../data/services/auth_service.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback? onCancel;

  const LoginForm({super.key, required this.onLoginSuccess, this.onCancel});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
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
              Row(
                children: [
                  const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'ورود به سیستم کیوسک',
                    style: TextStyle(
                      fontFamily: 'Peyda',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              if (widget.onCancel != null)
                IconButton(
                  icon: Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant),
                  onPressed: widget.onCancel,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'برای برقراری ارتباط فعال دستگاه با سرور، نام کاربری و رمز عبور را وارد کنید.',
            style: TextStyle(
              fontFamily: 'Peyda',
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _usernameController,
            style: TextStyle(color: AppColors.inputText, fontFamily: 'Peyda'),
            decoration: InputDecoration(
              labelText: 'نام کاربری',
              labelStyle: TextStyle(color: AppColors.inputHint),
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
            onSubmitted: (_) => _handleLogin(),
            style: TextStyle(color: AppColors.inputText, fontFamily: 'Peyda'),
            decoration: InputDecoration(
              labelText: 'رمز عبور',
              labelStyle: TextStyle(color: AppColors.inputHint),
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
