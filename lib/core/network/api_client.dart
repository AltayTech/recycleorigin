import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:recycleorigin/core/config/app_config.dart';
import 'package:recycleorigin/core/constants/urls.dart';
import 'package:recycleorigin/core/storage/secure_storage.dart';
import 'package:recycleorigin/core/utils/logger.dart';
import 'package:recycleorigin/core/utils/result.dart';

/// Centralized HTTP client for all backend communication.
///
/// `ApiClient` wraps Dio with:
/// - shared base options and timeouts,
/// - automatic bearer-token injection from secure storage,
/// - transparent access-token rotation: when the backend returns 401 the
///   client posts the stored refresh token to `/auth/refresh` once, persists
///   the new pair, and replays the original request,
/// - request/response/error logging, and
/// - unified mapping of transport failures into `Result<T>`.
///
/// Concurrent 401s are coalesced behind a single in-flight refresh future:
/// only one refresh call is made even if many requests fail at the same
/// time. A failed refresh wipes the credentials and notifies listeners via
/// [onUnauthorized] so the UI can route to the login screen.
class ApiClient {
  ApiClient({this.onUnauthorized}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _setupInterceptors();
  }

  late final Dio _dio;

  /// Callback invoked when the refresh path fails and the user needs to
  /// re-authenticate. The Bloc layer should clear its state and route to the
  /// login screen.
  final VoidCallback? onUnauthorized;

  Future<void>? _refreshFuture;

  /// Direct access to the underlying Dio instance for advanced cases that
  /// need custom request building (multipart, response streams, etc.).
  Dio get raw => _dio;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_isAuthExempt(options.path)) {
            handler.next(options);
            return;
          }
          final token = await SecureStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          AppLogger.networkRequest(
            options.method,
            '${options.baseUrl}${options.path}',
            headers: options.headers,
            body: options.data,
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.networkResponse(
            '${response.requestOptions.baseUrl}${response.requestOptions.path}',
            response.statusCode ?? 0,
          );
          handler.next(response);
        },
        onError: (error, handler) async {
          if (await _shouldAttemptRefresh(error)) {
            try {
              await _ensureRefreshed();
              final retry = await _retryRequest(error.requestOptions);
              handler.resolve(retry);
              return;
            } catch (refreshError, stackTrace) {
              AppLogger.warning(
                'Token refresh failed: $refreshError',
                refreshError,
                stackTrace,
              );
              await _clearSessionAndNotify();
              handler.next(error);
              return;
            }
          }
          AppLogger.error(
            'Network error: ${error.message}',
            error: error,
            stackTrace: error.stackTrace,
          );
          handler.next(error);
        },
      ),
    );
  }

  bool _isAuthExempt(String path) {
    return path.contains(Urls.loginEndPoint) ||
        path.contains(Urls.registerEndPoint) ||
        path.contains(Urls.firebaseExchangeEndPoint) ||
        path.contains(Urls.refreshTokenEndPoint);
  }

  Future<bool> _shouldAttemptRefresh(DioException error) async {
    if (error.response?.statusCode != 401) {
      return false;
    }
    final path = error.requestOptions.path;
    if (path.contains(Urls.refreshTokenEndPoint) ||
        path.contains(Urls.firebaseExchangeEndPoint) ||
        path.contains(Urls.loginEndPoint) ||
        path.contains(Urls.registerEndPoint)) {
      return false;
    }
    final refresh = await SecureStorage.getRefreshToken();
    return refresh != null && refresh.isNotEmpty;
  }

  Future<void> _ensureRefreshed() {
    final inflight = _refreshFuture;
    if (inflight != null) {
      return inflight;
    }
    final future = _refreshTokens()..whenComplete(() => _refreshFuture = null);
    _refreshFuture = future;
    return future;
  }

  Future<void> _refreshTokens() async {
    final refresh = await SecureStorage.getRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      throw StateError('no refresh token');
    }
    final response = await _dio.post<Map<String, dynamic>>(
      Urls.refreshTokenEndPoint,
      data: {'refresh_token': refresh},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    final data = response.data;
    if (data == null) {
      throw StateError('refresh response empty');
    }
    final newAccess = (data['access_token'] ?? data['token']) as String? ?? '';
    final newRefresh = data['refresh_token'] as String? ?? '';
    if (newAccess.isEmpty || newRefresh.isEmpty) {
      throw StateError('refresh response missing tokens');
    }
    await SecureStorage.saveAccessToken(newAccess);
    await SecureStorage.saveRefreshToken(newRefresh);
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions options) async {
    final newAccess = await SecureStorage.getAccessToken();
    final headers = Map<String, dynamic>.from(options.headers)
      ..['Authorization'] = 'Bearer ${newAccess ?? ''}';
    return _dio.fetch<dynamic>(options.copyWith(headers: headers));
  }

  Future<void> _clearSessionAndNotify() async {
    await SecureStorage.deleteToken();
    await SecureStorage.saveLoginStatus(false);
    onUnauthorized?.call();
  }

  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      if (response.statusCode == 200) {
        final data =
            parser != null ? parser(response.data) : response.data as T;
        return Success(data);
      }
      return Failure('Request failed with status ${response.statusCode}');
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in GET request',
          error: e, stackTrace: stackTrace);
      return Failure('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final result =
            parser != null ? parser(response.data) : response.data as T;
        return Success(result);
      }
      return Failure('Request failed with status ${response.statusCode}');
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in POST request',
          error: e, stackTrace: stackTrace);
      return Failure('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<Result<T>> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      if (response.statusCode == 200 || response.statusCode == 204) {
        final result =
            parser != null ? parser(response.data) : response.data as T;
        return Success(result);
      }
      return Failure('Request failed with status ${response.statusCode}');
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in PUT request',
          error: e, stackTrace: stackTrace);
      return Failure('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<Result<void>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Success(null);
      }
      return Failure('Request failed with status ${response.statusCode}');
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in DELETE request',
          error: e, stackTrace: stackTrace);
      return Failure('An unexpected error occurred: ${e.toString()}');
    }
  }

  Result<T> _handleDioError<T>(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const Failure(
            'Connection timeout. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return const Failure('Authentication failed. Please login again.');
        } else if (statusCode == 403) {
          return const Failure('Access forbidden.');
        } else if (statusCode == 404) {
          return const Failure('Resource not found.');
        } else if (statusCode != null && statusCode >= 500) {
          return const Failure('Server error. Please try again later.');
        }
        return Failure('Request failed with status $statusCode');
      case DioExceptionType.cancel:
        return const Failure('Request was cancelled.');
      case DioExceptionType.unknown:
        if (error.error?.toString().contains('SocketException') == true) {
          return const Failure(
              'No internet connection. Please check your network.');
        }
        return Failure('Network error: ${error.message}');
      default:
        return Failure('An error occurred: ${error.message}');
    }
  }
}
