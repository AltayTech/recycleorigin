import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:recycleorigin/core/utils/logger.dart';

/// Tokens returned by the Identity Toolkit REST sign-in / sign-up endpoints.
class IdentityToolkitTokens {
  const IdentityToolkitTokens({
    required this.idToken,
    required this.refreshToken,
  });

  final String idToken;
  final String refreshToken;
}

/// Failure surfaced by [FirebaseIdentityToolkit] REST calls.
class IdentityToolkitFailure implements Exception {
  const IdentityToolkitFailure(this.status, this.message);

  /// Firebase error message, e.g. `INVALID_PASSWORD`.
  final String status;
  final String message;

  @override
  String toString() => 'IdentityToolkitFailure($status): $message';
}

/// Maps Identity Toolkit error messages to stable [AuthErrorCodes] strings.
String identityToolkitStatusToAuthCode(String status) {
  switch (status.toUpperCase()) {
    case 'EMAIL_NOT_FOUND':
      return 'user-not-found';
    case 'INVALID_PASSWORD':
    case 'INVALID_LOGIN_CREDENTIALS':
      return 'wrong-password';
    case 'INVALID_EMAIL':
      return 'invalid-email';
    case 'EMAIL_EXISTS':
      return 'email-already-in-use';
    case 'WEAK_PASSWORD':
    case 'PASSWORD_DOES_NOT_MEET_REQUIREMENTS':
      return 'weak-password';
    case 'TOO_MANY_ATTEMPTS_TRY_LATER':
    case 'NETWORK_REQUEST_FAILED':
      return 'network-request-failed';
    default:
      return 'unknown';
  }
}

/// Thin client for the Firebase Identity Toolkit REST API.
///
/// Used as a fallback when the native Firebase Auth SDK is blocked by
/// Play Integrity / reCAPTCHA on emulators or misconfigured debug builds.
class FirebaseIdentityToolkit {
  FirebaseIdentityToolkit({Dio? client, String? apiKey})
    : _client =
          client ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          ),
      _apiKeyOverride = apiKey;

  static const _baseUrl = 'https://identitytoolkit.googleapis.com/v1';

  final Dio _client;
  final String? _apiKeyOverride;

  String get _apiKey {
    final override = _apiKeyOverride;
    if (override != null && override.isNotEmpty) {
      return override;
    }
    try {
      return Firebase.app().options.apiKey;
    } catch (e, st) {
      AppLogger.error(
        'Firebase API key unavailable for Identity Toolkit',
        error: e,
        stackTrace: st,
      );
      throw const IdentityToolkitFailure(
        'CONFIGURATION_NOT_FOUND',
        'Firebase is not initialized',
      );
    }
  }

  Future<IdentityToolkitTokens> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final data = await _post('accounts:signInWithPassword', {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    });
    return _tokensFromResponse(data);
  }

  Future<IdentityToolkitTokens> signUp({
    required String email,
    required String password,
  }) async {
    final data = await _post('accounts:signUp', {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    });
    return _tokensFromResponse(data);
  }

  Future<void> updateDisplayName({
    required String idToken,
    required String displayName,
  }) async {
    await _post('accounts:update', {
      'idToken': idToken,
      'displayName': displayName,
      'returnSecureToken': false,
    });
  }

  Future<void> sendEmailVerification(String idToken) async {
    await _post('accounts:sendOobCode', {
      'requestType': 'VERIFY_EMAIL',
      'idToken': idToken,
    });
  }

  Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '$_baseUrl/$endpoint',
        queryParameters: {'key': _apiKey},
        data: body,
      );
      return response.data ?? const <String, dynamic>{};
    } on IdentityToolkitFailure {
      rethrow;
    } on DioException catch (e) {
      throw _fromDio(e);
    } on Object catch (e, st) {
      AppLogger.error(
        'Identity Toolkit request failed',
        error: e,
        stackTrace: st,
      );
      throw IdentityToolkitFailure('UNKNOWN', e.toString());
    }
  }

  IdentityToolkitTokens _tokensFromResponse(Map<String, dynamic> data) {
    final idToken = (data['idToken'] as String?) ?? '';
    final refreshToken = (data['refreshToken'] as String?) ?? '';
    if (idToken.isEmpty) {
      throw const IdentityToolkitFailure(
        'UNKNOWN',
        'Identity Toolkit did not return an ID token',
      );
    }
    return IdentityToolkitTokens(
      idToken: idToken,
      refreshToken: refreshToken,
    );
  }

  IdentityToolkitFailure _fromDio(DioException e) {
    final responseData = e.response?.data;
    if (responseData is Map<String, dynamic>) {
      final error = responseData['error'];
      if (error is Map<String, dynamic>) {
        final message = (error['message'] as String?) ?? 'UNKNOWN';
        return IdentityToolkitFailure(message, message);
      }
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return IdentityToolkitFailure(
        'NETWORK_REQUEST_FAILED',
        e.message ?? 'Network request failed',
      );
    }
    return IdentityToolkitFailure(
      'UNKNOWN',
      e.response?.data?.toString() ?? e.message ?? 'Request failed',
    );
  }
}
