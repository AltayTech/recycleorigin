import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:recycleorigin/core/constants/urls.dart';
import 'package:recycleorigin/core/models/region.dart';
import 'package:recycleorigin/core/network/api_client.dart';
import 'package:recycleorigin/core/notifications/push_notification_controller.dart';
import 'package:recycleorigin/core/storage/secure_storage.dart';
import 'package:recycleorigin/core/utils/logger.dart';
import 'package:recycleorigin/features/auth_feature/data/models/TokenResponseModel.dart';
import 'package:recycleorigin/features/auth_feature/presentation/bloc/auth_event.dart';
import 'package:recycleorigin/features/auth_feature/presentation/bloc/auth_state.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/address.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/address_main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Central auth/application-account bloc for user app.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._apiClient) : super(AuthState()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthTokenLoadRequested>(_onTokenLoadRequested);
    on<AuthCompletionCheckRequested>(_onCompletionCheckRequested);
    on<AuthTokenRemoved>(_onTokenRemoved);
    on<AuthAddressesLoadRequested>(_onAddressesLoadRequested);
    on<AuthAddressUpdateRequested>(_onAddressUpdateRequested);
    on<AuthOrderRequested>(_onOrderRequested);
    on<AuthAddressSelected>(_onAddressSelected);
    on<AuthRegionsLoadRequested>(_onRegionsLoadRequested);
    on<AuthRegionsByCityLoadRequested>(_onRegionsByCityLoadRequested);
    on<AuthRegionLoadRequested>(_onRegionLoadRequested);
    on<AuthFirstLoginFlagChanged>(_onFirstLoginFlagChanged);
    on<AuthFirstLogoutFlagChanged>(_onFirstLogoutFlagChanged);
    on<AuthLoggedInFlagChanged>(_onLoggedInFlagChanged);
  }

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

  set isFirstLogin(bool value) => add(AuthFirstLoginFlagChanged(value));
  set isFirstLogout(bool value) => add(AuthFirstLogoutFlagChanged(value));
  set isLoggedin(bool value) => add(AuthLoggedInFlagChanged(value));

  Future<bool> _login(
    String email,
    String password,
    Emitter<AuthState> emitter,
  ) async {
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
        emitter(
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

      emitter(
        state.copyWith(
          token: token,
          tokenResponseModel: tokenModel,
          isLoggedIn: token.isNotEmpty,
          isFirstLogin: true,
          isFirstLogout: false,
        ),
      );
      if (token.isNotEmpty) {
        unawaited(
          PushNotificationController.instance.syncAfterLogin(_apiClient),
        );
      }
      return token.isNotEmpty;
    } catch (error, stackTrace) {
      await SecureStorage.saveToken('');
      await SecureStorage.saveLoginStatus(false);
      emitter(
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
    Emitter<AuthState> emitter,
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
      emitter(state.copyWith(isLoggedIn: success));
      if (!success) {
        AppLogger.warning('Registration failed: ${result.errorOrNull}');
      }
      return success;
    } catch (error, stackTrace) {
      emitter(state.copyWith(isLoggedIn: false));
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

  Future<bool> login(Map<String, String> authData) {
    final completer = Completer<bool>();
    add(AuthLoginRequested(authData: authData, completer: completer));
    return completer.future;
  }

  Future<bool> register(Map<String, String> authData) {
    final completer = Completer<bool>();
    add(AuthRegisterRequested(authData: authData, completer: completer));
    return completer.future;
  }

  Future<void> getTokenFromDB() async {
    final completer = Completer<void>();
    add(AuthTokenLoadRequested(completer: completer));
    return completer.future;
  }

  Future<void> checkCompleted() async {
    final completer = Completer<void>();
    add(AuthCompletionCheckRequested(completer: completer));
    return completer.future;
  }

  Future<void> removeToken() async {
    final completer = Completer<void>();
    add(AuthTokenRemoved(completer: completer));
    return completer.future;
  }

  Future<void> getAddresses() async {
    final completer = Completer<void>();
    add(AuthAddressesLoadRequested(completer: completer));
    return completer.future;
  }

  Future<void> updateAddress(List<Address> addressList) async {
    final completer = Completer<void>();
    add(AuthAddressUpdateRequested(
        addresses: addressList, completer: completer));
    return completer.future;
  }

  Future<void> getOrder(List<Address> addressList) async {
    final completer = Completer<void>();
    add(AuthOrderRequested(addresses: addressList, completer: completer));
    return completer.future;
  }

  Future<void> selectAddress(Address address) async {
    add(AuthAddressSelected(address));
  }

  Future<void> retrieveRegionList() async {
    final completer = Completer<void>();
    add(AuthRegionsLoadRequested(completer: completer));
    return completer.future;
  }

  Future<void> retrieveRegionsByCity(int cityId) async {
    final completer = Completer<void>();
    add(AuthRegionsByCityLoadRequested(cityId: cityId, completer: completer));
    return completer.future;
  }

  Future<void> retrieveRegion(int regionId) async {
    final completer = Completer<void>();
    add(AuthRegionLoadRequested(regionId: regionId, completer: completer));
    return completer.future;
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final result = await _login(
        event.authData['email']!,
        event.authData['password']!,
        emit,
      );
      event.completer.complete(result);
    } catch (error, stackTrace) {
      event.completer.completeError(error, stackTrace);
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final result = await _register(
        event.authData['email']!,
        event.authData['password']!,
        event.authData['first_name']!,
        event.authData['last_name']!,
        emit,
      );
      event.completer.complete(result);
    } catch (error, stackTrace) {
      event.completer.completeError(error, stackTrace);
    }
  }

  Future<void> _onTokenLoadRequested(
    AuthTokenLoadRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final token = await SecureStorage.getToken() ?? '';
      emit(state.copyWith(token: token));
      if (token.isNotEmpty) {
        unawaited(
          PushNotificationController.instance.syncAfterLogin(_apiClient),
        );
      }
      event.completer?.complete();
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to get token from secure storage',
        error: error,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(token: ''));
      event.completer?.completeError(error, stackTrace);
    }
  }

  Future<void> _onCompletionCheckRequested(
    AuthCompletionCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final token = await SecureStorage.getToken() ?? '';
      if (token.isEmpty) {
        emit(state.copyWith(token: '', isCompleted: false));
        event.completer?.complete();
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
      event.completer?.complete();
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to check completion status',
        error: error,
        stackTrace: stackTrace,
      );
      event.completer?.completeError(error, stackTrace);
    }
  }

  Future<void> _onTokenRemoved(
    AuthTokenRemoved event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await PushNotificationController.instance.onLogout(_apiClient);
      await SecureStorage.deleteToken();
      await SecureStorage.saveLoginStatus(false);
      emit(
        state.copyWith(
          token: '',
          isLoggedIn: false,
          isCompleted: false,
          addressItems: <Address>[],
          isFirstLogin: false,
        ),
      );
      event.completer?.complete();
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to remove token',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          token: '',
          isLoggedIn: false,
          isFirstLogin: false,
        ),
      );
      event.completer?.completeError(error, stackTrace);
    }
  }

  Future<void> _onAddressesLoadRequested(
    AuthAddressesLoadRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final token = await SecureStorage.getToken() ?? '';
      if (token.isEmpty) {
        emit(state.copyWith(token: '', addressItems: <Address>[]));
        event.completer?.complete();
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
      event.completer?.complete();
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to get addresses',
        error: error,
        stackTrace: stackTrace,
      );
      event.completer?.completeError(error, stackTrace);
    }
  }

  Future<void> _onAddressUpdateRequested(
    AuthAddressUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final token = await SecureStorage.getToken() ?? '';
      if (token.isEmpty) {
        emit(state.copyWith(addressItems: event.addresses));
        event.completer?.complete();
        return;
      }

      final response = await http.post(
        Uri.parse(Urls.rootUrl + Urls.addressEndPoint),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(AddressMain(addressData: event.addresses).toJson()),
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
      event.completer?.complete();
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to update addresses',
        error: error,
        stackTrace: stackTrace,
      );
      event.completer?.completeError(error, stackTrace);
    }
  }

  Future<void> _onOrderRequested(
    AuthOrderRequested event,
    Emitter<AuthState> emit,
  ) async {
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
          body: json.encode(AddressMain(addressData: event.addresses)),
        );
      }
      emit(state.copyWith(token: token, addressItems: event.addresses));
      event.completer?.complete();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to get order',
          error: error, stackTrace: stackTrace);
      event.completer?.completeError(error, stackTrace);
    }
  }

  void _onAddressSelected(AuthAddressSelected event, Emitter<AuthState> emit) {
    emit(state.copyWith(selectedAddress: event.address));
  }

  Future<void> _onRegionsLoadRequested(
    AuthRegionsLoadRequested event,
    Emitter<AuthState> emit,
  ) async {
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
      event.completer?.complete();
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to retrieve region list',
        error: error,
        stackTrace: stackTrace,
      );
      event.completer?.completeError(error, stackTrace);
    }
  }

  Future<void> _onRegionsByCityLoadRequested(
    AuthRegionsByCityLoadRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${Urls.rootUrl}${Urls.regionEndPoint}?city_id=${event.cityId}'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final extractedData = json.decode(response.body) as List;
      final regionList = extractedData.map((i) => Region.fromJson(i)).toList();
      emit(state.copyWith(regionItems: regionList));
      event.completer?.complete();
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to retrieve regions by city',
        error: error,
        stackTrace: stackTrace,
      );
      event.completer?.completeError(error, stackTrace);
    }
  }

  Future<void> _onRegionLoadRequested(
    AuthRegionLoadRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${Urls.rootUrl}${Urls.regionEndPoint}/${event.regionId}'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final extractedData = json.decode(response.body);
      emit(state.copyWith(regionData: Region.fromJson(extractedData)));
      event.completer?.complete();
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to retrieve region',
        error: error,
        stackTrace: stackTrace,
      );
      event.completer?.completeError(error, stackTrace);
    }
  }

  void _onFirstLoginFlagChanged(
    AuthFirstLoginFlagChanged event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(isFirstLogin: event.value));
  }

  void _onFirstLogoutFlagChanged(
    AuthFirstLogoutFlagChanged event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(isFirstLogout: event.value));
  }

  void _onLoggedInFlagChanged(
    AuthLoggedInFlagChanged event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(isLoggedIn: event.value));
  }
}
