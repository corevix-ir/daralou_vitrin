class AppConfig {
  final bool isDebug;
  final String baseUrl;

  const AppConfig({required this.isDebug, required this.baseUrl});

  static AppConfig current = const AppConfig(
    isDebug: true,
    baseUrl: 'http://localhost:5749/', // Replace or update base URL as required
  );

  /// The backend returns media (e.g. `main_img`) as a path relative to
  /// itself (`/static/news/xxx.jpg`), not a full URL - resolve it against
  /// [baseUrl] so `Image.network` gets something it can actually fetch.
  /// Already-absolute URLs (or an empty path) pass through unchanged.
  static String resolveMediaUrl(String path) {
    if (path.isEmpty) return path;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;

    final base = current.baseUrl.endsWith('/')
        ? current.baseUrl.substring(0, current.baseUrl.length - 1)
        : current.baseUrl;
    final suffix = path.startsWith('/') ? path : '/$path';
    return '$base$suffix';
  }
}
