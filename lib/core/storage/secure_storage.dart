import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:recycleorigin/core/utils/logger.dart';

/// Secure storage utility for sensitive data.
///
/// Uses flutter_secure_storage which encrypts data using platform-specific
/// secure storage mechanisms (Keychain on iOS, KeyStore on Android).
///
/// Storage keys:
///   - `accessToken`: short-lived backend JWT used for API authorization.
///   - `refreshToken`: opaque rotating refresh token used to obtain a new
///     access token without re-authenticating the user.
///   - `token`: legacy alias for the access token. Kept for compatibility
///     with code that has not been migrated to the new APIs yet — every read
///     and write of `accessToken` mirrors `token` and vice versa.
///   - `userData`: cached profile JSON (display name, email, role, etc.).
///   - `isLogin`: persisted login status flag.
class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const _keyAccessToken = 'accessToken';
  static const _keyRefreshToken = 'refreshToken';
  static const _keyLegacyToken = 'token';
  static const _keyUserData = 'userData';
  static const _keyIsLogin = 'isLogin';
  static const _keyFirebaseRefresh = 'firebaseRefreshToken';

  /// Save the backend access token. Mirrored to the legacy `token` key for
  /// callers that have not yet migrated.
  static Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: _keyAccessToken, value: token);
      await _storage.write(key: _keyLegacyToken, value: token);
      AppLogger.debug('Access token saved securely');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to save access token',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Read the backend access token. Falls back to the legacy `token` key for
  /// older sessions that were stored before this refactor.
  static Future<String?> getAccessToken() async {
    try {
      final value = await _storage.read(key: _keyAccessToken);
      if (value != null && value.isNotEmpty) {
        return value;
      }
      return await _storage.read(key: _keyLegacyToken);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to read access token',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Save the rotating refresh token.
  static Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _keyRefreshToken, value: token);
      AppLogger.debug('Refresh token saved securely');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to save refresh token',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Read the rotating refresh token. Returns null when no session exists.
  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _keyRefreshToken);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to read refresh token',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Delete the refresh token (e.g. on logout).
  static Future<void> deleteRefreshToken() async {
    try {
      await _storage.delete(key: _keyRefreshToken);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to delete refresh token',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Legacy alias for [saveAccessToken].
  static Future<void> saveToken(String token) => saveAccessToken(token);

  /// Legacy alias for [getAccessToken].
  static Future<String?> getToken() => getAccessToken();

  /// Delete every credential (access + refresh + legacy).
  static Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _keyAccessToken);
      await _storage.delete(key: _keyRefreshToken);
      await _storage.delete(key: _keyLegacyToken);
      await _storage.delete(key: _keyFirebaseRefresh);
      AppLogger.debug('Tokens deleted');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to delete tokens',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Firebase Identity Toolkit refresh token used when Play Integrity /
  /// reCAPTCHA blocked the native SDK from creating a [FirebaseAuth] session.
  static Future<void> saveFirebaseRefreshToken(String token) async {
    try {
      await _storage.write(key: _keyFirebaseRefresh, value: token);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to save Firebase refresh token',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<String?> getFirebaseRefreshToken() async {
    try {
      return await _storage.read(key: _keyFirebaseRefresh);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to read Firebase refresh token',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  static Future<void> deleteFirebaseRefreshToken() async {
    try {
      await _storage.delete(key: _keyFirebaseRefresh);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to delete Firebase refresh token',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<void> saveUserData(String userData) async {
    try {
      await _storage.write(key: _keyUserData, value: userData);
      AppLogger.debug('User data saved securely');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to save user data',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<String?> getUserData() async {
    try {
      return await _storage.read(key: _keyUserData);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to read user data',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  static Future<void> saveLoginStatus(bool isLoggedIn) async {
    try {
      await _storage.write(key: _keyIsLogin, value: isLoggedIn.toString());
      AppLogger.debug('Login status saved');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to save login status',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<bool> getLoginStatus() async {
    try {
      final status = await _storage.read(key: _keyIsLogin);
      return status == 'true';
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to read login status',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Clear all secure storage.
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      AppLogger.debug('All secure storage cleared');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to clear secure storage',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
