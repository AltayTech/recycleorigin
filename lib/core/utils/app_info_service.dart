import 'package:package_info_plus/package_info_plus.dart';

/// Production-grade service for managing application information.
///
/// This service provides a centralized way to access app version information
/// dynamically from the package metadata. It uses a singleton pattern to ensure
/// efficient resource usage and consistent access across the application.
///
/// Features:
/// - Lazy initialization with caching
/// - Error handling with fallback values
/// - Thread-safe singleton pattern
/// - Production-ready error recovery
///
/// Usage:
/// ```dart
/// final appInfo = AppInfoService.instance;
/// await appInfo.initialize();
/// final version = appInfo.version; // "1.3.1"
/// final buildNumber = appInfo.buildNumber; // "12"
/// final fullVersion = appInfo.fullVersion; // "v1.3.1 (12)"
/// ```
class AppInfoService {
  // Private constructor for singleton pattern
  AppInfoService._();

  /// Singleton instance of AppInfoService
  static final AppInfoService instance = AppInfoService._();

  PackageInfo? _packageInfo;
  bool _isInitialized = false;
  bool _isInitializing = false;

  /// Package name (e.g., "com.example.app")
  String get packageName => _packageInfo?.packageName ?? 'recycleorigin';

  /// App name (e.g., "Recycle Origin")
  String get appName => _packageInfo?.appName ?? 'Recycle Origin';

  /// Version string (e.g., "1.3.1")
  String get version => _packageInfo?.version ?? '1.0.0';

  /// Build number as string (e.g., "12")
  String get buildNumber => _packageInfo?.buildNumber ?? '0';

  /// Build signature (Android only)
  String get buildSignature => _packageInfo?.buildSignature ?? '';

  /// Installer store (Android only)
  String get installerStore => _packageInfo?.installerStore ?? '';

  /// Full version string formatted as "v{version} ({buildNumber})"
  /// Example: "v1.3.1 (12)"
  String get fullVersion => 'v$version ($buildNumber)';

  /// Short version string formatted as "v{version}"
  /// Example: "v1.3.1"
  String get shortVersion => 'v$version';

  /// Version with build number formatted as "{version}+{buildNumber}"
  /// Example: "1.3.1+12"
  String get versionWithBuild => '$version+$buildNumber';

  /// Check if the service has been initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the service and load package information.
  ///
  /// This method should be called once during app startup, preferably
  /// in the main() function or app initialization.
  ///
  /// Returns `true` if initialization was successful, `false` otherwise.
  ///
  /// Throws [Exception] if initialization fails and no fallback is available.
  Future<bool> initialize() async {
    // Prevent multiple simultaneous initializations
    if (_isInitialized) {
      return true;
    }

    if (_isInitializing) {
      // Wait for ongoing initialization to complete
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _isInitialized;
    }

    _isInitializing = true;

    try {
      _packageInfo = await PackageInfo.fromPlatform();
      _isInitialized = true;
      return true;
    } catch (e) {
      // Log error in production (you might want to use a logging service)
      // For now, we'll use fallback values defined in getters
      _isInitialized = false;
      return false;
    } finally {
      _isInitializing = false;
    }
  }

  /// Force re-initialization of the service.
  ///
  /// This is useful for testing or when package info might have changed.
  Future<bool> reinitialize() async {
    _isInitialized = false;
    _packageInfo = null;
    return await initialize();
  }

  /// Get formatted version string with custom format.
  ///
  /// [format] can contain placeholders:
  /// - {version} - version number
  /// - {build} - build number
  /// - {name} - app name
  ///
  /// Example: formatVersion('Version {version} (Build {build})')
  /// Returns: "Version 1.3.1 (Build 12)"
  String formatVersion(String format) {
    return format
        .replaceAll('{version}', version)
        .replaceAll('{build}', buildNumber)
        .replaceAll('{name}', appName);
  }
}
