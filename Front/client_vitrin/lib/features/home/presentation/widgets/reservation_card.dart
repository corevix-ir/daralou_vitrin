import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/base_card.dart';
import '../../data/models/service_model.dart';

/// Personnel Services & Sports Reservation Card (2-columns wide)
class ReservationCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onReservePressed;

  const ReservationCard({
    super.key,
    required this.service,
    this.onReservePressed,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header Row: Sub-label & Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                service.sectionTitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.copperOrange,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.iconBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.sports_basketball_outlined,
                  color: AppColors.copperOrange,
                  size: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Main Title
          Text(
            service.title,
            style: AppTypography.titleMedium.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          // Description Subtitle
          Text(
            service.subtitle,
            style: AppTypography.bodyMedium.copyWith(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          // Full-width Orange Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onReservePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.copperOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    service.buttonText,
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_back_rounded, // RTL direction pointing arrow
                    size: 20,
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
