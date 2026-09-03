import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bento_card.dart';

class LmeCopperTickerCard extends StatelessWidget {
  const LmeCopperTickerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      backgroundImage: 'assets/copper.jpg',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'قیمت مس LME',
                style: TextStyle(
                  fontFamily: 'Peyda',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                  shadows: [Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 1))],
                ),
              ),
              Icon(
                Icons.trending_up_rounded,
                color: AppColors.emeraldGreen,
                size: 22,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\$9,450',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                  shadows: [Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 1))],
                ),
              ),
              SizedBox(height: 2),
              Text(
                'قیمت جهانی هر تن',
                style: TextStyle(
                  fontFamily: 'Peyda',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                  shadows: [Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 5, offset: const Offset(0, 1))],
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.emeraldGreenBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.emeraldGreen.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_drop_up_rounded, color: AppColors.emeraldGreen, size: 20),
                Text(
                  '+2.1% 24h',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.emeraldGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
