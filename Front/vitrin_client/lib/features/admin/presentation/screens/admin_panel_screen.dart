import 'package:flutter/material.dart';
import '../../../../core/services/system_intent_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/global_keys.dart';

class _AdminOption {
  final String title;
  final IconData icon;
  final Color color;
  final Future<bool> Function() action;
  final String failureMessage;

  const _AdminOption({
    required this.title,
    required this.icon,
    required this.color,
    required this.action,
    required this.failureMessage,
  });
}

/// Grid of square shortcut cards for on-site, device-level admin actions
/// (developer options, system settings, Wi-Fi, Bluetooth). New options are
/// simply appended to [_options]: under the app's RTL layout a [GridView]
/// fills its "start" (top-right) cell first, so each addition naturally
/// takes the next free slot without any manual positioning.
class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  static final List<_AdminOption> _options = [
    _AdminOption(
      title: 'گزینه‌های توسعه‌دهنده',
      icon: Icons.developer_mode_rounded,
      color: AppColors.primary,
      action: SystemIntentService.openDeveloperOptions,
      failureMessage: 'گزینه‌های توسعه‌دهنده در این دستگاه در دسترس نیست.',
    ),
    _AdminOption(
      title: 'تنظیمات سیستم',
      icon: Icons.settings_rounded,
      color: AppColors.slateDark,
      action: SystemIntentService.openSystemSettings,
      failureMessage: 'باز کردن تنظیمات سیستم ممکن نشد.',
    ),
    _AdminOption(
      title: 'وای‌فای',
      icon: Icons.wifi_rounded,
      color: AppColors.emeraldGreen,
      action: SystemIntentService.openWifiSettings,
      failureMessage: 'باز کردن تنظیمات وای‌فای ممکن نشد.',
    ),
    _AdminOption(
      title: 'بلوتوث',
      icon: Icons.bluetooth_rounded,
      color: AppColors.primaryFixed,
      action: SystemIntentService.openBluetoothSettings,
      failureMessage: 'باز کردن تنظیمات بلوتوث ممکن نشد.',
    ),
  ];

  Future<void> _handleTap(_AdminOption option) async {
    final ok = await option.action();
    if (!ok) {
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(option.failureMessage, style: const TextStyle(fontFamily: 'Peyda')),
          backgroundColor: AppColors.slateDark,
        ),
      );
    }
  }

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
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 260,
            mainAxisSpacing: 22,
            crossAxisSpacing: 22,
            childAspectRatio: 1,
          ),
          itemCount: _options.length,
          itemBuilder: (context, index) {
            final option = _options[index];
            return _AdminOptionCard(
              option: option,
              onTap: () => _handleTap(option),
            );
          },
        ),
      ),
    );
  }
}

class _AdminOptionCard extends StatelessWidget {
  final _AdminOption option;
  final VoidCallback onTap;

  const _AdminOptionCard({required this.option, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: option.color.withValues(alpha: 0.16),
                ),
                child: Icon(option.icon, color: option.color, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                option.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Peyda',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
