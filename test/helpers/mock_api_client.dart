import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:recycleorigin/core/network/api_client.dart';
import 'package:recycleorigin/core/utils/result.dart';

/// Mock ApiClient for testing
///
/// Allows tests to control API responses without making actual network calls.
/// This is a wrapper that can be used in place of ApiClient for testing.
class MockApiClient implements ApiClient {
  @override
  VoidCallback? get onUnauthorized => null;

  @override
  Dio get raw =>
      throw UnimplementedError('raw is not available on MockApiClient');

  // Store responses for different paths
  final Map<String, Result<dynamic>> _getResponses = {};
  final Map<String, Result<dynamic>> _postResponses = {};
  final Map<String, Result<dynamic>> _putResponses = {};
  final Map<String, Result<void>> _deleteResponses = {};

  /// Set a mock GET response for a specific path
  void setGetResponse(String path, Result<dynamic> response) {
    _getResponses[path] = response;
  }

  /// Set a mock POST response for a specific path
  void setPostResponse(String path, Result<dynamic> response) {
    _postResponses[path] = response;
  }

  /// Set a mock PUT response for a specific path
  void setPutResponse(String path, Result<dynamic> response) {
    _putResponses[path] = response;
  }

  /// Set a mock DELETE response for a specific path
  void setDeleteResponse(String path, Result<void> response) {
    _deleteResponses[path] = response;
  }

  /// Clear all mock responses
  void clearResponses() {
    _getResponses.clear();
    _postResponses.clear();
    _putResponses.clear();
    _deleteResponses.clear();
  }

  @override
  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
  }) async {
    // Check if we have a mock response for this path
    final normalizedPath = _normalizePath(path, queryParameters);
    if (_getResponses.containsKey(normalizedPath)) {
      final response = _getResponses[normalizedPath]!;
      if (response.isSuccess && parser != null) {
        return Success(parser(response.valueOrNull!));
      }
      return response as Result<T>;
    }

    // Default: return failure if no mock is set
    return Failure('No mock response set for path: $path');
  }

  @override
  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
  }) async {
    final normalizedPath = _normalizePath(path, queryParameters);
    if (_postResponses.containsKey(normalizedPath)) {
      final response = _postResponses[normalizedPath]!;
      if (response.isSuccess && parser != null) {
        return Success(parser(response.valueOrNull!));
      }
      return response as Result<T>;
    }

    return Failure('No mock response set for path: $path');
  }

  @override
  Future<Result<T>> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? parser,
  }) async {
    if (_putResponses.containsKey(path)) {
      final response = _putResponses[path]!;
      if (response.isSuccess && parser != null) {
        return Success(parser(response.valueOrNull!));
      }
      return response as Result<T>;
    }

    return Failure('No mock response set for path: $path');
  }

  @override
  Future<Result<void>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    if (_deleteResponses.containsKey(path)) {
      return _deleteResponses[path]!;
    }

    return Failure('No mock response set for path: $path');
  }

  /// Normalize path with query parameters for consistent matching
  String _normalizePath(String path, Map<String, dynamic>? queryParameters) {
    if (queryParameters == null || queryParameters.isEmpty) {
      return path;
    }
    final sortedParams = Map.fromEntries(
      queryParameters.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    final queryString =
        sortedParams.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$path?$queryString';
  }
}
