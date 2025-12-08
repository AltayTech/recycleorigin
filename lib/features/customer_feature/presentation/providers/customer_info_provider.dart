import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import '../../../../core/utils/logger.dart';

class CustomerInfoProvider with ChangeNotifier {
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
  late String _token;

  Customer get customer => _customer;

  List<Order> _orders = [];

  late OrderDetails _order;

  List<Order> get orders => _orders;

  Future<void> getCustomer() async {
    AppLogger.debug('Fetching customer data');

    final url = Urls.rootUrl + Urls.customerEndPoint;
    AppLogger.debug('Customer URL: $url');

    final prefs = await SharedPreferences.getInstance();

    _token = prefs.getString('token')!;

    Customer customers;
    try {
      final response = await get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      });

      final extractedData = json.decode(response.body);
      AppLogger.debug('Customer data received');

      customers = Customer.fromJson(extractedData);

      _customer = customers;

      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to get customer data',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }

  Future<void> sendCustomer(Customer customer) async {
    AppLogger.debug('Sending customer data');

    final url = Urls.rootUrl + Urls.customerEndPoint;

    final prefs = await SharedPreferences.getInstance();

    _token = prefs.getString('token')!;

    try {
      final response = await post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({
          'customer_type': customer.customer_type.term_id,
          'customer_data': customer.personalData,
        }),
      );

      json.decode(response.body); // Validate response
      AppLogger.debug('Customer data sent successfully');
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to send customer data',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
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

    final url = Urls.rootUrl + Urls.orderInfoEndPoint + '?order_id=$orderId';

    final prefs = await SharedPreferences.getInstance();

    _token = prefs.getString('token')!;

    OrderDetails orderDetails;
    try {
      final response = await get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      });

      final extractedData = json.decode(response.body);

      orderDetails = OrderDetails.fromJson(extractedData);

      _order = orderDetails;
      AppLogger.debug('Order details retrieved successfully');

      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to get order details',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }

  Future<void> payCashOrder(int orderId) async {
    AppLogger.debug('Processing cash payment for order ID: $orderId');

    final url = Urls.rootUrl + Urls.payEndPoint + '?order_id=$orderId';

    final prefs = await SharedPreferences.getInstance();

    _token = prefs.getString('token')!;

    try {
      final response = await get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      });

      final extractedData = json.decode(response.body);

      _payUrl = extractedData;
      AppLogger.debug('Payment URL generated successfully');

      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to process cash payment',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }

  Future<void> sendNaghdOrder() async {
    AppLogger.debug('Sending naghd order');

    final url = Urls.rootUrl + Urls.orderInfoEndPoint + '?paytype=naghd';

    final prefs = await SharedPreferences.getInstance();

    _token = prefs.getString('token')!;

    try {
      final response = await post(Uri.parse(url), headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      });

      final extractedData = json.decode(response.body);
      AppLogger.debug('Naghd order sent successfully');

      int orderId = extractedData['order_id'];
      _currentOrderId = orderId;

      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to send naghd order',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }

  Future<void> fetchShopData() async {
    AppLogger.debug('Fetching shop data');

    final url = Urls.rootUrl + Urls.shopEndPoint;
    AppLogger.debug('Shop URL: $url');

    try {
      final response = await get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      });

      final extractedData = json.decode(response.body) as dynamic;
      AppLogger.debug('Shop data received');

      Shop shopData = Shop.fromJson(extractedData);

      _shop = shopData;
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to fetch shop data',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
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

    final url = Urls.rootUrl + Urls.transactionsEndPoint + '$searchEndPoint';
    AppLogger.debug('Transaction search URL: $url');
    final prefs = await SharedPreferences.getInstance();

    _token = prefs.getString('token')!;

    try {
      final response = await get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      });
      AppLogger.debug(
          'Transaction search response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body);
        AppLogger.debug('Transaction items retrieved');

        TransactionMain transactionMain =
            TransactionMain.fromJson(extractedData);
        AppLogger.debug('Max page: ${transactionMain.searchDetail.max_page}');

        _transactionItems = transactionMain.transactions;
        _searchDetails = transactionMain.searchDetail;
      } else {
        _transactionItems = [];
      }
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to search transaction items',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }

  Future<void> retrieveItem(int collectId) async {
    AppLogger.debug('Retrieving item for collect ID: $collectId');

    final url = Urls.rootUrl + Urls.collectsEndPoint + "/$collectId";
    AppLogger.debug('Retrieve item URL: $url');

    try {
      final response = await get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      });
      final extractedData = json.decode(response.body) as dynamic;
      AppLogger.debug('Item data retrieved');

      Transaction transaction = Transaction.fromJson(extractedData);

      _transactionItem = transaction;
    } catch (error, stackTrace) {
      AppLogger.error('Failed to retrieve item',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
    notifyListeners();
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

    final url = Urls.rootUrl + Urls.provincesEndPoint;
    AppLogger.debug('Provinces URL: $url');

    try {
      final response = await get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      });
      AppLogger.debug('Provinces response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body) as List<dynamic>;
        AppLogger.debug('Loaded ${extractedData.length} provinces');

        List<Province> wastes =
            extractedData.map((i) => Province.fromJson(i)).toList();

        _provincesItems = wastes;
      } else {
        _provincesItems = [];
      }
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to get provinces',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }

  List<Province> _provincesItems = [];

  List<Province> get provincesItems => _provincesItems;

  Future<void> getCities(int provinceId) async {
    AppLogger.debug('Fetching cities for province ID: $provinceId');

    final url = Urls.rootUrl + Urls.provincesEndPoint + '$provinceId';
    AppLogger.debug('Cities URL: $url');

    try {
      final response = await get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      });
      AppLogger.debug('Cities response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body) as List<dynamic>;
        AppLogger.debug('Loaded ${extractedData.length} cities');

        List<City> wastes = extractedData.map((i) => City.fromJson(i)).toList();

        _citiesItems = wastes;
      } else {
        _citiesItems = [];
      }
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to get cities',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }

  List<City> _citiesItems = [];

  List<City> get citiesItems => _citiesItems;

  Future<void> getTypes() async {
    AppLogger.debug('Fetching types');

    final url = Urls.rootUrl + Urls.typesEndPoint;
    AppLogger.debug('Types URL: $url');

    try {
      final response = await get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      });
      AppLogger.debug('Types response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body) as List<dynamic>;
        AppLogger.debug('Loaded ${extractedData.length} types');

        List<Status> wastes =
            extractedData.map((i) => Status.fromJson(i)).toList();

        _typesItems = wastes;
      } else {
        _typesItems = [];
      }
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to get types',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }

  List<Status> _typesItems = [];

  List<Status> get typesItems => _typesItems;

  Future<void> sendClearingRequest(String money, String shaba) async {
    AppLogger.debug('Sending clearing request');
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token')!;

      final url = Urls.rootUrl + Urls.clearingEndPoint;
      AppLogger.debug('Clearing request URL: $url');

      final response = await post(Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $_token',
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode({"money": money, 'shaba': shaba}));

      json.decode(response.body); // Validate response
      AppLogger.debug('Clearing request sent successfully');

      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to send clearing request',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }
}
