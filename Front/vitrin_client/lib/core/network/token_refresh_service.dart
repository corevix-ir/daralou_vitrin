import 'dart:async';
import 'package:dio/dio.dart';
import '../auth/auth_state.dart';
import '../config/app_config.dart';
import 'auth_token_storage.dart';
import 'interceptors/logging_interceptor.dart';
import 'jwt_utils.dart';

/// Single place that performs the `/auth/refresh` call.
///
/// Two things trigger a refresh: the [AuthInterceptor] reacting to a 401,
/// and a proactive timer scheduled from the access token's own `exp` claim.
/// Without the proactive timer, a kiosk left logged in but idle (no API
/// calls firing) for long enough lets both the access AND refresh token
/// quietly expire, and by the time some request finally 401s there is
/// nothing left to refresh with. [refreshNow] de-duplicates concurrent
/// callers so both triggers never race each other over the same
/// (single-use, rotated) refresh token.
class TokenRefreshService {
  TokenRefreshService._internal();
  static final TokenRefreshService instance = TokenRefreshService._internal();

  static const _refreshMargin = Duration(seconds: 45);

  final AuthTokenStorage _storage = AuthTokenStorage.instance;
  Future<bool>? _inFlight;
  Timer? _proactiveTimer;

  Future<bool> refreshNow() {
    return _inFlight ??= _performRefresh().whenComplete(() => _inFlight = null);
  }

  void scheduleProactiveRefresh(String accessToken) {
    _proactiveTimer?.cancel();
    final expiry = JwtUtils.getExpiry(accessToken);
    if (expiry == null) return;

    var delay = expiry.difference(DateTime.now()) - _refreshMargin;
    if (delay.isNegative) delay = const Duration(seconds: 2);
    _proactiveTimer = Timer(delay, () => refreshNow());
  }

  void cancelProactiveRefresh() {
    _proactiveTimer?.cancel();
    _proactiveTimer = null;
  }

  Future<bool> _performRefresh() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: AppConfig.current.baseUrl,
          connectTimeout: const Duration(seconds: 8),
        ),
      )..interceptors.add(LoggingInterceptor());
      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final newAccess = (data['access_token'] ?? data['access'] ?? '').toString();
        final newRefresh = (data['refresh_token'] ?? data['refresh'] ?? refreshToken).toString();
        final username = await _storage.getUsername() ?? '';

        if (newAccess.isNotEmpty) {
          await _storage.saveTokens(
            accessToken: newAccess,
            refreshToken: newRefresh,
            username: username,
          );
          // Re-reads storage and reschedules the proactive timer from the
          // freshly-rotated access token's own expiry.
          await AuthState.instance.refresh();
          return true;
        }
      }
    } catch (_) {
      // Falls through to the failure path below.
    }

    // The refresh token itself is expired/invalid - nothing left to do but
    // drop back to the login screen.
    await _storage.clearTokens();
    await AuthState.instance.refresh();
    return false;
  }
}
