import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:recycleorigin/core/network/api_client.dart';
import 'package:recycleorigin/core/storage/secure_storage.dart';
import 'package:recycleorigin/core/utils/logger.dart';
import 'package:recycleorigin/features/customer_feature/data/models/TokenResponseModel.dart';

import '../../../../core/constants/urls.dart';
import '../../../../core/models/region.dart';
import '../../../waste_feature/business/entities/address.dart';
import '../../../waste_feature/business/entities/address_main.dart';

class AuthenticationProvider with ChangeNotifier {
  final ApiClient _apiClient;

  AuthenticationProvider(this._apiClient);

  String _token = '';
  TokenResponseModel tokenResponseModel = TokenResponseModel();
  late bool _isLoggedin;

  bool _isFirstLogin = false;
  bool _isFirstLogout = false;

  List<Address> _addressItems = [];

  Address _selectedAddress = Address(region: Region());

  List<Region> _regionItems = [];

  late Region _regionData;

  bool _isCompleted = false;

  bool get isLoggedin => _isLoggedin;

  bool get isFirstLogout => _isFirstLogout;

  set isFirstLogout(bool value) {
    _isFirstLogout = value;
  }

  set isLoggedin(bool value) {
    _isLoggedin = value;
  }

  bool get isAuth {
    getTokenFromDB();
    return _token != '';
  }

  String get token => _token;
  Map<String, String> headers = {};

  /// Login with email and password
  ///
  /// Returns true if login is successful, false otherwise.
  /// Throws an exception if an unexpected error occurs.
  Future<bool> _login(String email, String password) async {
    // SECURITY: Never log passwords or sensitive data
    // Using logger utility which automatically sanitizes sensitive information

    final data = {
      'username': email,
      'password': password,
    };

    try {
      // Use ApiClient for secure, logged requests
      final result = await _apiClient.post<Map<String, dynamic>>(
        Urls.loginEndPoint,
        queryParameters: data,
        parser: (data) => data as Map<String, dynamic>,
      );

      if (result.isSuccess) {
        final responseData = result.valueOrNull!;

        try {
          _token = responseData['token'] as String? ?? '';
          _isFirstLogin = true;

          // Store token securely
          final userData = jsonEncode({
            'token': _token,
          });
          tokenResponseModel = TokenResponseModel.fromJson(responseData);

          await SecureStorage.saveUserData(userData);
          await SecureStorage.saveToken(_token);
          await SecureStorage.saveLoginStatus(true);
          _isLoggedin = _token.isNotEmpty;
          notifyListeners();
          return true;
        } catch (error, stackTrace) {
          _isLoggedin = false;
          _token = '';
          await SecureStorage.saveToken('');
          await SecureStorage.saveLoginStatus(false);
          AppLogger.error('Failed to process login response',
              error: error, stackTrace: stackTrace);
          tokenResponseModel = TokenResponseModel(
            token: "",
            userDisplayName: '',
            userEmail: '',
            userNicename: '',
          );
          notifyListeners();
          return false;
        }
      } else {
        _isLoggedin = false;
        _token = '';
        AppLogger.warning('Login failed: ${result.errorOrNull}');
        tokenResponseModel = TokenResponseModel(
          token: "",
          userDisplayName: '',
          userEmail: '',
          userNicename: '',
        );
        notifyListeners();
        return false;
      }
    } catch (error, stackTrace) {
      _isLoggedin = false;
      _token = '';
      AppLogger.error('Login error', error: error, stackTrace: stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// Register a new user with email and password
  ///
  /// Returns true if registration is successful, false otherwise.
  /// Throws an exception if an unexpected error occurs.
  Future<bool> _register(
      String email, String password, String firstName, String lastName) async {
    final data = {
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

      if (result.isSuccess) {
        _isLoggedin = true;
        notifyListeners();
        return true;
      } else {
        _isLoggedin = false;
        AppLogger.warning('Registration failed: ${result.errorOrNull}');
        notifyListeners();
        return false;
      }
    } catch (error, stackTrace) {
      _isLoggedin = false;
      AppLogger.error('Registration error',
          error: error, stackTrace: stackTrace);
      notifyListeners();
      return false;
    }
  }

  void updateCookie(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers['cookie'] =
          (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }

  Future<Future<bool>> login(Map<String, String> authData) async {
    return _login(authData['email']!, authData['password']!);
  }

  Future<bool> register(Map<String, String> authData) async {
    return _register(authData['email']!, authData['password']!,
        authData['first_name']!, authData['last_name']!);
  }

  Future<void> getTokenFromDB() async {
    try {
      _token = await SecureStorage.getToken() ?? "";
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get token from secure storage',
          error: e, stackTrace: stackTrace);
      _token = "";
      notifyListeners();
    }
  }

  // //////////////////////////////////////////////////////////////////////////

  /// //////////////////////////////////////////////////////////////////////////
  ///  sing up or login with email and password
  Future<bool> emailAuth(String email, String password) async {
    AppLogger.debug('Starting email authentication');

    final url = Urls.rootUrl + Urls.loginEndPoint + email;
    AppLogger.debug('Authentication URL: $url');

    try {
      final response = await http.post(Uri.parse(url), headers: headers);
      updateCookie(response);

      final responseData = json.decode(response.body);
      AppLogger.debug('Authentication response received');

      if (responseData != 'false') {
        try {
          _token = responseData['token'];
          _isFirstLogin = true;

          // Store token securely - NEVER log the token
          await SecureStorage.saveToken(_token);
          final userData = json.encode(
            {
              'token': _token,
            },
          );
          await SecureStorage.saveUserData(userData);
          await SecureStorage.saveLoginStatus(true);
          AppLogger.info('User authenticated successfully');
          _isLoggedin = true;
        } catch (error, stackTrace) {
          _isLoggedin = false;
          _token = '';
          await SecureStorage.saveToken('');
          await SecureStorage.saveLoginStatus(false);
          AppLogger.error('Failed to process authentication response',
              error: error, stackTrace: stackTrace);
        }
      } else {
        _isLoggedin = false;
        _token = '';
        await SecureStorage.saveToken('');
        await SecureStorage.saveLoginStatus(false);
        AppLogger.warning('Authentication failed: invalid response');
      }
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Authentication error',
          error: error, stackTrace: stackTrace);
      throw error;
    }
    return _isLoggedin;
  }

  Future<void> checkCompleted() async {
    try {
      if (isAuth) {
        _token = await SecureStorage.getToken() ?? '';

        final url = Urls.rootUrl + Urls.checkCompletedEndPoint;

        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $_token',
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
        );

        final extractedData = json.decode(response.body) as dynamic;

        AppLogger.debug('Check completed response received');
        bool isCompleted = extractedData['complete'];

        _isCompleted = isCompleted;
      } else {
        _isCompleted = false;
      }
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to check completion status',
          error: error, stackTrace: stackTrace);
      throw (error);
    }

    notifyListeners();
  }

  Future<void> removeToken() async {
    try {
      await SecureStorage.deleteToken();
      await SecureStorage.saveLoginStatus(false);
      _token = '';
      AppLogger.debug('Token removed successfully');
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to remove token',
          error: e, stackTrace: stackTrace);
      _token = '';
      notifyListeners();
    }
  }

  bool get isCompleted => _isCompleted;

  bool get isFirstLogin => _isFirstLogin;

  set isFirstLogin(bool value) {
    _isFirstLogin = value;
  }

  Future<void> getAddresses() async {
    AppLogger.debug('Fetching addresses');
    try {
      if (isAuth) {
        _token = await SecureStorage.getToken() ?? '';

        final url = Urls.rootUrl + Urls.addressEndPoint;

        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $_token',
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
        );

        final extractedData = json.decode(response.body);

        AppLogger.debug('Addresses response received');
        AddressMain addressMain = AddressMain.fromJson(extractedData);

        List<Address> addresseList = addressMain.addressData;
        AppLogger.debug('Loaded ${addresseList.length} addresses');

        _addressItems = addresseList;
      } else {
        _addressItems = [];
      }
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to get addresses',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }

  Future<void> updateAddress(List<Address> addressList) async {
    AppLogger.debug('Updating addresses');
    try {
      if (isAuth) {
        _token = await SecureStorage.getToken() ?? '';

        final url = Urls.rootUrl + Urls.addressEndPoint;
        AppLogger.debug('Update address URL: $url');

        final response = await http.post(Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            },
            body: jsonEncode(AddressMain(
              addressData: addressList,
            ).toJson()));

        if (response.statusCode < 200 || response.statusCode >= 300) {
          final body = json.decode(response.body);
          final message = body is Map && body['error'] != null
              ? body['error'].toString()
              : 'Failed to save address (${response.statusCode})';
          throw Exception(message);
        }

        final extractedData = json.decode(response.body) as Map<String, dynamic>;
        AddressMain addressMain = AddressMain.fromJson(extractedData);
        AppLogger.debug('Address update response received');

        List<Address> addresses = addressMain.addressData;
        AppLogger.debug('Updated ${addresses.length} addresses');

        _addressItems = addresses;
      } else {
        AppLogger.debug('User not authenticated, using local address list');
        _addressItems = addressList;
      }
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to update addresses',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }

  List<Address> get addressItems => _addressItems;

  Future<void> getOrder(List<Address> addressList) async {
    AppLogger.debug('Getting order');
    try {
      if (isAuth) {
        _token = await SecureStorage.getToken() ?? '';

        final url = Urls.rootUrl + Urls.addressEndPoint;
        await http.post(Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            },
            body: json.encode(AddressMain(
              addressData: addressList,
            )));

        AppLogger.debug('Order response received');

        _addressItems = addressList;
      } else {
        _addressItems = addressList;
      }
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to get order',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }

  Future<void> selectAddress(Address address) async {
    AppLogger.debug('Selecting address');
    try {
      _selectedAddress = address;
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to select address',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }

  Address get selectedAddress => _selectedAddress;

  Future<void> retrieveRegionList() async {
    AppLogger.debug('Retrieving region list');

    final url = Urls.rootUrl + Urls.regionEndPoint;

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      });

      final extractedData = json.decode(response.body) as List;
      AppLogger.debug('Region list response received');

      List<Region> regionList = [];

      regionList = extractedData.map((i) => Region.fromJson(i)).toList();
      AppLogger.debug('Loaded ${regionList.length} regions');

      _regionItems = regionList;

      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to retrieve region list',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }

  List<Region> get regionItems => _regionItems;

  Future<void> retrieveRegion(int regionId) async {
    AppLogger.debug('Retrieving region: $regionId');

    final url = Urls.rootUrl + Urls.regionEndPoint + '/$regionId';
    AppLogger.debug('Region URL: $url');

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      });

      final extractedData = json.decode(response.body);
      AppLogger.debug('Region response received');

      _regionData = Region.fromJson(extractedData);

      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to retrieve region',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }

  Region get regionData => _regionData;
}
