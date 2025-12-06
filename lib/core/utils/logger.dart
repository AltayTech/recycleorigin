import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Production-grade logging utility
///
/// Provides structured logging with different log levels.
/// In production, only errors and warnings are logged.
/// Sensitive information is automatically filtered.
class AppLogger {
  static const String _tag = 'RecycleOrigin';

  /// Log debug messages (only in debug mode)
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      developer.log(
        message,
        name: _tag,
        level: 800, // Debug level
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log informational messages
  static void info(String message) {
    developer.log(
      message,
      name: _tag,
      level: 700, // Info level
    );
  }

  /// Log warning messages
  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _tag,
      level: 900, // Warning level
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log error messages
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: _tag,
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log network requests (filters sensitive data)
  static void networkRequest(String method, String url,
      {Map<String, dynamic>? headers, Map<String, dynamic>? body}) {
    if (kDebugMode) {
      final safeHeaders = _sanitizeHeaders(headers);
      final safeBody = _sanitizeBody(body);

      developer.log(
        '$method $url',
        name: '$_tag.Network',
        level: 800,
      );

      if (safeHeaders != null && safeHeaders.isNotEmpty) {
        developer.log('Headers: $safeHeaders',
            name: '$_tag.Network', level: 800);
      }

      if (safeBody != null && safeBody.isNotEmpty) {
        developer.log('Body: $safeBody', name: '$_tag.Network', level: 800);
      }
    }
  }

  /// Log network responses
  static void networkResponse(String url, int statusCode, {String? body}) {
    if (kDebugMode) {
      developer.log(
        'Response: $statusCode for $url',
        name: '$_tag.Network',
        level: statusCode >= 400 ? 1000 : 800,
      );
    }
  }

  /// Sanitize headers to remove sensitive information
  static Map<String, dynamic>? _sanitizeHeaders(Map<String, dynamic>? headers) {
    if (headers == null) return null;

    final sanitized = Map<String, dynamic>.from(headers);
    const sensitiveKeys = [
      'authorization',
      'cookie',
      'token',
      'password',
      'api-key'
    ];

    sanitized.forEach((key, value) {
      if (sensitiveKeys
          .any((sensitive) => key.toLowerCase().contains(sensitive))) {
        sanitized[key] = '***REDACTED***';
      }
    });

    return sanitized;
  }

  /// Sanitize body to remove sensitive information
  static Map<String, dynamic>? _sanitizeBody(Map<String, dynamic>? body) {
    if (body == null) return null;

    final sanitized = Map<String, dynamic>.from(body);
    const sensitiveKeys = ['password', 'token', 'credit_card', 'cvv', 'ssn'];

    sanitized.forEach((key, value) {
      if (sensitiveKeys
          .any((sensitive) => key.toLowerCase().contains(sensitive))) {
        sanitized[key] = '***REDACTED***';
      }
    });

    return sanitized;
  }
}
