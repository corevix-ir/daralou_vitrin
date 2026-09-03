import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bento_card.dart';
import '../../../../shared/widgets/global_snackbar.dart';

class RestaurantMenuCard extends StatelessWidget {
  const RestaurantMenuCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      backgroundImage: 'assets/resturant.jpg',
      onTap: () {
        GlobalSnackBar.showInfo('برنامه غذایی هفتگی سلف سرویس مرکزی درآلو...');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: const Icon(
              Icons.restaurant_menu_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'منوی رستوران',
                style: TextStyle(
                  fontFamily: 'Peyda',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                  shadows: [Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 1))],
                ),
              ),
              SizedBox(height: 4),
              Text(
                'مشاهده لیست غذاها و برنامه هفتگی سلف',
                style: TextStyle(
                  fontFamily: 'Peyda',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                  shadows: [Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 5, offset: const Offset(0, 1))],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
