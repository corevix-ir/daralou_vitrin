abstract class AppConstants {
  static const String appName = 'شرکت مس درآلو - ویترین';
  static const String kioskLocation = 'ساختمان مرکزی | لابی';
  static const Duration connectTimeout = Duration(seconds: 12);
  static const Duration receiveTimeout = Duration(seconds: 12);
  static const String defaultKioskId = 'KIOSK_LOBBY_CENTRAL_01';
  static const String emergencyText =
      'وضعیت سیستم: فعال | پروتکل اضطراری فعال: با امنیت سایت داخلی ۹۱۱ تماس بگیرید';

  // Local storage keys
  static const String keyAccessToken = 'kiosk_access_token';
  static const String keyRefreshToken = 'kiosk_refresh_token';
  static const String keyIsLoggedIn = 'kiosk_is_logged_in';
  static const String keyUsername = 'kiosk_username';

  // Password gate for the admin settings panel (client-side only for now,
  // there is no backend endpoint for it yet). Change this value to rotate it.
  static const String adminPanelPassword = '1010';
}
