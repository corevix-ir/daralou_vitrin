import 'package:flutter/material.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/screens/home_kiosk_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthState _authState = AuthState.instance;

  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _authState.addListener(_onAuthChanged);
    _bootstrap();
  }

  @override
  void dispose() {
    _authState.removeListener(_onAuthChanged);
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _authState.refresh();
    if (mounted) {
      setState(() => _isChecking = false);
    }
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (!_authState.isLoggedIn) {
      return LoginScreen(onLoginSuccess: _authState.refresh);
    }

    return const HomeKioskScreen();
  }
}
