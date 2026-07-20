import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/base_card.dart';
import '../../data/models/stock_model.dart';

/// TSE Stock Index Card for FAMELI stock (1-column wide)
class TseStockCard extends StatelessWidget {
  final StockModel stock;
  final VoidCallback? onTap;

  const TseStockCard({
    super.key,
    required this.stock,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header: Symbol Tag & Circular Stock Arrow Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stock.symbol,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Roboto',
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.emeraldGreenSubtle,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.north_east_rounded,
                    color: AppColors.emeraldGreenBright,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Main Stat Change (+1.4%)
          Text(
            stock.changePercent,
            style: AppTypography.titleLarge.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppColors.emeraldGreenBright,
            ),
          ),

          const SizedBox(height: 8),

          // Last Updated Time Subtitle
          Text(
            'بروزرسانی: ${stock.lastUpdatedTime}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
