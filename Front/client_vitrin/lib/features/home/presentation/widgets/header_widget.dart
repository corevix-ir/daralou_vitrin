import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Top Header Widget for Digital Signage Kiosk with responsive flex constraints
class HeaderWidget extends StatelessWidget {
  final String locationTag;
  final String temperature;
  final String time;
  final String date;

  const HeaderWidget({
    super.key,
    required this.locationTag,
    required this.temperature,
    required this.time,
    this.date = 'دوشنبه ۳۰ تیر ۱۴۰۵',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Right Side: Gray Circle Logo Placeholder + Title & Subtitle Column
          Expanded(
            child: Row(
              children: [
                // Gray Circle Placeholder for Logo
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF333745),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.cardBorder,
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.business_rounded,
                      color: AppColors.textSecondary,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Title & Subtitle Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'شرکت مس درآلو',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'سامانه اطلاع‌رسانی کیوسک دیجیتال',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Left Side: Two smaller lines for Time/Date and Weather
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Line 1: Time and Date
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    color: AppColors.copperOrange,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$time  |  $date',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Line 2: Weather Info
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.wb_sunny_outlined,
                    color: Color(0xFFFFC107),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'هوا: $temperature - آفتابی',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
