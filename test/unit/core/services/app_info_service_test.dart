import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigin/core/utils/app_info_service.dart';

void main() {
  group('AppInfoService', () {
    tearDown(() {
      // Reset singleton state if needed
      // Note: AppInfoService is a singleton, so we test its behavior
    });

    group('Initialization', () {
      test('should be a singleton', () {
        final instance1 = AppInfoService.instance;
        final instance2 = AppInfoService.instance;
        expect(identical(instance1, instance2), isTrue);
      });

      test('should have default values before initialization', () {
        final service = AppInfoService.instance;
        expect(service.packageName, 'recycleorigin');
        expect(service.appName, 'RecycleOrigin');
        expect(service.version, '1.0.0');
        expect(service.buildNumber, '0');
      });
    });

    group('Version formatting', () {
      test('should format full version correctly', () {
        final service = AppInfoService.instance;
        // Before initialization, uses defaults
        expect(service.fullVersion, 'v1.0.0 (0)');
      });

      test('should format version with build correctly', () {
        final service = AppInfoService.instance;
        expect(service.versionWithBuild, '1.0.0+0');
      });
    });

    group('Build information', () {
      test('should have default build signature', () {
        final service = AppInfoService.instance;
        expect(service.buildSignature, '');
      });

      test('should have default installer store', () {
        final service = AppInfoService.instance;
        expect(service.installerStore, '');
      });
    });

    group('Edge cases', () {
      test('should handle missing package info gracefully', () {
        final service = AppInfoService.instance;
        // Should not throw even if not initialized
        expect(service.packageName, isNotEmpty);
        expect(service.appName, isNotEmpty);
        expect(service.version, isNotEmpty);
        expect(service.buildNumber, isNotEmpty);
      });
    });
  });
}

/// Note: Full integration tests would require:
/// 1. Mocking PackageInfo to test actual initialization
/// 2. Testing initialize() method with real PackageInfo
/// 3. Testing error handling during initialization
/// 4. Testing concurrent access (singleton thread safety)

