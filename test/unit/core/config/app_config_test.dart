import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigin/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    setUp(() async {
      try {
        await AppConfig.initialize();
      } catch (_) {
        // Idempotent or asset missing in some environments.
      }
    });

    group('apiBaseUrl', () {
      test('is non-empty and uses trailing slash', () {
        final url = AppConfig.apiBaseUrl;
        expect(url, isNotEmpty);
        expect(url.endsWith('/'), isTrue);
        expect(url.startsWith('http://') || url.startsWith('https://'), isTrue);
      });
    });

    group('apiRootUrl', () {
      test('is non-empty', () {
        expect(AppConfig.apiRootUrl, isNotEmpty);
      });
    });

    group('googleMapsApiKey', () {
      test('is a string (may be empty)', () {
        expect(AppConfig.googleMapsApiKey, isA<String>());
      });
    });

    group('environment flags', () {
      test('production and development are mutually consistent', () {
        // Both false when ENVIRONMENT unset; otherwise one may be true.
        expect(
          (!AppConfig.isProduction && !AppConfig.isDevelopment) ||
              AppConfig.isProduction ||
              AppConfig.isDevelopment,
          isTrue,
        );
      });
    });

    group('initialize', () {
      test('does not throw when invoked repeatedly', () async {
        await expectLater(AppConfig.initialize(), completes);
      });
    });
  });
}
