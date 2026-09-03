import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bento_card.dart';
import '../../../../shared/widgets/global_snackbar.dart';

class SportsReservationCard extends StatelessWidget {
  const SportsReservationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      backgroundImage: 'assets/sport.jpg',
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
                  Icons.sports_soccer_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'خدمات رفاهی پرسنل',
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
                'رزرو ورزشی',
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
                'رزرو نوبت‌های سالن ورزشی، استخر و زمین چمن مجموعه',
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
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                GlobalSnackBar.showInfo('سیستم رزرو مجتمع ورزشی در دست آماده‌سازی است.');
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'رزرو نوبت',
                    style: TextStyle(
                      fontFamily: 'Peyda',
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
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
