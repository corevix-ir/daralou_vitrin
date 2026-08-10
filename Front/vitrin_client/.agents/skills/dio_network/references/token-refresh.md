# JWT Token Refresh Pipeline with QueuedInterceptor

## Overview
Kiosk terminals run continuously 24/7. Access tokens expire periodically. To prevent interactive requests (like leave registration or feedback submission) from failing with `401 Unauthorized`, a transparent queued refresh interceptor handles token renewal in the background.

---

## 1. Token Refresh Interceptor Implementation

```dart
import 'package:dio/dio.dart';

class AuthTokenInterceptor extends QueuedInterceptor {
  String? _accessToken;
  String? _refreshToken;

  AuthTokenInterceptor([this._accessToken, this._refreshToken]);

  void updateTokens(String accessToken, String refreshToken) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_accessToken';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && _refreshToken != null) {
      try {
        final refreshedSuccessfully = await _performTokenRefresh();
        if (refreshedSuccessfully) {
          // Retry original request with new access token
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $_accessToken';
          
          final retryClient = Dio(BaseOptions(baseUrl: options.baseUrl));
          final response = await retryClient.fetch(options);
          return handler.resolve(response);
        }
      } catch (e) {
        // Token refresh failed completely
      }
    }
    handler.next(err);
  }

  Future<bool> _performTokenRefresh() async {
    try {
      final refreshDio = Dio();
      final response = await refreshDio.post(
        'https://api.daralou.ir/v1/kiosk/auth/refresh',
        data: {'refresh_token': _refreshToken},
      );

      if (response.statusCode == 200) {
        _accessToken = response.data['access_token'];
        _refreshToken = response.data['refresh_token'];
        return true;
      }
    } catch (_) {}
    return false;
  }
}
```
