import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/theme/app_colors.dart';

/// A reusable in-app browser screen. Kiosk devices often have no default
/// browser configured (and no way to switch back to this app afterwards),
/// so every "open this external link" action in the project should route
/// through here rather than the system browser - see [open] for the entry
/// point any feature can call.
class InAppBrowserScreen extends StatefulWidget {
  final String url;
  final String? title;

  const InAppBrowserScreen({super.key, required this.url, this.title});

  /// Pushes the in-app browser on top of the current route.
  static Future<void> open(BuildContext context, {required String url, String? title}) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => InAppBrowserScreen(url: url, title: title)),
    );
  }

  @override
  State<InAppBrowserScreen> createState() => _InAppBrowserScreenState();
}

class _InAppBrowserScreenState extends State<InAppBrowserScreen> {
  late final WebViewController _controller;

  double _progress = 0;
  bool _isLoading = true;
  bool _hasError = false;
  String? _pageTitle;

  @override
  void initState() {
    super.initState();
    _pageTitle = widget.title;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) return;
            setState(() => _progress = progress / 100);
          },
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (_) async {
            final title = await _controller.getTitle();
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              if (title != null && title.trim().isNotEmpty) _pageTitle = title;
            });
          },
          onWebResourceError: (error) {
            // A failed sub-resource (an ad, a tracking pixel...) shouldn't
            // blank out a page that otherwise loaded fine - only bail out
            // to the error state when the main document itself failed.
            if (error.isForMainFrame == false) return;
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  String get _host {
    try {
      return Uri.parse(widget.url).host;
    } catch (_) {
      return '';
    }
  }

  /// Steps back through the page's own navigation history first; only
  /// leaves the browser once there's nowhere left to go back to.
  Future<void> _handleBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    } else if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceContainerLow,
          foregroundColor: AppColors.onSurface,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_rounded),
            tooltip: 'بازگشت',
            onPressed: _handleBack,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _pageTitle?.trim().isNotEmpty == true ? _pageTitle! : 'در حال بارگذاری...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Peyda',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_host.isNotEmpty)
                Text(
                  _host,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Peyda',
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'بارگذاری مجدد',
              onPressed: () => _controller.reload(),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'بستن و بازگشت به اپلیکیشن',
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 4),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isLoading ? 1 : 0,
              child: LinearProgressIndicator(
                value: _progress == 0 ? null : _progress,
                minHeight: 3,
                backgroundColor: AppColors.outlineVariant,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_hasError) _BrowserErrorView(onRetry: () => _controller.reload()),
          ],
        ),
      ),
    );
  }
}

class _BrowserErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _BrowserErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 56, color: AppColors.onSurfaceVariant),
            const SizedBox(height: 20),
            Text(
              'بارگذاری این صفحه ممکن نشد.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Peyda',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'اتصال اینترنت دستگاه را بررسی کنید و دوباره تلاش کنید.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Peyda',
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'تلاش مجدد',
                style: TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
