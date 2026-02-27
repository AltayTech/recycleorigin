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

  /// Initialize configuration
  /// Call this in main() before runApp()
  /// Loads .env from assets (bundled) so it works on device/emulator.
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
      _isInitialized = true;
      AppLogger.info(
        'App configuration loaded from .env file. API_BASE_URL=${apiBaseUrl}',
      );
    } catch (e) {
      _isInitialized = false;
      AppLogger.info(
        'No .env loaded, using default. API_BASE_URL=$apiBaseUrl',
      );
    }
  }
}
