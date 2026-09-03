import 'package:dio/dio.dart';
import '../auth_token_storage.dart';
import '../token_refresh_service.dart';
import 'logging_interceptor.dart';

class AuthInterceptor extends QueuedInterceptor {
  final AuthTokenStorage tokenStorage = AuthTokenStorage.instance;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Shared with the proactive refresh timer so the two never race each
      // other over the same (single-use, rotated) refresh token.
      final refreshed = await TokenRefreshService.instance.refreshNow();
      if (refreshed) {
        try {
          final newToken = await tokenStorage.getAccessToken();
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newToken';

          final retryDio = Dio(BaseOptions(baseUrl: options.baseUrl))
            ..interceptors.add(LoggingInterceptor());
          final response = await retryDio.fetch(options);
          return handler.resolve(response);
        } catch (_) {
          // Fall through and surface the original error below.
        }
      }
    }
    handler.next(err);
  }
}
