import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Custom capsule badge widget used for tags, indicators, and trends
class CustomBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Widget? customIcon;
  final Color backgroundColor;
  final Color textColor;
  final Color? iconColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final TextStyle? textStyle;
  final VoidCallback? onTap;

  const CustomBadge({
    super.key,
    required this.label,
    this.icon,
    this.customIcon,
    this.backgroundColor = AppColors.tagBackground,
    this.textColor = AppColors.textPrimary,
    this.iconColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    this.borderRadius = 30.0,
    this.textStyle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget childWidget = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (customIcon != null) ...[
            customIcon!,
            const SizedBox(width: 6),
          ] else if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: iconColor ?? textColor,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: textStyle ??
                AppTypography.labelMedium.copyWith(
                  color: textColor,
                ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: childWidget,
      );
    }
    return childWidget;
  }
}
