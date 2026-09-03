import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bento_card.dart';
import '../../../news/data/models/vitrin_item.dart';
import '../../../news/data/services/vitrin_news_service.dart';
import '../../../news/presentation/screens/news_list_screen.dart';

class LatestNewsCard extends StatefulWidget {
  const LatestNewsCard({super.key});

  @override
  State<LatestNewsCard> createState() => _LatestNewsCardState();
}

class _LatestNewsCardState extends State<LatestNewsCard> {
  // Kiosk display: nothing ever triggers a manual refresh, so this card has
  // to notice new scraped content on its own while it stays on screen.
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
    _loadLatestNews();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _loadLatestNews(silent: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadLatestNews({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    final response = await _newsService.getScrapNews(page: 1, size: 3);
    if (!mounted) return;

    if (response == null) {
      // Request failed (network hiccup, backend restart, timeout...) - keep
      // whatever is already on screen rather than wiping a working
      // slideshow because of one bad poll. Only clear the spinner so the
      // very first load doesn't hang forever.
      if (!silent) setState(() => _isLoading = false);
      return;
    }

    final items = response.items.take(3).toList();
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
      _startAutoSlide();
    } else if (!silent) {
      _startAutoSlide();
    }
  }

  bool _sameItems(List<VitrinItem> a, List<VitrinItem> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  void _startAutoSlide() {
    _timer?.cancel();
    if (_items.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (_pageController.hasClients) {
          final next = (_currentIndex + 1) % _items.length;
          _pageController.animateToPage(
            next,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _openNewsListScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const NewsListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      padding: EdgeInsets.zero,
      onTap: _openNewsListScreen,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Slide Content
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            else if (_items.isEmpty)
              Center(
                child: Text(
                  'خبری یافت نشد',
                  style: TextStyle(fontFamily: 'Peyda', color: AppColors.onSurfaceVariant),
                ),
              )
            else
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                  // A manual swipe shouldn't get immediately overridden by
                  // whatever's left of the previous auto-advance countdown.
                  _startAutoSlide();
                },
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background Image
                      Image.network(
                        item.mainImg,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.surfaceContainerHigh,
                            child: Icon(
                              Icons.newspaper_rounded,
                              size: 40,
                              color: AppColors.onSurfaceVariant,
                            ),
                          );
                        },
                      ),

                      // Dark Overlay Gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              Colors.black.withValues(alpha: 0.85),
                            ],
                          ),
                        ),
                      ),

                      // News Content Text
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Top Tag & Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'آخرین اخبار',
                                    style: TextStyle(
                                      fontFamily: 'Peyda',
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onPrimary,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: List.generate(
                                    _items.length,
                                    (dotIdx) => AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.only(left: 4),
                                      width: _currentIndex == dotIdx ? 16 : 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: _currentIndex == dotIdx
                                            ? AppColors.primary
                                            : Colors.white38,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Bottom Title & CTA
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Peyda',
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Row(
                                  children: [
                                    Text(
                                      'نمایش بیشتر',
                                      style: TextStyle(
                                        fontFamily: 'Peyda',
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_back_rounded,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
