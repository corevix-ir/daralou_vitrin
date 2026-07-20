import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/base_card.dart';
import '../../../../shared/widgets/custom_badge.dart';

/// Secondary News Card for Row 3 (placed next to Sports Reservation)
class SecondaryNewsCard extends StatelessWidget {
  final VoidCallback? onTap;

  const SecondaryNewsCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header Tag & News Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'اخبار و اعلانات',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.copperOrangeSubtle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.newspaper_rounded,
                  color: AppColors.copperOrange,
                  size: 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // News Headline Title
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'اطلاعیه برگزاری المپیاد ورزشی کارکنان',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.titleSmall.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Tag Pill / Time Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomBadge(
                label: 'جدیدترین اخبار',
                backgroundColor: AppColors.tagBackground,
                textColor: AppColors.copperOrange,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                textStyle: AppTypography.labelMedium.copyWith(
                  fontSize: 11,
                  color: AppColors.copperOrange,
                ),
              ),
              Text(
                '۰۹:۱۵',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
