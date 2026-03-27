import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:recycleorigin/core/constants/urls.dart';
import 'package:recycleorigin/core/models/region.dart';
import 'package:recycleorigin/core/network/api_client.dart';
import 'package:recycleorigin/core/storage/secure_storage.dart';
import 'package:recycleorigin/core/utils/logger.dart';
import 'package:recycleorigin/features/auth_feature/data/models/TokenResponseModel.dart';
import 'package:recycleorigin/features/auth_feature/presentation/bloc/auth_state.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/address.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/address_main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Central auth/application-account bloc for user app.
class AuthBloc extends Cubit<AuthState> {
  AuthBloc(this._apiClient) : super(AuthState());

  final ApiClient _apiClient;
  final Map<String, String> headers = <String, String>{};

  bool get isAuth => state.isAuth;
  bool get isLoggedin => state.isLoggedIn;
  bool get isFirstLogin => state.isFirstLogin;
  bool get isFirstLogout => state.isFirstLogout;
  bool get isCompleted => state.isCompleted;
  String get token => state.token;
  List<Address> get addressItems => state.addressItems;
  Address get selectedAddress => state.selectedAddress;
  List<Region> get regionItems => state.regionItems;
  Region get regionData => state.regionData ?? Region();
  TokenResponseModel get tokenResponseModel => state.tokenResponseModel;

  set isFirstLogin(bool value) => emit(state.copyWith(isFirstLogin: value));
  set isFirstLogout(bool value) => emit(state.copyWith(isFirstLogout: value));
  set isLoggedin(bool value) => emit(state.copyWith(isLoggedIn: value));

  Future<bool> _login(String email, String password) async {
    final data = <String, String>{
      'username': email,
      'password': password,
    };

    try {
      final result = await _apiClient.post<Map<String, dynamic>>(
        Urls.loginEndPoint,
        queryParameters: data,
        parser: (data) => data as Map<String, dynamic>,
      );

      if (!result.isSuccess) {
        emit(
          state.copyWith(
            token: '',
            isLoggedIn: false,
            tokenResponseModel: TokenResponseModel(
              token: '',
              userDisplayName: '',
              userEmail: '',
              userNicename: '',
            ),
          ),
        );
        AppLogger.warning('Login failed: ${result.errorOrNull}');
        return false;
      }

      final responseData = result.valueOrNull!;
      final token = responseData['token'] as String? ?? '';
      final tokenModel = TokenResponseModel.fromJson(responseData);
      final userData = jsonEncode(<String, String>{'token': token});

      await SecureStorage.saveUserData(userData);
      await SecureStorage.saveToken(token);
      await SecureStorage.saveLoginStatus(token.isNotEmpty);

      emit(
        state.copyWith(
          token: token,
          tokenResponseModel: tokenModel,
          isLoggedIn: token.isNotEmpty,
          isFirstLogin: true,
        ),
      );
      return token.isNotEmpty;
    } catch (error, stackTrace) {
      await SecureStorage.saveToken('');
      await SecureStorage.saveLoginStatus(false);
      emit(
        state.copyWith(
          token: '',
          isLoggedIn: false,
          tokenResponseModel: TokenResponseModel(
            token: '',
            userDisplayName: '',
            userEmail: '',
            userNicename: '',
          ),
        ),
      );
      AppLogger.error('Login error', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> _register(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    final data = <String, String>{
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
    };

    try {
      final result = await _apiClient.post<Map<String, dynamic>>(
        Urls.registerEndPoint,
        data: data,
        parser: (data) => data as Map<String, dynamic>,
      );
      final success = result.isSuccess;
      emit(state.copyWith(isLoggedIn: success));
      if (!success) {
        AppLogger.warning('Registration failed: ${result.errorOrNull}');
      }
      return success;
    } catch (error, stackTrace) {
      emit(state.copyWith(isLoggedIn: false));
      AppLogger.error(
        'Registration error',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  void updateCookie(http.Response response) {
    final rawCookie = response.headers['set-cookie'];
    if (rawCookie == null) {
      return;
    }
    final index = rawCookie.indexOf(';');
    headers['cookie'] = index == -1 ? rawCookie : rawCookie.substring(0, index);
  }

  Future<Future<bool>> login(Map<String, String> authData) async {
    return _login(authData['email']!, authData['password']!);
  }

  Future<bool> register(Map<String, String> authData) {
    return _register(
      authData['email']!,
      authData['password']!,
      authData['first_name']!,
      authData['last_name']!,
    );
  }

  Future<void> getTokenFromDB() async {
    try {
      final token = await SecureStorage.getToken() ?? '';
      emit(state.copyWith(token: token));
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to get token from secure storage',
        error: error,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(token: ''));
    }
  }

  Future<void> checkCompleted() async {
    try {
      final token = await SecureStorage.getToken() ?? '';
      if (token.isEmpty) {
        emit(state.copyWith(token: '', isCompleted: false));
        return;
      }

      final response = await http.get(
        Uri.parse(Urls.rootUrl + Urls.checkCompletedEndPoint),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final extractedData = json.decode(response.body) as dynamic;
      final isCompleted = extractedData['complete'] as bool? ?? false;

      emit(state.copyWith(token: token, isCompleted: isCompleted));
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to check completion status',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> removeToken() async {
    try {
      await SecureStorage.deleteToken();
      await SecureStorage.saveLoginStatus(false);
      emit(
        state.copyWith(
          token: '',
          isLoggedIn: false,
          isCompleted: false,
          addressItems: <Address>[],
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to remove token',
        error: error,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(token: '', isLoggedIn: false));
    }
  }

  Future<void> getAddresses() async {
    try {
      final token = await SecureStorage.getToken() ?? '';
      if (token.isEmpty) {
        emit(state.copyWith(token: '', addressItems: <Address>[]));
        return;
      }

      final response = await http.get(
        Uri.parse(Urls.rootUrl + Urls.addressEndPoint),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final extractedData = json.decode(response.body);
      final addresses = AddressMain.fromJson(extractedData).addressData;
      emit(state.copyWith(token: token, addressItems: addresses));
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to get addresses',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> updateAddress(List<Address> addressList) async {
    try {
      final token = await SecureStorage.getToken() ?? '';
      if (token.isEmpty) {
        emit(state.copyWith(addressItems: addressList));
        return;
      }

      final response = await http.post(
        Uri.parse(Urls.rootUrl + Urls.addressEndPoint),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(AddressMain(addressData: addressList).toJson()),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final body = json.decode(response.body);
        final message = body is Map && body['error'] != null
            ? body['error'].toString()
            : 'Failed to save address (${response.statusCode})';
        throw Exception(message);
      }

      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final addresses = AddressMain.fromJson(extractedData).addressData;
      emit(state.copyWith(token: token, addressItems: addresses));
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to update addresses',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> getOrder(List<Address> addressList) async {
    try {
      final token = await SecureStorage.getToken() ?? '';
      if (token.isNotEmpty) {
        await http.post(
          Uri.parse(Urls.rootUrl + Urls.addressEndPoint),
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode(AddressMain(addressData: addressList)),
        );
      }
      emit(state.copyWith(token: token, addressItems: addressList));
    } catch (error, stackTrace) {
      AppLogger.error('Failed to get order',
          error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> selectAddress(Address address) async {
    emit(state.copyWith(selectedAddress: address));
  }

  Future<void> retrieveRegionList() async {
    try {
      final response = await http.get(
        Uri.parse(Urls.rootUrl + Urls.regionEndPoint),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final extractedData = json.decode(response.body) as List;
      final regionList = extractedData.map((i) => Region.fromJson(i)).toList();
      emit(state.copyWith(regionItems: regionList));
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to retrieve region list',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> retrieveRegionsByCity(int cityId) async {
    try {
      final response = await http.get(
        Uri.parse('${Urls.rootUrl}${Urls.regionEndPoint}?city_id=$cityId'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final extractedData = json.decode(response.body) as List;
      final regionList = extractedData.map((i) => Region.fromJson(i)).toList();
      emit(state.copyWith(regionItems: regionList));
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to retrieve regions by city',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> retrieveRegion(int regionId) async {
    try {
      final response = await http.get(
        Uri.parse('${Urls.rootUrl}${Urls.regionEndPoint}/$regionId'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final extractedData = json.decode(response.body);
      emit(state.copyWith(regionData: Region.fromJson(extractedData)));
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to retrieve region',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
