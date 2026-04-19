import 'package:dio/dio.dart';
import 'package:recycleorigin/core/config/app_config.dart';
import 'package:recycleorigin/core/storage/secure_storage.dart';
import 'package:recycleorigin/core/utils/logger.dart';
import 'package:recycleorigin/core/utils/result.dart';

/// Centralized HTTP client for all backend communication.
///
/// `ApiClient` wraps Dio with:
/// - shared base options and timeouts,
/// - automatic bearer token injection from secure storage,
/// - request/response/error logging, and
/// - unified mapping of transport failures into `Result<T>`.
class ApiClient {
  late final Dio _dio;

  /// Creates a configured Dio client for app API calls.
  ApiClient() {
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

  /// Registers request, response, and error interceptors.
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available (from secure storage)
          final token = await SecureStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Log request (sanitized)
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
        onError: (error, handler) {
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

  /// Perform a GET request
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
      } else {
        return Failure('Request failed with status ${response.statusCode}');
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in GET request',
          error: e, stackTrace: stackTrace);
      return Failure('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Perform a POST request
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
      } else {
        return Failure('Request failed with status ${response.statusCode}');
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in POST request',
          error: e, stackTrace: stackTrace);
      return Failure('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Perform a PUT request
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
      } else {
        return Failure('Request failed with status ${response.statusCode}');
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in PUT request',
          error: e, stackTrace: stackTrace);
      return Failure('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Perform a DELETE request
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
      } else {
        return Failure('Request failed with status ${response.statusCode}');
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in DELETE request',
          error: e, stackTrace: stackTrace);
      return Failure('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Converts low-level Dio exceptions into user-facing failure messages.
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
