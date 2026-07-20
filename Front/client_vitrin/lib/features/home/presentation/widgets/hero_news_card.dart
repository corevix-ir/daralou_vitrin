import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/base_card.dart';
import '../../../../shared/widgets/custom_badge.dart';
import '../../data/models/news_model.dart';

/// Hero Banner News Card displaying official news with background imagery and slider dots
class HeroNewsCard extends StatelessWidget {
  final NewsModel news;
  final VoidCallback? onTap;

  const HeroNewsCard({
    super.key,
    required this.news,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      padding: EdgeInsets.zero,
      borderRadius: 24,
      onTap: onTap,
      child: Stack(
        children: [
          // Background Image with Fallback Pattern Gradient
          Positioned.fill(
            child: Image.network(
              news.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2C3E50), Color(0xFF000000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.precision_manufacturing_rounded,
                    size: 100,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
          ),

          // Smooth Gradient Overlay (Dark bottom gradient for text contrast)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Color(0x40000000),
                    Color(0xCC121318),
                    Color(0xFF121318),
                  ],
                  stops: [0.0, 0.4, 0.8, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Content Layer
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Tag Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomBadge(
                        label: news.categoryTag,
                        backgroundColor: AppColors.copperOrange,
                        textColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        textStyle: AppTypography.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  // Bottom Container: Title + Subtitle + Indicators
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // News Title
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              news.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.titleLarge.copyWith(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                height: 1.4,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 6,
                                    color: Color(0x80000000),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Slider Carousel Dots (Bottom Left)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          news.totalSlides,
                          (index) => Container(
                            margin: const EdgeInsets.only(left: 6),
                            width: index == news.activeIndex ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: index == news.activeIndex
                                  ? AppColors.copperOrange
                                  : Colors.white38,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
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
