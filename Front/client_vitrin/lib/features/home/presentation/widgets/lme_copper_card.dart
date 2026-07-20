import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/base_card.dart';
import '../../../../shared/widgets/custom_badge.dart';
import '../../data/models/lme_model.dart';

/// LME Copper Price Live Indicator Card (1-column wide) with adaptive layout
class LmeCopperCard extends StatelessWidget {
  final LmeModel lme;
  final VoidCallback? onTap;

  const LmeCopperCard({
    super.key,
    required this.lme,
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
          // Top Label & Category Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  lme.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.iconBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: AppColors.emeraldGreenBright,
                  size: 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Price Display ($9,450 / تن) in FittedBox to avoid overflow
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  lme.priceFormatted,
                  style: AppTypography.titleLarge.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '/ ${lme.unit}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Green Trend Pill Badge (+2.1% 24h)
          CustomBadge(
            label: '${lme.trendPercent} ${lme.timeFrame}',
            icon: lme.isPositiveTrend
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            backgroundColor: lme.isPositiveTrend
                ? AppColors.emeraldGreenSubtle
                : AppColors.crimsonRedSubtle,
            textColor: lme.isPositiveTrend
                ? AppColors.emeraldGreenBright
                : AppColors.crimsonRed,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          ),
        ],
      ),
    );
  }
}
