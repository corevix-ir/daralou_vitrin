class LoginResponse {
  final String accessToken;
  final String refreshToken;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: (json['access_token'] ?? json['access'] ?? '').toString(),
      refreshToken: (json['refresh_token'] ?? json['refresh'] ?? '').toString(),
    );
  }
}
