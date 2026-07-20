import 'package:dio/dio.dart';

/// Interceptor responsible for injecting access token headers into outgoing requests
/// and attempting refresh token authorization flow on 401 unauthorized errors.
class AuthInterceptor extends Interceptor {
  String? _accessToken;
  String? _refreshToken;

  AuthInterceptor({String? accessToken, String? refreshToken})
      : _accessToken = accessToken,
        _refreshToken = refreshToken;

  void updateTokens({required String accessToken, String? refreshToken}) {
    _accessToken = accessToken;
    if (refreshToken != null) {
      _refreshToken = refreshToken;
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_accessToken';
    }
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';
    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && _refreshToken != null) {
      // Attempt token refresh logic
      final refreshed = await _attemptTokenRefresh();
      if (refreshed) {
        // Retry original request with new token
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $_accessToken';
        try {
          final dio = Dio();
          final response = await dio.fetch(opts);
          return handler.resolve(response);
        } catch (e) {
          return super.onError(err, handler);
        }
      }
    }
    return super.onError(err, handler);
  }

  Future<bool> _attemptTokenRefresh() async {
    // Simulated token refresh
    await Future.delayed(const Duration(milliseconds: 200));
    _accessToken = 'mock_refreshed_access_token';
    return true;
  }
}
