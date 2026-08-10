import 'package:dio/dio.dart';
import '../auth_token_storage.dart';
import '../../config/app_config.dart';

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
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          final refreshed = await _refreshTokens(refreshToken);
          if (refreshed) {
            final newToken = await tokenStorage.getAccessToken();
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';

            final retryDio = Dio(BaseOptions(baseUrl: options.baseUrl));
            final response = await retryDio.fetch(options);
            return handler.resolve(response);
          }
        } catch (_) {
          await tokenStorage.clearTokens();
        }
      }
    }
    handler.next(err);
  }

  Future<bool> _refreshTokens(String refreshToken) async {
    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: AppConfig.current.baseUrl,
          connectTimeout: const Duration(seconds: 8),
        ),
      );

      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final newAccess = data['access_token'] ?? data['access'] ?? '';
        final newRefresh = data['refresh_token'] ?? data['refresh'] ?? refreshToken;
        final username = await tokenStorage.getUsername() ?? 'admin';

        if (newAccess.toString().isNotEmpty) {
          await tokenStorage.saveTokens(
            accessToken: newAccess.toString(),
            refreshToken: newRefresh.toString(),
            username: username,
          );
          return true;
        }
      }
    } catch (_) {}
    return false;
  }
}
