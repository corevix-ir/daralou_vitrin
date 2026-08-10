import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class AuthTokenStorage {
  static final AuthTokenStorage instance = AuthTokenStorage._internal();
  AuthTokenStorage._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String username,
  }) async {
    await init();
    await _prefs?.setString(AppConstants.keyAccessToken, accessToken);
    await _prefs?.setString(AppConstants.keyRefreshToken, refreshToken);
    await _prefs?.setString(AppConstants.keyUsername, username);
    await _prefs?.setBool(AppConstants.keyIsLoggedIn, true);
  }

  Future<String?> getAccessToken() async {
    await init();
    return _prefs?.getString(AppConstants.keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    await init();
    return _prefs?.getString(AppConstants.keyRefreshToken);
  }

  Future<String?> getUsername() async {
    await init();
    return _prefs?.getString(AppConstants.keyUsername);
  }

  Future<bool> isLoggedIn() async {
    await init();
    return _prefs?.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  Future<void> clearTokens() async {
    await init();
    await _prefs?.remove(AppConstants.keyAccessToken);
    await _prefs?.remove(AppConstants.keyRefreshToken);
    await _prefs?.remove(AppConstants.keyUsername);
    await _prefs?.setBool(AppConstants.keyIsLoggedIn, false);
  }
}
