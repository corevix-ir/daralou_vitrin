import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bento_card.dart';
import '../../../../shared/widgets/global_snackbar.dart';

class LeaveRegistrationCard extends StatelessWidget {
  const LeaveRegistrationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      backgroundImage: 'assets/morakhasi.jpg',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: const Icon(
                  Icons.assignment_ind_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'مرکز خدمات پرسنلی',
                style: TextStyle(
                  fontFamily: 'Peyda',
                  fontSize: 17,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 5, offset: const Offset(0, 1))],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ثبت مرخصی',
                style: TextStyle(
                  fontFamily: 'Peyda',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                  shadows: [Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 1))],
                ),
              ),
              SizedBox(height: 6),
              Text(
                'ثبت و پیگیری آنلاین درخواست‌های مرخصی ساعتی و روزانه پرسنل',
                style: TextStyle(
                  fontFamily: 'Peyda',
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                  shadows: [Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 5, offset: const Offset(0, 1))],
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () {
                GlobalSnackBar.showInfo('سامانه ثبت مرخصی در حال بارگذاری است...');
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_note_rounded, color: AppColors.onPrimary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'ثبت درخواست',
                    style: TextStyle(
                      fontFamily: 'Peyda',
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
