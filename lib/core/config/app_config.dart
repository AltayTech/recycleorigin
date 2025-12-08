import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:recycleorigin/core/utils/logger.dart';

/// Application configuration
///
/// Manages environment variables and app-wide configuration settings.
/// Load environment variables using: await dotenv.load(fileName: ".env");
class AppConfig {
  static bool _isInitialized = false;

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

  static String get apiBaseUrl {
    final url = _getEnv('API_BASE_URL') ?? 'https://recycleorigin.com/rest/';
    if (url.isEmpty) {
      AppLogger.warning('API_BASE_URL not set, using default');
      return 'https://recycleorigin.com/rest/';
    }
    return url;
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

  /// Initialize configuration
  /// Call this in main() before runApp()
  static Future<void> initialize() async {
    try {
      // Try to load .env file, but don't fail if it doesn't exist
      // The app will use default values defined in the getters
      await dotenv.load(fileName: '.env');
      _isInitialized = true;
      AppLogger.info('App configuration loaded from .env file');
    } catch (e) {
      // .env file doesn't exist or couldn't be loaded
      // This is okay - we'll use default values
      _isInitialized = false;
      AppLogger.info('No .env file found, using default configuration');
    }
  }
}
