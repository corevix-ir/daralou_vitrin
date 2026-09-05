import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../browser/presentation/screens/in_app_browser_screen.dart';
import '../../data/models/content_detail.dart';
import '../../data/services/vitrin_news_service.dart';
import '../../data/utils/scraped_html_sanitizer.dart';

/// Full-article view for a single news/content item, fetched from
/// `GET /contents/{content_id}`. [previewTitle]/[previewImage] (already
/// known from whatever list/carousel card was tapped) are shown instantly
/// while the real detail loads, so the screen never opens on a blank page.
class NewsDetailScreen extends StatefulWidget {
  final int contentId;
  final String? previewTitle;
  final String? previewImage;

  const NewsDetailScreen({
    super.key,
    required this.contentId,
    this.previewTitle,
    this.previewImage,
  });

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  final VitrinNewsService _newsService = VitrinNewsService();

  ContentDetail? _detail;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    final detail = await _newsService.getContentDetail(widget.contentId);
    if (!mounted) return;
    setState(() {
      _detail = detail;
      _hasError = detail == null;
      _isLoading = false;
    });
  }

  String get _heroImage => _detail?.mainImgUrl ?? widget.previewImage ?? '';

  String get _heroTitle => _detail?.title ?? widget.previewTitle ?? '';

  String _formatDate(String iso) {
    if (iso.isEmpty) return '';
    try {
      final date = DateTime.parse(iso).toLocal();
      return DateFormat('yyyy/MM/dd  -  HH:mm', 'en').format(date);
    } catch (_) {
      return iso;
    }
  }

  String _contentTypeLabel(String type) {
    switch (type) {
      case 'news':
        return 'خبر';
      case 'announcement':
        return 'اطلاعیه';
      default:
        return type.isEmpty ? 'محتوا' : type;
    }
  }

  void _openExternalUrl() {
    final detail = _detail;
    if (detail == null || !detail.hasExternalUrl) return;
    InAppBrowserScreen.open(context, url: detail.externalUrl, title: detail.title);
  }

  @override
  Widget build(BuildContext context) {
    // Only fall back to a full-screen loader/error when there's nothing at
    // all to show yet (no preview title/image from the list card either) -
    // otherwise keep the hero visible and confine the loading/error state
    // to the body area below it.
    final noPreviewAvailable = _heroTitle.isEmpty;
    final showFullScreenLoader = _isLoading && _detail == null && noPreviewAvailable;
    final showFullScreenError = _hasError && _detail == null && noPreviewAvailable;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: showFullScreenLoader
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : showFullScreenError
              ? _ErrorState(onRetry: _load)
              : CustomScrollView(
                  slivers: [
                    _buildHeroAppBar(),
                    SliverToBoxAdapter(child: _buildBody(context)),
                  ],
                ),
    );
  }

  Widget _buildHeroAppBar() {
    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: 360,
      backgroundColor: AppColors.surfaceContainerLow,
      foregroundColor: AppColors.onDark,
      iconTheme: const IconThemeData(color: AppColors.onDark),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            _heroImage.isEmpty
                ? Container(color: AppColors.surfaceContainerHigh)
                : Image.network(
                    _heroImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surfaceContainerHigh,
                      child: Icon(
                        Icons.image_not_supported_rounded,
                        size: 56,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    // Slightly stronger than a pure 0.15 wash so the AppBar's
                    // back icon stays legible even over a bright hero photo.
                    AppColors.scrim.withValues(alpha: 0.3),
                    AppColors.scrim.withValues(alpha: 0.35),
                    AppColors.scrim.withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_detail != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _contentTypeLabel(_detail!.contentType),
                        style: const TextStyle(
                          fontFamily: 'Peyda',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    _heroTitle.isEmpty ? ' ' : _heroTitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Peyda',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.35,
                      color: AppColors.onDark,
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

  Widget _buildBody(BuildContext context) {
    final detail = _detail;
    if (detail == null) {
      // Preview data got the hero on screen, but the real payload is either
      // still on its way or never arrived - tell those two apart.
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _ErrorState(onRetry: _load, compact: true),
      );
    }

    final createdLabel = _formatDate(detail.createdAt);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Meta row: publish date + source
          Wrap(
            spacing: 16,
            runSpacing: 10,
            children: [
              if (createdLabel.isNotEmpty)
                _MetaChip(icon: Icons.access_time_rounded, label: createdLabel),
              if (detail.source.isNotEmpty)
                _MetaChip(icon: Icons.source_rounded, label: detail.source),
            ],
          ),

          if (detail.summary.trim().isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border(
                  right: BorderSide(color: AppColors.primary, width: 4),
                ),
              ),
              child: Text(
                detail.summary,
                style: TextStyle(
                  fontFamily: 'Peyda',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  height: 1.7,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          Html(
            data: ScrapedHtmlSanitizer.clean(detail.bodyHtml),
            style: _htmlStyle,
            onLinkTap: (url, attributes, element) {
              if (url != null && url.trim().isNotEmpty) {
                InAppBrowserScreen.open(context, url: url);
              }
            },
          ),

          if (detail.extraImgList.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: detail.extraImgList.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    detail.extraImgList[index],
                    width: 200,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 200,
                      height: 140,
                      color: AppColors.surfaceContainerHigh,
                      child: Icon(Icons.image_not_supported_rounded, color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          if (detail.hasExternalUrl) ...[
            const SizedBox(height: 16),
            Material(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _openExternalUrl,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.16),
                        ),
                        child: const Icon(Icons.public_rounded, color: AppColors.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مشاهده خبر در سایت اصلی',
                              style: TextStyle(
                                fontFamily: 'Peyda',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'نمایش صفحه کامل خبر در مرورگر داخلی اپلیکیشن',
                              style: TextStyle(
                                fontFamily: 'Peyda',
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_left_rounded, color: AppColors.primary, size: 28),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Map<String, Style> get _htmlStyle => {
        'body': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontFamily: 'Peyda',
          fontSize: FontSize(17),
          color: AppColors.onSurface,
          lineHeight: LineHeight(1.6),
        ),
        'p': Style(
          margin: Margins.only(bottom: 14),
          fontFamily: 'Peyda',
          fontSize: FontSize(17),
          color: AppColors.onSurface,
          lineHeight: LineHeight(1.6),
        ),
        'h1': Style(fontFamily: 'Peyda', fontWeight: FontWeight.bold, color: AppColors.onSurface),
        'h2': Style(fontFamily: 'Peyda', fontWeight: FontWeight.bold, color: AppColors.onSurface),
        'h3': Style(fontFamily: 'Peyda', fontWeight: FontWeight.bold, color: AppColors.onSurface),
        'h4': Style(fontFamily: 'Peyda', fontWeight: FontWeight.bold, color: AppColors.onSurface),
        'h5': Style(fontFamily: 'Peyda', fontWeight: FontWeight.bold, color: AppColors.onSurface),
        'a': Style(
          color: AppColors.primary,
          textDecoration: TextDecoration.underline,
        ),
        'img': Style(
          width: Width(100, Unit.percent),
          margin: Margins.symmetric(vertical: 16),
        ),
        'div': Style(margin: Margins.zero, padding: HtmlPaddings.zero),
      };
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Peyda',
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  final bool compact;

  const _ErrorState({required this.onRetry, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: compact ? 12 : 0, horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: compact ? 40 : 56, color: AppColors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'دریافت جزئیات خبر ممکن نشد.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Peyda',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.onSurface,
                side: BorderSide(color: AppColors.outlineVariant),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('تلاش مجدد', style: TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
