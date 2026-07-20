import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/base_card.dart';

/// QR Code Custom Painter for high-precision vector QR graphic styling
class QrGraphicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.copperOrange
      ..style = PaintingStyle.fill;

    // Corner positioning squares
    final cornerSize = size.width * 0.28;
    
    // Top Right corner
    canvas.drawRect(Rect.fromLTWH(size.width - cornerSize, 0, cornerSize, cornerSize), paint);
    canvas.drawRect(Rect.fromLTWH(size.width - cornerSize + 4, 4, cornerSize - 8, cornerSize - 8), Paint()..color = AppColors.cardBackground);
    canvas.drawRect(Rect.fromLTWH(size.width - cornerSize + 8, 8, cornerSize - 16, cornerSize - 16), paint);

    // Top Left corner
    canvas.drawRect(Rect.fromLTWH(0, 0, cornerSize, cornerSize), paint);
    canvas.drawRect(Rect.fromLTWH(4, 4, cornerSize - 8, cornerSize - 8), Paint()..color = AppColors.cardBackground);
    canvas.drawRect(Rect.fromLTWH(8, 8, cornerSize - 16, cornerSize - 16), paint);

    // Bottom Right corner
    canvas.drawRect(Rect.fromLTWH(size.width - cornerSize, size.height - cornerSize, cornerSize, cornerSize), paint);
    canvas.drawRect(Rect.fromLTWH(size.width - cornerSize + 4, size.height - cornerSize + 4, cornerSize - 8, cornerSize - 8), Paint()..color = AppColors.cardBackground);
    canvas.drawRect(Rect.fromLTWH(size.width - cornerSize + 8, size.height - cornerSize + 8, cornerSize - 16, cornerSize - 16), paint);

    // Data dots pattern
    final dotPaint = Paint()..color = Colors.white70;
    const double step = 6.0;
    for (double x = 4; x < size.width - 4; x += step) {
      for (double y = 4; y < size.height - 4; y += step) {
        if ((x + y) % 3 == 0) {
          canvas.drawRect(Rect.fromLTWH(x, y, 3.5, 3.5), dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// QR Code Connection Card for digital signage (1-column wide)
class QrConnectCard extends StatelessWidget {
  final VoidCallback? onTap;

  const QrConnectCard({
    super.key,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Orange QR Icon Container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.copperOrangeSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  color: AppColors.copperOrange,
                  size: 24,
                ),
              ),

              // Mini QR graphic representation
              SizedBox(
                width: 32,
                height: 32,
                child: CustomPaint(
                  painter: QrGraphicPainter(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Title & Subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اسکن برای اتصال',
                style: AppTypography.titleSmall.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'آخرین اخبار ما را دنبال کنید',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
