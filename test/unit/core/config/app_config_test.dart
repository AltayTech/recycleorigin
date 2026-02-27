import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigin/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    // Note: We don't manipulate dotenv.env directly to avoid NotInitializedError
    // Instead, we test the actual behavior of AppConfig which handles initialization

    setUp(() async {
      // Ensure AppConfig is initialized (it handles missing .env gracefully)
      try {
        await AppConfig.initialize();
      } catch (_) {
        // Already initialized or failed - that's okay
      }
    });

    group('apiBaseUrl', () {
      test('should return default URL when env variable not set', () {
        // AppConfig uses default when env variable is not set
        final url = AppConfig.apiBaseUrl;
        expect(url, 'https://recycleorigin.com/');
      });
    });

    group('apiRootUrl', () {
      test('should return default URL when env variable not set', () {
        final url = AppConfig.apiRootUrl;
        expect(url, 'https://recycleorigin.com/');
      });
    });

    group('googleMapsApiKey', () {
      test('should return empty string when not set', () {
        final key = AppConfig.googleMapsApiKey;
        expect(key, '');
      });
    });

    group('isProduction', () {
      test('should return false when ENVIRONMENT not set to production', () {
        // When ENVIRONMENT is not set or not 'production', should return false
        expect(AppConfig.isProduction, isFalse);
      });
    });

    group('isDevelopment', () {
      test('should return false when ENVIRONMENT not set to development', () {
        // When ENVIRONMENT is not set or not 'development', should return false
        expect(AppConfig.isDevelopment, isFalse);
      });
    });

    group('initialize', () {
      test('should handle missing .env file gracefully', () async {
        // This should not throw even if .env doesn't exist
        await AppConfig.initialize();
        expect(AppConfig.apiBaseUrl, 'https://recycleorigin.com/');
      });
    });

    group('Edge cases', () {
      test('should return default values when environment variables not set',
          () {
        // Test that defaults are returned when env vars are not set
        expect(AppConfig.apiBaseUrl, 'https://recycleorigin.com/');
        expect(AppConfig.apiRootUrl, 'https://recycleorigin.com/');
        expect(AppConfig.googleMapsApiKey, '');
        expect(AppConfig.isProduction, isFalse);
        expect(AppConfig.isDevelopment, isFalse);
      });
    });
  });
}
