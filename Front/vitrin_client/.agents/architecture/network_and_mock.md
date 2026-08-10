# Network Architecture, Constants & Mock Strategy Specification

## 1. AppConfig & AppConstants Management

Global parameters are managed via `AppConstants` (`lib/core/constants/app_constants.dart`) and dynamic environment configurations via `AppConfig` (`lib/core/config/app_config.dart`).

```dart
// lib/core/constants/app_constants.dart
abstract class AppConstants {
  static const String appName = 'شرکت مس درآلو - ویترین';
  static const String kioskLocation = 'ساختمان مرکزی | لابی';
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const String defaultKioskId = 'KIOSK_LOBBY_CENTRAL_01';
  static const String emergencyExtension = '۹۱۱';
}

// lib/core/config/app_config.dart
class AppConfig {
  final bool isDebug;
  final String baseUrl;
  final String kioskId;
  final Duration mockDelay;

  const AppConfig({
    required this.isDebug,
    required this.baseUrl,
    required this.kioskId,
    this.mockDelay = const Duration(milliseconds: 600),
  });

  static AppConfig current = const AppConfig(
    isDebug: true,
    baseUrl: 'https://api.daralou.ir/v1/kiosk',
    kioskId: AppConstants.defaultKioskId,
  );
}
```

---

## 2. CoreHttpClient with Dio

ALL remote HTTP network traffic must pass through `CoreHttpClient`. Direct instantiation of raw `Dio` or `http` inside feature services or repositories is strictly forbidden.

### Key Features of `CoreHttpClient`:
1. **Configured Base Options:** Timeouts bound to 10s via `AppConstants.connectTimeout` to prevent kiosk UI hangs.
2. **Interceptors Pipeline:**
   - `KioskHeaderInterceptor`: Injects `X-Kiosk-ID`, `X-App-Version`, and `Accept-Language: fa`.
   - `AuthTokenInterceptor`: Injects Bearer JWT tokens and handles seamless token refresh.
   - `LoggingInterceptor`: Formatted console logs during `isDebug == true`.
   - `ErrorInterceptor`: Normalizes network errors and delegates to `GlobalSnackBar`.

```dart
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../constants/app_constants.dart';

class CoreHttpClient {
  late final Dio dio;

  CoreHttpClient({required AppConfig config}) {
    dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Kiosk-ID': config.kioskId,
        },
      ),
    );

    dio.interceptors.addAll([
      KioskHeaderInterceptor(config),
      AuthTokenInterceptor(),
      if (config.isDebug) CustomLoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }
}
```

---

## 3. Global Error Handling & SnackBar System

Errors are handled seamlessly without displaying native red crash screens or interrupting kiosk uptime.

1. **Global Scaffold Messenger Key:** Defined in `lib/core/utils/global_keys.dart`.
2. **`GlobalSnackBar` Utility:** Dispatches visual, floating snackbars styled according to the design system.
3. **Automatic Translation:** Translates HTTP errors (400, 401, 403, 500, socket timeout) into clear Persian notification strings.

---

## 4. Offline & Mock Data Strategy per Feature

To satisfy continuous 24/7 kiosk operation requirements:
- Every feature folder contains a dedicated `mock/` subfolder (e.g., `lib/features/leave_registration/mock/`).
- When `AppConfig.current.isDebug == true` or when `CoreHttpClient` throws a socket/network exception, services fallback automatically to feature mock data.
