import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'floating_assistive_ball.dart';

/// A wrapper widget that enforces a fixed 1080x1920 Portrait Kiosk canvas
/// and scales it smoothly using [FittedBox] to fit any laptop or desktop screen window.
class KioskViewScaler extends StatelessWidget {
  final Widget child;
  final double targetWidth;
  final double targetHeight;
  final bool enableScaling;

  const KioskViewScaler({
    super.key,
    required this.child,
    this.targetWidth = 1080,
    this.targetHeight = 1920,
    this.enableScaling = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enableScaling) return child;

    return Container(
      color: AppColors.canvasLetterbox,
      child: Center(
        child: AspectRatio(
          aspectRatio: targetWidth / targetHeight,
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            child: SizedBox(
              width: targetWidth,
              height: targetHeight,
              child: ClipRect(
                child: Stack(
                  children: [
                    child,
                    FloatingAssistiveBall(canvasSize: Size(targetWidth, targetHeight)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
