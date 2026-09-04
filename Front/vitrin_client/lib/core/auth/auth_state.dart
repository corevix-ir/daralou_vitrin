import 'package:flutter/foundation.dart';
import '../network/auth_token_storage.dart';
import '../network/token_refresh_service.dart';
import '../realtime/remote_command_service.dart';
import '../../features/auth/data/services/auth_service.dart';

/// Single source of truth for the device login state, shared by [AuthGate]
/// and the global floating assistive ball so both stay in sync without a
/// widget-tree relationship between them. Also owns (re)scheduling the
/// proactive token refresh timer whenever the logged-in access token
/// changes, since [TokenRefreshService] itself only knows how to run one.
class AuthState extends ChangeNotifier {
  AuthState._internal();
  static final AuthState instance = AuthState._internal();

  final AuthTokenStorage _storage = AuthTokenStorage.instance;
  final AuthService _authService = AuthService();

  bool isLoggedIn = false;
  String username = '';
  String location = '';
  String section = '';

  Future<void> refresh() async {
    isLoggedIn = await _storage.isLoggedIn();
    username = await _storage.getUsername() ?? '';

    if (isLoggedIn) {
      final accessToken = await _storage.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        TokenRefreshService.instance.scheduleProactiveRefresh(accessToken);
      }
      RemoteCommandService.instance.connect();

      final profile = await _authService.getProfile();
      if (profile != null) {
        location = profile.location;
        section = profile.section;
      }
    } else {
      TokenRefreshService.instance.cancelProactiveRefresh();
      RemoteCommandService.instance.disconnect();
      location = '';
      section = '';
    }

    notifyListeners();
  }

  Future<void> logout() async {
    TokenRefreshService.instance.cancelProactiveRefresh();
    RemoteCommandService.instance.disconnect();
    await _authService.logout();
    isLoggedIn = false;
    username = '';
    location = '';
    section = '';
    notifyListeners();
  }
}
