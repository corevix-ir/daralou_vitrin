import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class BentoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  /// Optional illustration shown behind the card content, blurred and
  /// washed with the card's own surface color so it reads as a faint
  /// tinted backdrop rather than a competing image — keeps flat cards
  /// (especially in the light theme) from looking like plain white boxes
  /// without ever fighting the text on top for legibility.
  final String? backgroundImage;

  const BentoCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.onTap,
    this.width,
    this.height,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedBackground = backgroundColor ?? AppColors.surfaceContainerLow;
    final image = backgroundImage;

    final Widget contentPadding = Padding(
      padding: padding ?? const EdgeInsets.all(20),
      child: child,
    );

    final Widget innerContent = image == null
        ? contentPadding
        : Stack(
            children: [
              Positioned.fill(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4, tileMode: TileMode.decal),
                  child: Image.asset(image, fit: BoxFit.cover),
                ),
              ),
              // Deliberately a fixed dark scrim, not the card's own
              // (theme-flipping) surface color: in light mode that used to
              // be a near-white wash that left dark text unreadable
              // against busy photos, and the reverse in dark mode. A fixed
              // dark tint plus fixed-light text (AppColors.onDark /
              // onDarkMuted at call sites) reads correctly in both themes.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(color: AppColors.scrim.withValues(alpha: 0.55)),
                ),
              ),
              contentPadding,
            ],
          );

    final cardWidget = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: image == null ? resolvedBackground : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: innerContent,
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.primary.withValues(alpha: 0.15),
          highlightColor: AppColors.primary.withValues(alpha: 0.08),
          child: cardWidget,
        ),
      );
    }

    return cardWidget;
  }
}
