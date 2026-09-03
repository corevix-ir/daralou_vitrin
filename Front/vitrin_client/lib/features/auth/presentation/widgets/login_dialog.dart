import 'package:flutter/material.dart';
import 'login_form.dart';

class LoginDialog extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return LoginForm(
      onCancel: () => Navigator.of(context).pop(),
      onLoginSuccess: () {
        Navigator.of(context).pop();
        onLoginSuccess();
      },
    );
  }
}
