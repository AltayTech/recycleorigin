/// Thrown when production configuration is invalid or missing.
class AppConfigException implements Exception {
  AppConfigException(this.message);

  final String message;

  @override
  String toString() => 'AppConfigException: $message';
}
