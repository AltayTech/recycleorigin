import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:recycleorigin/core/utils/logger.dart';

/// Secure storage utility for sensitive data
///
/// Uses flutter_secure_storage which encrypts data using platform-specific
/// secure storage mechanisms (Keychain on iOS, KeyStore on Android).
class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,

    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Save authentication token securely
  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: 'token', value: token);
      AppLogger.debug('Token saved securely');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save token securely',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get authentication token
  static Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: 'token');
      return token;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to read token', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Delete authentication token
  static Future<void> deleteToken() async {
    try {
      await _storage.delete(key: 'token');
      AppLogger.debug('Token deleted');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete token',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Save user data securely
  static Future<void> saveUserData(String userData) async {
    try {
      await _storage.write(key: 'userData', value: userData);
      AppLogger.debug('User data saved securely');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save user data',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get user data
  static Future<String?> getUserData() async {
    try {
      return await _storage.read(key: 'userData');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to read user data',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Save login status
  static Future<void> saveLoginStatus(bool isLoggedIn) async {
    try {
      await _storage.write(key: 'isLogin', value: isLoggedIn.toString());
      AppLogger.debug('Login status saved');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save login status',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get login status
  static Future<bool> getLoginStatus() async {
    try {
      final status = await _storage.read(key: 'isLogin');
      return status == 'true';
    } catch (e, stackTrace) {
      AppLogger.error('Failed to read login status',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Clear all secure storage
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      AppLogger.debug('All secure storage cleared');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to clear secure storage',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
