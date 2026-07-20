import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Reusable dark slate card container used throughout the digital signage interface.
class BaseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Widget? backgroundOverlay;
  final AlignmentGeometry alignment;
  final double? width;
  final double? height;

  const BaseCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = 20.0,
    this.backgroundColor = AppColors.cardBackground,
    this.borderColor,
    this.onTap,
    this.gradient,
    this.backgroundOverlay,
    this.alignment = Alignment.topRight,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppColors.cardBorder,
          width: 1.2,
        ),
        gradient: gradient,
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 1),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: AppColors.copperOrangeSubtle,
            highlightColor: Colors.white10,
            borderRadius: BorderRadius.circular(borderRadius - 1),
            child: Stack(
              alignment: alignment,
              children: [
                if (backgroundOverlay != null) Positioned.fill(child: backgroundOverlay!),
                Padding(
                  padding: padding,
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
