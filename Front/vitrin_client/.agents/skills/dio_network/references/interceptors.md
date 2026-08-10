# Custom Dio Interceptors & Kiosk Headers Pipeline

## Overview
Interceptors in **vitrin_client** handle cross-cutting request metadata, security headers, and structured logging.

---

## 1. Kiosk Header Interceptor

Every HTTP request must identify the physical kiosk hardware, software version, and requested language context:

```dart
import 'package:dio/dio.dart';
import '../../config/app_config.dart';

class KioskHeaderInterceptor extends Interceptor {
  final AppConfig config;

  KioskHeaderInterceptor(this.config);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Kiosk-ID'] = config.kioskId;
    options.headers['X-Kiosk-OS'] = 'Android-Kiosk-55in';
    options.headers['Accept-Language'] = 'fa';
    options.headers['Client-Timestamp'] = DateTime.now().toIso8601String();
    
    super.onRequest(options, handler);
  }
}
```

---

## 2. Structured Kiosk Console Logging Interceptor

```dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class CustomLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('--> ${options.method.toUpperCase()} ${options.uri}');
      debugPrint('Headers: ${options.headers}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<-- ${response.statusCode} ${response.requestOptions.uri}');
    }
    super.onResponse(response, handler);
  }
}
```
