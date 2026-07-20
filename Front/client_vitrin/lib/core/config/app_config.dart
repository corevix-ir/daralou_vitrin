/// Central configuration for the application environment, endpoints, and flags.
class AppConfig {
  AppConfig._();

  /// Static debug flag. When true, [HomeService] bypasses live network calls
  /// and returns static mock data from `home_mock_data.dart`.
  static const bool isDebug = true;

  /// Base API URL for Daralou Copper Corporation endpoints
  static const String baseUrl = 'https://api.daraloocopper.ir/v1';

  /// Connection and timeout duration for network requests
  static const Duration timeout = Duration(seconds: 10);

  /// Application title / Brand name
  static const String appTitle = 'شرکت مس درآلو - کیوسک دیجیتال';

  /// Kiosk resolution dimensions (55-inch portrait digital signage: 1080x1920)
  static const double targetWidth = 1080.0;
  static const double targetHeight = 1920.0;
}
