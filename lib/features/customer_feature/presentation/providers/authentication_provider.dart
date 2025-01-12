import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/models/region.dart';
import '../../../waste_feature/business/entities/address.dart';
import '../../../waste_feature/business/entities/address_main.dart';
import '../../../../core/constants/urls.dart';

class AuthenticationProvider with ChangeNotifier {
  final Dio _dio = Dio();

  String _token = '';
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

  /// ////////////////////////////////////////////////////////////////////////////
  /// login or sign up with phone number
  Future<bool> _login(String email, String password) async {
    debugPrint('_login');
    final url = Urls.baseUrl + Urls.loginEndPoint;
    _dio.options = BaseOptions(
      baseUrl: url,
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 5),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    final data = {
      'email': email,
      'password': password,
    };
    debugPrint(url);

    try {
      Response response = await _dio.post(
        '/login', // Replace with your login endpoint
        data: data,
      );

      // final response = await http.post(Uri.parse(url), headers: headers);
      // updateCookie(response);

      final responseData = json.decode(response.data);
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

  /// ////////////////////////////////////////////////////////////////////////////
  ///  sign up with email and password
  Future<bool> _register(
      String email, String password, String firstName, String lastName) async {
    debugPrint('_register');
    final url = Urls.baseUrl + Urls.loginEndPoint;
    _dio.options = BaseOptions(
      baseUrl: url,
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 5),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    final data = {
      'email': email,
      'password': password,
    };
    debugPrint(url);

    try {
      Response response = await _dio.post(
        '/login', // Replace with your login endpoint
        data: data,
      );

      // final response = await http.post(Uri.parse(url), headers: headers);
      // updateCookie(response);

      final responseData = json.decode(response.data);
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
      debugPrint(extractedData);

      _regionData = Region.fromJson(extractedData);

      notifyListeners();
    } catch (error) {
      debugPrint(error.toString());
      throw (error);
    }
  }

  Region get regionData => _regionData;
}
