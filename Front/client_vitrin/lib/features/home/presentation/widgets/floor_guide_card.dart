import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/base_card.dart';
import '../../data/models/floor_guide_model.dart';

/// Custom painter for blueprint architectural grid vector overlay
class BlueprintGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x154A90E2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw compass / architectural grid circle overlay on top corner
    final circlePaint = Paint()
      ..color = const Color(0x20F37321)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.35), 60, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.35), 90, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Floor Guide & Directory Directory Card (2-columns wide)
class FloorGuideCard extends StatelessWidget {
  final FloorGuideModel floorGuide;
  final VoidCallback? onTap;

  const FloorGuideCard({
    super.key,
    required this.floorGuide,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      onTap: onTap,
      backgroundOverlay: CustomPaint(
        painter: BlueprintGridPainter(),
      ),
      child: Row(
        children: [
          // Text Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.copperOrangeSubtle,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.map_outlined,
                        color: AppColors.copperOrange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      floorGuide.title,
                      style: AppTypography.titleMedium.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  floorGuide.description,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Direction Arrow Action Circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.tagBackground,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Icon(
              Icons.chevron_left_rounded,
              color: AppColors.copperOrange,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}
