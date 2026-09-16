import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:recycleorigin/core/config/app_config_exception.dart';
import 'package:recycleorigin/core/utils/logger.dart';

/// Application configuration
///
/// Manages environment variables and app-wide configuration settings.
/// Load environment variables using: await dotenv.load(fileName: ".env");
class AppConfig {
  static bool _isInitialized = false;
  static String _activeEnvFile = 'assets/env/.env.dev';

  /// Safely get environment variable or return default
  static String? _getEnv(String key) {
    try {
      if (!_isInitialized) {
        return null;
      }
      return dotenv.env[key];
    } catch (e) {
      // dotenv not initialized
      return null;
    }
  }

  /// Backend API root (no trailing path). E.g. https://api.example.com/
  /// Do not include /rest; the backend serves at root.
  static String get apiBaseUrl {
    final url = _getEnv('API_BASE_URL') ?? 'https://recycleorigin.com/';
    if (url.isEmpty) {
      AppLogger.warning('API_BASE_URL not set, using default');
      return 'https://recycleorigin.com/';
    }
    return url.endsWith('/') ? url : '$url/';
  }

  static String get apiRootUrl {
    final url = _getEnv('API_ROOT_URL') ?? 'https://recycleorigin.com/';
    if (url.isEmpty) {
      AppLogger.warning('API_ROOT_URL not set, using default');
      return 'https://recycleorigin.com/';
    }
    return url;
  }

  static String get googleMapsApiKey {
    final key = _getEnv('GOOGLE_MAPS_API_KEY') ?? '';
    if (key.isEmpty) {
      AppLogger.warning('GOOGLE_MAPS_API_KEY not set');
    }
    return key;
  }

  static bool get isProduction {
    return _getEnv('ENVIRONMENT') == 'production';
  }

  static bool get isDevelopment {
    return _getEnv('ENVIRONMENT') == 'development';
  }

  /// Controls whether push registration should run on this build.
  ///
  /// Defaults to disabled on development env to avoid noisy FCM/FIS errors on
  /// local emulators without fully configured Google Play services.
  static bool get enablePushNotifications {
    final raw = _getEnv('ENABLE_PUSH_NOTIFICATIONS');
    if (raw == null || raw.isEmpty) {
      return !isDevelopment;
    }
    return raw.toLowerCase() == 'true';
  }

  /// When false, Store UI shows Coming Soon (catalog/cart/checkout stay in the
  /// codebase for a later launch). Defaults to off.
  static bool get enableStore {
    final raw = _getEnv('ENABLE_STORE');
    if (raw == null || raw.isEmpty) {
      return false;
    }
    switch (raw.toLowerCase()) {
      case '1':
      case 'true':
      case 'yes':
      case 'on':
        return true;
      default:
        return false;
    }
  }

  /// Initialize configuration
  /// Call this in main() before runApp()
  /// Loads .env from assets (bundled) so it works on device/emulator.
  static Future<void> initialize({required String envFile}) async {
    _activeEnvFile = envFile;
    try {
      await dotenv.load(fileName: envFile);
      _isInitialized = true;
      AppLogger.info(
        'App configuration loaded from $envFile. API_BASE_URL=${apiBaseUrl}',
      );
    } catch (e) {
      _isInitialized = false;
      AppLogger.info(
        'No env loaded from $_activeEnvFile, using default. API_BASE_URL=$apiBaseUrl',
      );
    }
    _validateProductionConfig();
  }

  static void _validateProductionConfig() {
    if (!isProduction) {
      return;
    }
    if (!_isInitialized) {
      throw AppConfigException(
        'Production build requires $_activeEnvFile to load successfully',
      );
    }
    if (!apiBaseUrl.startsWith('https://')) {
      throw AppConfigException(
        'Production API_BASE_URL must use HTTPS (got $apiBaseUrl)',
      );
    }
  }
}
