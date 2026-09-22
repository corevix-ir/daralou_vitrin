class AppConfig {
  final bool isDebug;
  final String baseUrl;
  final String updateCheckUrl;
  final String updateApkUrl;

  const AppConfig({
    required this.isDebug,
    required this.baseUrl,
    this.updateCheckUrl = '',
    this.updateApkUrl = '',
  });

  static AppConfig current = const AppConfig(
    isDebug: true,
    baseUrl:
        'https://vitrin.wikm.ir/', // Replace or update base URL as required
    updateCheckUrl: 'https://wikm.ir/vitrin/', // آدرس صفحه HTML حاوی شماره نسخه
    updateApkUrl:
        'https://wikm.ir/vitrin/app-release.apk', // آدرس فایل APK جهت دانلود نسخه جدید
  );

  /// The backend returns media (e.g. `main_img`) as a path relative to
  /// itself (`/static/news/xxx.jpg`), not a full URL - resolve it against
  /// [baseUrl] so `Image.network` gets something it can actually fetch.
  /// Already-absolute URLs (or an empty path) pass through unchanged.
  static String resolveMediaUrl(String path) {
    if (path.isEmpty) return path;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;

    final base =
        current.baseUrl.endsWith('/')
            ? current.baseUrl.substring(0, current.baseUrl.length - 1)
            : current.baseUrl;
    final suffix = path.startsWith('/') ? path : '/$path';
    return '$base$suffix';
  }
}
