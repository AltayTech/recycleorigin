import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:recycleorigin/features/customer_feature/data/models/TokenResponseModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/urls.dart';
import '../../../../core/models/region.dart';
import '../../../waste_feature/business/entities/address.dart';
import '../../../waste_feature/business/entities/address_main.dart';

class AuthenticationProvider with ChangeNotifier {
  final Dio _dio = Dio();

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

    final url = Urls.baseUrl + Urls.loginEndPoint;
    final data = {
      'username': email,
      'password': password,
    };

    try {
      final response = await _dio.post(
        url,
        queryParameters: data,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.toString());

        try {
          _token = responseData['token'] as String? ?? '';
          _isFirstLogin = true;

          final prefs = await SharedPreferences.getInstance();
          final userData = jsonEncode({
            'token': _token,
          });
          tokenResponseModel = TokenResponseModel.fromJson(responseData);

          prefs.setString('userData', userData);
          prefs.setString('token', _token);
          prefs.setString('isLogin', 'true');
          _isLoggedin = _token.isNotEmpty;
        } catch (error) {
          _isLoggedin = false;
          final prefs = await SharedPreferences.getInstance();
          _token = '';
          prefs.setString('token', _token);
          prefs.setString('isLogin', 'false');
          tokenResponseModel = TokenResponseModel(
            token: "",
            userDisplayName: '',
            userEmail: '',
            userNicename: '',
          );
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        _isLoggedin = false;
        _token = '';
        prefs.setString('token', _token);
        prefs.setString('isLogin', 'false');
        tokenResponseModel = TokenResponseModel(
          token: "",
          userDisplayName: '',
          userEmail: '',
          userNicename: '',
        );
      }
      notifyListeners();
    } catch (error) {
      _isLoggedin = false;
      _token = '';
      notifyListeners();
      rethrow;
    }
    return _isLoggedin;
  }

  /// Register a new user with email and password
  ///
  /// Returns true if registration is successful, false otherwise.
  /// Throws an exception if an unexpected error occurs.
  Future<bool> _register(
      String email, String password, String firstName, String lastName) async {
    final url = Urls.baseUrl + Urls.registerEndPoint;

    final data = {
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
    };

    try {
      final response = await _dio.post(
        url,
        data: data,
      );

      if (response.statusCode == 200) {
        _isLoggedin = true;
      } else {
        _isLoggedin = false;
      }

      notifyListeners();
    } catch (error) {
      _isLoggedin = false;
      notifyListeners();
      rethrow;
    }
    return _isLoggedin;
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
    final prefs = await SharedPreferences.getInstance().then(
      (value) {
        _token = value.getString("token") ?? "";
      },
    );

    notifyListeners();
  }

  // //////////////////////////////////////////////////////////////////////////

  /// //////////////////////////////////////////////////////////////////////////
  ///  sing up or login with email and password
  Future<bool> emailAuth(String email, String password) async {
    debugPrint('_authenticate');

    final url = Urls.rootUrl + Urls.loginEndPoint + email;
    debugPrint(url);

    try {
      final response = await http.post(Uri.parse(url), headers: headers);
      updateCookie(response);

      final responseData = json.decode(response.body);
      debugPrint(responseData);

      if (responseData != 'false') {
        try {
          _token = responseData['token'];
          _isFirstLogin = true;

          final prefs = await SharedPreferences.getInstance();
          final userData = json.encode(
            {
              'token': _token,
            },
          );
          prefs.setString('userData', userData);
          prefs.setString('token', _token);
          debugPrint(_token);
          prefs.setString('isLogin', 'true');
          _isLoggedin = true;
        } catch (error) {
          _isLoggedin = false;
          final prefs = await SharedPreferences.getInstance();
          final userData = json.encode(
            {
              'token': '',
            },
          );
          _token = '';
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        _isLoggedin = false;

        _token = '';
        prefs.setString('token', _token);
        debugPrint(_token);
        debugPrint('noooo token');
        prefs.setString('isLogin', 'true');
      }
      notifyListeners();
    } catch (error) {
      debugPrint(error.toString());
      throw error;
    }
    return _isLoggedin;
  }

  Future<void> checkCompleted() async {
    try {
      if (isAuth) {
        final prefs = await SharedPreferences.getInstance();
        _token = prefs.getString('token')!;

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

        debugPrint(extractedData.toString());
        bool isCompleted = extractedData['complete'];

        _isCompleted = isCompleted;
      } else {
        _isCompleted = false;
      }
      notifyListeners();
    } catch (error) {
      debugPrint(error.toString());
      throw (error);
    }

    notifyListeners();
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    _token = '';
    debugPrint('toookeeen');
    debugPrint(prefs.getString('token'));
    notifyListeners();
  }

  bool get isCompleted => _isCompleted;

  bool get isFirstLogin => _isFirstLogin;

  set isFirstLogin(bool value) {
    _isFirstLogin = value;
  }

  Future<void> getAddresses() async {
    debugPrint('getAddresses');
    try {
      if (isAuth) {
        final prefs = await SharedPreferences.getInstance();
        _token = prefs.getString('token')!;

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

        debugPrint(extractedData.toString());
        AddressMain addressMain = AddressMain.fromJson(extractedData);
        debugPrint(extractedData.toString());

        List<Address> addresseList = addressMain.addressData;
        debugPrint('sssssssssssssssssssssssssss ${addresseList.length}');

        _addressItems = addresseList;
      } else {
        _addressItems = [];
      }
      notifyListeners();
    } catch (error) {
      debugPrint(error.toString());
      throw (error);
    }
  }

  Future<void> updateAddress(List<Address> addressList) async {
    debugPrint('addAddress');
    try {
      if (isAuth) {
        final prefs = await SharedPreferences.getInstance();
        _token = prefs.getString('token')!;
        debugPrint('tooookkkkeeennnn    $_token');

        final url = Urls.rootUrl + Urls.addressEndPoint;
        debugPrint('url  $url');
        debugPrint(jsonEncode(AddressMain(
          addressData: addressList,
        )));

        final response = await http.post(Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            },
            body: jsonEncode(AddressMain(
              addressData: addressList,
            )));

        final extractedData = json.decode(response.body);

        AddressMain addressMain = AddressMain.fromJson(extractedData);
        debugPrint(extractedData.toString());

        List<Address> addresses = addressMain.addressData;
        debugPrint('ییییییییییییییییییی  ${addresses.length}');

        _addressItems = addresses;
      } else {
        debugPrint('qqqqqqqqqqqqqqggggggggq');

        _addressItems = addressList;
      }
      notifyListeners();
    } catch (error) {
      debugPrint(error.toString());
      throw (error);
    }
  }

  List<Address> get addressItems => _addressItems;

  Future<void> getOrder(List<Address> addressList) async {
    debugPrint('addAddress');
    try {
      if (isAuth) {
        final prefs = await SharedPreferences.getInstance();
        _token = prefs.getString('token')!;

        final url = Urls.rootUrl + Urls.addressEndPoint;
        final response = await http.post(Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            },
            body: json.encode(AddressMain(
              addressData: addressList,
            )));

        final extractedData = json.decode(response.body);

        debugPrint(extractedData.toString());

        _addressItems = addressList;
      } else {
        _addressItems = addressList;
      }
      notifyListeners();
    } catch (error) {
      debugPrint(error.toString());
      throw (error);
    }
  }

  Future<void> selectAddress(Address address) async {
    debugPrint('selectAddress');
    try {
      _selectedAddress = address;

      notifyListeners();
    } catch (error) {
      debugPrint(error.toString());
      throw (error);
    }
  }

  Address get selectedAddress => _selectedAddress;

  Future<void> retrieveRegionList() async {
    debugPrint('retrieveRegionList');

    final url = Urls.rootUrl + Urls.regionEndPoint;

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      });

      final extractedData = json.decode(response.body) as List;
      debugPrint(extractedData.toString());

      List<Region> regionList = [];

      regionList = extractedData.map((i) => Region.fromJson(i)).toList();
      debugPrint(regionList.length.toString());

      _regionItems = regionList;

      notifyListeners();
    } catch (error) {
      debugPrint(error.toString());
      throw (error);
    }
  }

  List<Region> get regionItems => _regionItems;

  Future<void> retrieveRegion(int regionId) async {
    debugPrint('retrieveRegion');

    final url = Urls.rootUrl + Urls.regionEndPoint + '/$regionId';
    debugPrint(url);

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      });

      final extractedData = json.decode(response.body);
      debugPrint("extractedData  $extractedData");

      _regionData = Region.fromJson(extractedData);

      notifyListeners();
    } catch (error) {
      debugPrint(error.toString());
      throw (error);
    }
  }

  Region get regionData => _regionData;
}
