import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/base_card.dart';
import '../../../../shared/widgets/custom_badge.dart';
import '../../data/models/transit_model.dart';

/// Bus & Shuttle Transit Timetable Card (1-column wide)
class TransitCard extends StatelessWidget {
  final TransitModel transit;
  final VoidCallback? onTap;

  const TransitCard({
    super.key,
    required this.transit,
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
          // Header: Bus Icon + Next Departure Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.copperOrangeSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_bus_rounded,
                  color: AppColors.copperOrange,
                  size: 24,
                ),
              ),
              CustomBadge(
                label: 'بعدی: ${transit.nextDepartureMinutes} دقیقه',
                backgroundColor: AppColors.tagBackground,
                textColor: AppColors.copperOrange,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                textStyle: AppTypography.labelMedium.copyWith(
                  fontSize: 12,
                  color: AppColors.copperOrange,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Timetable entries
          Column(
            children: transit.schedules.map((schedule) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.iconBackground,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        schedule.time,
                        style: AppTypography.labelMedium.copyWith(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${schedule.routeName} (${schedule.gateName})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
