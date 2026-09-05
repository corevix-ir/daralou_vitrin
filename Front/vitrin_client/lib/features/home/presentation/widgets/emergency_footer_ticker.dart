import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class EmergencyFooterTicker extends StatelessWidget {
  const EmergencyFooterTicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: double.infinity,
      color: AppColors.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.onDark, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              AppConstants.emergencyText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Peyda',
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.onDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
