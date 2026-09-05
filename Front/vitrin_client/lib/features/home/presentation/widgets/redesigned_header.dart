import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

class RedesignedHeader extends StatefulWidget {
  const RedesignedHeader({super.key});

  @override
  State<RedesignedHeader> createState() => _RedesignedHeaderState();
}

class _RedesignedHeaderState extends State<RedesignedHeader> {
  final AuthState _authState = AuthState.instance;
  late Timer _timer;

  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _authState.addListener(_onAuthChanged);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _authState.removeListener(_onAuthChanged);
    _timer.cancel();
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  String get _locationText {
    final parts = [_authState.location, _authState.section].where((s) => s.isNotEmpty);
    return parts.isEmpty ? AppConstants.kioskLocation : parts.join(' | ');
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.onDark,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'شرکت مس درآلو',
                    style: TextStyle(
                      fontFamily: 'Peyda',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    _locationText,
                    style: TextStyle(
                      fontFamily: 'Peyda',
                      fontSize: 16,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
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
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('•', style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6))),
                  const SizedBox(width: 10),
                  const Icon(Icons.wb_sunny_rounded, color: AppColors.weatherAccent, size: 22),
                  const SizedBox(width: 6),
                  Text(
                    '28°C',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'شنبه ۱۸ مرداد ۱۴۰۵',
                style: TextStyle(
                  fontFamily: 'Peyda',
                  fontSize: 16,
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
