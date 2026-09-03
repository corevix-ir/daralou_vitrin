import 'dart:convert';

/// Minimal JWT payload reader used only to pull the `exp` (expiry) claim so
/// a refresh can be scheduled ahead of time. This does not verify the
/// token's signature - the backend remains the source of truth for that.
class JwtUtils {
  const JwtUtils._();

  static DateTime? getExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = jsonDecode(_decodeBase64(parts[1])) as Map<String, dynamic>;
      final exp = payload['exp'];
      final seconds = exp is num ? exp.toInt() : int.tryParse(exp.toString());
      if (seconds == null) return null;

      return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true).toLocal();
    } catch (_) {
      return null;
    }
  }

  static String _decodeBase64(String input) {
    var normalized = input.replaceAll('-', '+').replaceAll('_', '/');
    switch (normalized.length % 4) {
      case 2:
        normalized += '==';
        break;
      case 3:
        normalized += '=';
        break;
    }
    return utf8.decode(base64.decode(normalized));
  }
}
