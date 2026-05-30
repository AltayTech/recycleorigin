import 'package:recycleorigin/core/network/api_client.dart';
import 'package:recycleorigin/core/storage/secure_storage.dart';
import 'package:recycleorigin/core/utils/result.dart';
import 'package:recycleorigin/features/auth_feature/data/models/TokenResponseModel.dart';

/// Remote data source for authentication operations
///
/// Handles all network calls related to authentication
abstract class AuthRemoteDataSource {
  Future<Result<TokenResponseModel>> login(String email, String password);
  Future<Result<bool>> register(
      String email, String password, String firstName, String lastName);
  Future<Result<bool>> checkCompleted();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Result<TokenResponseModel>> login(
      String email, String password) async {
    // Input validation
    if (email.isEmpty || password.isEmpty) {
      return const Failure('Email and password are required');
    }

    final result = await _apiClient.post<Map<String, dynamic>>(
      'jwt-auth/v1/token',
      queryParameters: {
        'username': email,
        'password': password,
      },
      parser: (data) => data as Map<String, dynamic>,
    );

    if (result.isFailure) {
      return Failure(result.errorOrNull ?? 'Login failed');
    }

    try {
      final data = result.valueOrNull!;
      final tokenModel = TokenResponseModel.fromJson(data);

      // Store token securely using SecureStorage
      final token = tokenModel.token;
      if (token != null && token.isNotEmpty) {
        await SecureStorage.saveToken(token);
        await SecureStorage.saveUserData(tokenModel.toJson().toString());
        await SecureStorage.saveLoginStatus(true);
      }

      return Success(tokenModel);
    } catch (e) {
      return Failure('Failed to parse token response: $e');
    }
  }

  @override
  Future<Result<bool>> register(
      String email, String password, String firstName, String lastName) async {
    // Input validation
    if (email.isEmpty ||
        password.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty) {
      return const Failure('All fields are required');
    }

    if (!_isValidEmail(email)) {
      return const Failure('Invalid email format');
    }

    if (password.length < 6) {
      return const Failure('Password must be at least 6 characters');
    }

    final result = await _apiClient.post<Map<String, dynamic>>(
      'recycleorigin/v1/auth/register',
      data: {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
      },
      parser: (data) => data as Map<String, dynamic>,
    );

    return result.map((_) => true);
  }

  @override
  Future<Result<bool>> checkCompleted() async {
    final token = await SecureStorage.getToken();
    if (token == null || token.isEmpty) {
      return const Failure('Not authenticated');
    }

    final result = await _apiClient.get<Map<String, dynamic>>(
      'recycleorigin/v1/customer/completed',
      parser: (data) => data as Map<String, dynamic>,
    );

    return result.map((data) {
      return data['complete'] as bool? ?? false;
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
