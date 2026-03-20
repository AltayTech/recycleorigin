import 'dart:io';

import 'package:flutter/material.dart';
import 'package:recycleorigin/features/customer_feature/business/entities/country.dart';
import 'package:recycleorigin/features/customer_feature/business/entities/city.dart';
import 'package:recycleorigin/features/customer_feature/business/entities/province.dart';
import 'package:recycleorigin/core/models/search_detail.dart';
import 'package:recycleorigin/core/models/status.dart';
import 'package:recycleorigin/core/models/transaction.dart';
import 'package:recycleorigin/features/customer_feature/business/entities/transaction_main.dart';

import '../../../../core/models/customer.dart';
import '../../../../core/models/order.dart';
import '../../../store_feature/business/entities/order_details.dart';
import '../../business/entities/personal_data.dart';
import '../../../store_feature/business/entities/shop.dart';
import '../../../../core/constants/urls.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';

class CustomerInfoProvider with ChangeNotifier {
  final ApiClient _apiClient;

  CustomerInfoProvider(this._apiClient);
  String _payUrl = '';

  late int _currentOrderId;

  late Shop _shop = Shop();

  String get payUrl => _payUrl;
  List<File> chequeImageList = [];

  static Customer _customer_zero = Customer(
    personalData: PersonalData(
      first_name: '',
      last_name: '',
      email: '',
      ostan: '',
      city: '',
//      address: '',
      postcode: '',
      phone: '',
    ),
    money: '0',
  );
  Customer _customer = _customer_zero;

  Customer get customer => _customer;

  List<Order> _orders = [];

  late OrderDetails _order;

  List<Order> get orders => _orders;

  Future<void> getCustomer() async {
    AppLogger.debug('Fetching customer data');

    final path = 'pasmands/v1${Urls.customerEndPoint}';
    AppLogger.debug('Customer path: $path');

    final result = await _apiClient.get<Map<String, dynamic>>(
      path,
      parser: (data) => data as Map<String, dynamic>,
    );

    result.onSuccess((extractedData) {
      AppLogger.debug('Customer data received');

      Customer customers = Customer.fromJson(extractedData);
      _customer = customers;
      notifyListeners();
    }).onFailure((error) {
      AppLogger.error('Failed to get customer data: $error');
      throw Exception(error);
    });
  }

  Future<void> sendCustomer(Customer customer) async {
    AppLogger.debug('Sending customer data');

    final path = 'pasmands/v1${Urls.customerEndPoint}';

    final result = await _apiClient.post<Map<String, dynamic>>(
      path,
      data: {
        'customer_type': customer.customer_type.term_id,
        'customer_data': customer.personalData.toJson(),
      },
      parser: (data) => data as Map<String, dynamic>,
    );

    result.onSuccess((_) {
      AppLogger.debug('Customer data sent successfully');
      notifyListeners();
    }).onFailure((error) {
      AppLogger.error('Failed to send customer data: $error');
      throw Exception(error);
    });
  }

  Order findById(int id) {
    return _orders.firstWhere((prod) => prod.id == id);
  }

  OrderDetails getOrder() {
    return _order;
  }

  Future<void> getOrderDetails(int orderId) async {
    AppLogger.debug('Getting order details for order ID: $orderId');

    _currentOrderId = orderId;

    final path = 'pasmands/v1${Urls.orderInfoEndPoint}?order_id=$orderId';

    final result = await _apiClient.get<Map<String, dynamic>>(
      path,
      parser: (data) => data as Map<String, dynamic>,
    );

    result.onSuccess((extractedData) {
      OrderDetails orderDetails = OrderDetails.fromJson(extractedData);
      _order = orderDetails;
      AppLogger.debug('Order details retrieved successfully');
      notifyListeners();
    }).onFailure((error) {
      AppLogger.error('Failed to get order details: $error');
      throw Exception(error);
    });
  }

  Future<void> payCashOrder(int orderId) async {
    AppLogger.debug('Processing cash payment for order ID: $orderId');

    final path = 'pasmands/v1${Urls.payEndPoint}?order_id=$orderId';

    final result = await _apiClient.get<dynamic>(
      path,
      parser: (data) => data,
    );

    result.onSuccess((extractedData) {
      // Handle both string and object responses
      if (extractedData is String) {
        _payUrl = extractedData;
      } else if (extractedData is Map && extractedData.containsKey('url')) {
        _payUrl = extractedData['url'] as String;
      } else {
        _payUrl = extractedData.toString();
      }
      AppLogger.debug('Payment URL generated successfully');
      notifyListeners();
    }).onFailure((error) {
      AppLogger.error('Failed to process cash payment: $error');
      throw Exception(error);
    });
  }

  Future<void> sendNaghdOrder() async {
    AppLogger.debug('Sending naghd order');

    final path = 'pasmands/v1${Urls.orderInfoEndPoint}?paytype=naghd';

    final result = await _apiClient.post<Map<String, dynamic>>(
      path,
      parser: (data) => data as Map<String, dynamic>,
    );

    result.onSuccess((extractedData) {
      AppLogger.debug('Naghd order sent successfully');
      int orderId = extractedData['order_id'] as int;
      _currentOrderId = orderId;
      notifyListeners();
    }).onFailure((error) {
      AppLogger.error('Failed to send naghd order: $error');
      throw Exception(error);
    });
  }

  Future<void> fetchShopData() async {
    AppLogger.debug('Fetching shop data');

    final path = 'pasmands/v1${Urls.shopEndPoint}';
    AppLogger.debug('Shop path: $path');

    final result = await _apiClient.get<Map<String, dynamic>>(
      path,
      parser: (data) => data as Map<String, dynamic>,
    );

    result.onSuccess((extractedData) {
      AppLogger.debug('Shop data received');
      Shop shopData = Shop.fromJson(extractedData);
      _shop = shopData;
      notifyListeners();
    }).onFailure((error) {
      AppLogger.error('Failed to fetch shop data: $error');
      throw Exception(error);
    });
  }

  int get currentOrderId => _currentOrderId;

  set customer(Customer value) {
    _customer = value;
  }

  set order(OrderDetails value) {
    _order = value;
  }

  Customer get customer_zero => _customer_zero;

  Shop get shop => _shop;

  String searchEndPoint = '';
  String searchKey = '';
  var _sPage = 1;
  var _sPerPage = 10;
  var _sOrder = 'desc';
  var _sOrderBy = 'date';

  List<Transaction> _transactionItems = [];

  late SearchDetail _searchDetails;
  late Transaction _transactionItem;

  void searchBuilder() {
    if (!(searchKey == '')) {
      searchEndPoint = '';

      searchEndPoint = searchEndPoint + '?search=$searchKey';
      searchEndPoint = searchEndPoint + '&page=$_sPage&per_page=$_sPerPage';
    } else {
      searchEndPoint = '';

      searchEndPoint = searchEndPoint + '?page=$_sPage&per_page=$_sPerPage';
    }
    if (!(_sOrder == '')) {
      searchEndPoint = searchEndPoint + '&order=$_sOrder';
    }
    if (!(_sOrderBy == '')) {
      searchEndPoint = searchEndPoint + '&orderby=$_sOrderBy';
    }

    AppLogger.debug('Search endpoint: $searchEndPoint');
  }

  Future<void> searchTransactionItems() async {
    AppLogger.debug('Searching transaction items');

    final path = 'pasmands/v1${Urls.transactionsEndPoint}$searchEndPoint';
    AppLogger.debug('Transaction search path: $path');

    final result = await _apiClient.get<Map<String, dynamic>>(
      path,
      parser: (data) => data as Map<String, dynamic>,
    );

    result.onSuccess((extractedData) {
      AppLogger.debug('Transaction items retrieved');
      TransactionMain transactionMain = TransactionMain.fromJson(extractedData);
      AppLogger.debug('Max page: ${transactionMain.searchDetail.max_page}');
      _transactionItems = transactionMain.transactions;
      _searchDetails = transactionMain.searchDetail;
      notifyListeners();
    }).onFailure((error) {
      AppLogger.error('Failed to search transaction items: $error');
      _transactionItems = [];
      notifyListeners();
    });
  }

  Future<void> retrieveItem(int collectId) async {
    AppLogger.debug('Retrieving item for collect ID: $collectId');

    final path = 'pasmands/v1${Urls.collectsEndPoint}/$collectId';
    AppLogger.debug('Retrieve item path: $path');

    final result = await _apiClient.get<Map<String, dynamic>>(
      path,
      parser: (data) => data as Map<String, dynamic>,
    );

    result.onSuccess((extractedData) {
      AppLogger.debug('Item data retrieved');
      Transaction transaction = Transaction.fromJson(extractedData);
      _transactionItem = transaction;
      notifyListeners();
    }).onFailure((error) {
      AppLogger.error('Failed to retrieve item: $error');
      throw Exception(error);
    });
  }

  Transaction get transactionItem => _transactionItem;

  SearchDetail get searchDetails => _searchDetails;

  List<Transaction> get transactionItems => _transactionItems;

  get sOrderBy => _sOrderBy;

  get sOrder => _sOrder;

  get sPerPage => _sPerPage;

  get sPage => _sPage;

  OrderDetails get order => _order;

  set sOrderBy(value) {
    _sOrderBy = value;
  }

  set sOrder(value) {
    _sOrder = value;
  }

  set sPerPage(value) {
    _sPerPage = value;
  }

  set sPage(value) {
    _sPage = value;
  }

  Future<void> getProvinces() async {
    AppLogger.debug('Fetching provinces');

    final path = 'pasmands/v1${Urls.provincesEndPoint}';
    AppLogger.debug('Provinces path: $path');

    final result = await _apiClient.get<List<dynamic>>(
      path,
      parser: (data) => data as List<dynamic>,
    );

    result.onSuccess((extractedData) {
      AppLogger.debug('Loaded ${extractedData.length} provinces');
      List<Province> provinces =
          extractedData.map((i) => Province.fromJson(i)).toList();
      _provincesItems = provinces;
      notifyListeners();
    }).onFailure((error) {
      AppLogger.error('Failed to get provinces: $error');
      _provincesItems = [];
      notifyListeners();
    });
  }

  List<Province> _provincesItems = [];

  List<Province> get provincesItems => _provincesItems;

  Future<void> getCountries() async {
    AppLogger.debug('Fetching countries');

    final path = 'pasmands/v1${Urls.countriesEndPoint}';

    final result = await _apiClient.get<List<dynamic>>(
      path,
      parser: (data) => data as List<dynamic>,
    );

    result.onSuccess((extractedData) {
      AppLogger.debug('Loaded ${extractedData.length} countries');
      final countries = extractedData.map((i) => Country.fromJson(i)).toList();
      _countriesItems = countries;
      notifyListeners();
    }).onFailure((error) {
      AppLogger.error('Failed to get countries: $error');
      _countriesItems = [];
      notifyListeners();
    });
  }

  List<Country> _countriesItems = [];

  List<Country> get countriesItems => _countriesItems;

  Future<void> getProvincesByCountry(int countryId) async {
    AppLogger.debug('Fetching provinces for country ID: $countryId');

    final path = 'pasmands/v1${Urls.provincesEndPoint}';

    final result = await _apiClient.get<List<dynamic>>(
      path,
      queryParameters: <String, dynamic>{'country_id': countryId},
      parser: (data) => data as List<dynamic>,
    );

    result.onSuccess((extractedData) {
      AppLogger.debug('Loaded ${extractedData.length} provinces');
      final provinces = extractedData.map((i) => Province.fromJson(i)).toList();
      _provincesItems = provinces;
      notifyListeners();
    }).onFailure((error) {
      AppLogger.error('Failed to get provinces: $error');
      _provincesItems = [];
      notifyListeners();
    });
  }

  Future<void> getCities(int provinceId) async {
    AppLogger.debug('Fetching cities for province ID: $provinceId');

    final path = 'pasmands/v1${Urls.provincesEndPoint}/$provinceId';
    AppLogger.debug('Cities path: $path');

    final result = await _apiClient.get<List<dynamic>>(
      path,
      parser: (data) => data as List<dynamic>,
    );

    result.onSuccess((extractedData) {
      AppLogger.debug('Loaded ${extractedData.length} cities');
      List<City> cities = extractedData.map((i) => City.fromJson(i)).toList();
      _citiesItems = cities;
      notifyListeners();
    }).onFailure((error) {
      AppLogger.error('Failed to get cities: $error');
      _citiesItems = [];
      notifyListeners();
    });
  }

  List<City> _citiesItems = [];

  List<City> get citiesItems => _citiesItems;

  Future<void> getTypes() async {
    AppLogger.debug('Fetching types');

    final path = 'pasmands/v1${Urls.typesEndPoint}';
    AppLogger.debug('Types path: $path');

    final result = await _apiClient.get<List<dynamic>>(
      path,
      parser: (data) => data as List<dynamic>,
    );

    result.onSuccess((extractedData) {
      AppLogger.debug('Loaded ${extractedData.length} types');
      List<Status> types =
          extractedData.map((i) => Status.fromJson(i)).toList();
      _typesItems = types;
      notifyListeners();
    }).onFailure((error) {
      AppLogger.error('Failed to get types: $error');
      _typesItems = [];
      notifyListeners();
    });
  }

  List<Status> _typesItems = [];

  List<Status> get typesItems => _typesItems;

  Future<void> sendClearingRequest(String money, String shaba) async {
    AppLogger.debug('Sending clearing request');

    final path = 'pasmands/v1${Urls.clearingEndPoint}';
    AppLogger.debug('Clearing request path: $path');

    final result = await _apiClient.post<Map<String, dynamic>>(
      path,
      data: {"money": money, 'shaba': shaba},
      parser: (data) => data as Map<String, dynamic>,
    );

    result.onSuccess((_) {
      AppLogger.debug('Clearing request sent successfully');
      notifyListeners();
    }).onFailure((error) {
      AppLogger.error('Failed to send clearing request: $error');
      throw Exception(error);
    });
  }
}
