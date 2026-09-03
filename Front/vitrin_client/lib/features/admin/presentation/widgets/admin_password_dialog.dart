import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// Password gate shown before entering the admin panel. Resolves `true`
/// when the correct password was entered, `false`/`null` on cancel.
class AdminPasswordDialog extends StatefulWidget {
  const AdminPasswordDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const AdminPasswordDialog(),
    );
  }

  @override
  State<AdminPasswordDialog> createState() => _AdminPasswordDialogState();
}

class _AdminPasswordDialogState extends State<AdminPasswordDialog> {
  final _controller = TextEditingController();
  String? _error;
  bool _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text == AppConstants.adminPanelPassword) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = 'رمز عبور نادرست است.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'ورود به تنظیمات ادمین',
                      style: TextStyle(
                        fontFamily: 'Peyda',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                obscureText: _obscure,
                autofocus: true,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                onSubmitted: (_) => _submit(),
                style: TextStyle(color: AppColors.inputText, fontFamily: 'Peyda'),
                decoration: InputDecoration(
                  labelText: 'رمز عبور',
                  labelStyle: TextStyle(color: AppColors.inputHint),
                  errorText: _error,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: AppColors.onSurfaceVariant,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('انصراف', style: TextStyle(fontFamily: 'Peyda')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      onPressed: _submit,
                      child: const Text(
                        'ورود',
                        style: TextStyle(fontFamily: 'Peyda', color: AppColors.onPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
