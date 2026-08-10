import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/auth_token_storage.dart';
import '../../../auth/presentation/widgets/login_dialog.dart';

class RedesignedHeader extends StatefulWidget {
  const RedesignedHeader({super.key});

  @override
  State<RedesignedHeader> createState() => _RedesignedHeaderState();
}

class _RedesignedHeaderState extends State<RedesignedHeader> {
  final AuthTokenStorage _storage = AuthTokenStorage.instance;
  late Timer _timer;
  
  DateTime _now = DateTime.now();
  bool _isLoggedIn = false;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    final loggedIn = await _storage.isLoggedIn();
    final username = await _storage.getUsername() ?? '';
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _username = username;
      });
    }
  }

  String _formatTime() {
    final h = _now.hour.toString().padLeft(2, '0');
    final m = _now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Right Side: Gray Circle Logo Placeholder & Title
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.logoCircleBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'شرکت مس درآلو',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'ساختمان مرکزی | لابی اصلی',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Center: Device Login / Status Button
          InkWell(
            onTap: () {
              LoginDialog.show(context, onLoginSuccess: _checkAuthStatus);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _isLoggedIn
                    ? AppColors.emeraldGreenBg
                    : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isLoggedIn
                      ? AppColors.emeraldGreen
                      : AppColors.primary.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isLoggedIn ? Icons.check_circle_rounded : Icons.login_rounded,
                    size: 20,
                    color: _isLoggedIn ? AppColors.emeraldGreen : AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isLoggedIn ? 'دستگاه فعال ($_username)' : 'ورود دستگاه',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _isLoggedIn ? Colors.white : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Left Side: 2-Line Time, Weather & Date Info
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(),
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('•', style: TextStyle(color: Colors.white38)),
                  const SizedBox(width: 10),
                  const Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 6),
                  const Text(
                    '28°C',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'شنبه ۱۸ مرداد ۱۴۰۵',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
