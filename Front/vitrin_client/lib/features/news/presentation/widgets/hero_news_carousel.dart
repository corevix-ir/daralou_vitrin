import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/vitrin_item.dart';
import '../../data/services/vitrin_news_service.dart';

class HeroNewsCarousel extends StatefulWidget {
  const HeroNewsCarousel({super.key});

  @override
  State<HeroNewsCarousel> createState() => _HeroNewsCarouselState();
}

class _HeroNewsCarouselState extends State<HeroNewsCarousel> {
  // Kiosk display: nothing ever triggers a manual refresh, so the carousel
  // has to notice new scraped content on its own while it stays on screen.
  static const _pollInterval = Duration(minutes: 2);

  final VitrinNewsService _newsService = VitrinNewsService();
  final PageController _pageController = PageController();

  List<VitrinItem> _items = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  Timer? _timer;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadNews();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _loadNews(silent: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadNews({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    final items = await _newsService.getVitrinContents();
    if (!mounted) return;

    if (items == null) {
      // Request failed (network hiccup, backend restart, timeout...) - keep
      // whatever is already on screen rather than wiping a working
      // slideshow because of one bad poll. Only clear the spinner so the
      // very first load doesn't hang forever.
      if (!silent) setState(() => _isLoading = false);
      return;
    }

    // Silent polls keep whatever the visitor is currently looking at unless
    // the content actually changed - otherwise every 2 minutes would jump
    // the slideshow back to the first slide for no visible reason.
    final changed = !_sameItems(_items, items);
    setState(() {
      _items = items;
      _isLoading = false;
    });

    if (changed) {
      _currentIndex = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
      _startAutoPlay();
    } else if (!silent) {
      _startAutoPlay();
    }
  }

  bool _sameItems(List<VitrinItem> a, List<VitrinItem> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (_items.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 6), (_) {
        if (_pageController.hasClients) {
          final nextIndex = (_currentIndex + 1) % _items.length;
          _pageController.animateToPage(
            nextIndex,
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOutCubic,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_items.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'محتوایی یافت نشد',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontFamily: 'Peyda',
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
              // A manual swipe shouldn't get immediately overridden by
              // whatever's left of the previous auto-advance countdown.
              _startAutoPlay();
            },
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  Image.network(
                    item.mainImg,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.surfaceContainerHigh,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_rounded,
                            size: 64,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  ),
                  // Dark Gradient Overlay for legibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.4),
                          Colors.black.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                  ),
                  // Tag & Title Content (Summary ignored as per instructions)
                  Positioned(
                    bottom: 32,
                    right: 32,
                    left: 32,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.isLocal ? 'اختصاصی' : 'گزارش',
                            style: const TextStyle(
                              fontFamily: 'Peyda',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Peyda',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.35,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // Indicator Dots
          Positioned(
            bottom: 24,
            left: 32,
            child: Row(
              children: List.generate(
                _items.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 6),
                  width: _currentIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        _currentIndex == index
                            ? AppColors.primary
                            : Colors.white38,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
