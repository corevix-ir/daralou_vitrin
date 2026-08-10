import 'package:dio/dio.dart';
import '../../../../core/network/core_http_client.dart';
import '../../../../core/network/auth_token_storage.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthService {
  final CoreHttpClient _client = CoreHttpClient.instance;
  final AuthTokenStorage _storage = AuthTokenStorage.instance;

  Future<bool> login(String username, String password) async {
    try {
      final request = LoginRequest(username: username, password: password);
      final response = await _client.dio.post(
        '/auth/login',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final loginRes = LoginResponse.fromJson(response.data);
        if (loginRes.accessToken.isNotEmpty) {
          await _storage.saveTokens(
            accessToken: loginRes.accessToken,
            refreshToken: loginRes.refreshToken,
            username: username,
          );
          return true;
        }
      }
    } on DioException catch (_) {
      rethrow;
    }
    return false;
  }

  Future<void> logout() async {
    await _storage.clearTokens();
  }

  Future<bool> isLoggedIn() async {
    return await _storage.isLoggedIn();
  }

  Future<String?> getUsername() async {
    return await _storage.getUsername();
  }
}
