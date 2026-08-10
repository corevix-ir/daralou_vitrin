class AppConfig {
  final bool isDebug;
  final String baseUrl;

  const AppConfig({required this.isDebug, required this.baseUrl});

  static AppConfig current = const AppConfig(
    isDebug: false,
    baseUrl: 'http://localhost:5749/', // Replace or update base URL as required
  );
}
