import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bento_card.dart';
import '../../data/models/vitrin_item.dart';
import '../../data/services/vitrin_news_service.dart';
import 'news_detail_screen.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final VitrinNewsService _newsService = VitrinNewsService();

  int _currentPage = 1;
  final int _pageSize = 8;
  int _totalCount = 0;
  bool _isLoading = true;
  List<VitrinItem> _newsItems = [];

  @override
  void initState() {
    super.initState();
    _fetchNewsPage(_currentPage);
  }

  Future<void> _fetchNewsPage(int page) async {
    setState(() => _isLoading = true);
    final response = await _newsService.getScrapNews(page: page, size: _pageSize);
    if (mounted) {
      setState(() {
        _currentPage = page;
        _newsItems = response?.items ?? const [];
        _totalCount = response?.total ?? 0;
        _isLoading = false;
      });
    }
  }

  int get _totalPages => (_totalCount / _pageSize).ceil().clamp(1, 999);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar with Back Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                border: Border(
                  bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.newspaper_rounded, color: AppColors.primary, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'آرشیو اخبار و اطلاعیه‌های شرکت مس درآلو',
                        style: TextStyle(
                          fontFamily: 'Peyda',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onSurface,
                      side: BorderSide(color: AppColors.outlineVariant),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                    label: const Text(
                      'بازگشت به صفحه اصلی',
                      style: TextStyle(
                        fontFamily: 'Peyda',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Grid Area
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : _newsItems.isEmpty
                      ? Center(
                          child: Text(
                            'هیچ خبری برای نمایش وجود ندارد.',
                            style: TextStyle(
                              fontFamily: 'Peyda',
                              fontSize: 16,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(24),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.4,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: _newsItems.length,
                          itemBuilder: (context, index) {
                            final item = _newsItems[index];
                            return BentoCard(
                              padding: EdgeInsets.zero,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => NewsDetailScreen(
                                    contentId: item.id,
                                    previewTitle: item.title,
                                    previewImage: item.mainImg,
                                  ),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Background Main Image
                                    Image.network(
                                      item.mainImg,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: AppColors.surfaceContainerHigh,
                                          child: Icon(
                                            Icons.image_not_supported_rounded,
                                            size: 48,
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
                                            Colors.transparent,
                                            AppColors.scrim.withValues(alpha: 0.5),
                                            AppColors.scrim.withValues(alpha: 0.9),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Content Text
                                    Positioned(
                                      bottom: 20,
                                      right: 20,
                                      left: 20,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: 'Peyda',
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.onDark,
                                              height: 1.3,
                                            ),
                                          ),
                                          if (item.createdAt.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.access_time_rounded,
                                                  size: 14,
                                                  color: AppColors.primary,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  item.createdAt,
                                                  style: TextStyle(
                                                    fontFamily: 'Peyda',
                                                    fontSize: 12,
                                                    // Fixed, not onSurfaceVariant: this sits on the
                                                    // same always-dark gradient as the white title
                                                    // above, which in light mode made this text a
                                                    // near-black-on-near-black near-miss.
                                                    color: AppColors.onDarkMuted,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),

            // Pagination Control Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                border: Border(
                  top: BorderSide(color: AppColors.outlineVariant, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Next Page Button (in RTL, next page is to the right/left accordingly)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerHigh,
                      foregroundColor: AppColors.onSurface,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _currentPage > 1 && !_isLoading
                        ? () => _fetchNewsPage(_currentPage - 1)
                        : null,
                    icon: const Icon(Icons.chevron_left_rounded, size: 22),
                    label: const Text(
                      'صفحه قبلی',
                      style: TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Page Counter Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      'صفحه $_currentPage از $_totalPages',
                      style: const TextStyle(
                        fontFamily: 'Peyda',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Previous Page Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerHigh,
                      foregroundColor: AppColors.onSurface,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _currentPage < _totalPages && !_isLoading
                        ? () => _fetchNewsPage(_currentPage + 1)
                        : null,
                    icon: const Icon(Icons.chevron_right_rounded, size: 22),
                    label: const Text(
                      'صفحه بعدی',
                      style: TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
