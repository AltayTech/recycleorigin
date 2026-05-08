import 'dart:convert';

/// Lightweight, dependency-free decoder for the payload of a JWT.
///
/// Tokens issued by the backend are HS256 access tokens. We only need to
/// read the public claims (e.g. `email_verified`, `role`); we never trust
/// these values for authorization — that always happens server-side. The
/// signature is intentionally not verified here.
Map<String, dynamic>? decodeJwtPayload(String token) {
  if (token.isEmpty) return null;
  final parts = token.split('.');
  if (parts.length != 3) return null;
  try {
    final normalized = base64Url.normalize(parts[1]);
    final payload = utf8.decode(base64Url.decode(normalized));
    final decoded = jsonDecode(payload);
    if (decoded is Map<String, dynamic>) return decoded;
    return null;
  } catch (_) {
    return null;
  }
}

/// Returns the value of `email_verified` from [token], or `false` if
/// the claim is missing or malformed.
bool jwtEmailVerified(String token) {
  final claims = decodeJwtPayload(token);
  final raw = claims?['email_verified'];
  if (raw is bool) return raw;
  return false;
}

/// Returns the value of `role` from [token], or an empty string.
String jwtRole(String token) {
  final claims = decodeJwtPayload(token);
  final raw = claims?['role'];
  return raw is String ? raw : '';
}

/// Returns the value of `provider` from [token], or an empty string.
String jwtProvider(String token) {
  final claims = decodeJwtPayload(token);
  final raw = claims?['provider'];
  return raw is String ? raw : '';
}
