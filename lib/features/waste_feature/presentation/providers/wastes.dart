import 'dart:convert';

import 'package:dio/dio.dart' as diolib;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/collect_main.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/request_waste.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/request_waste_item.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/waste.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/wasteCart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/urls.dart';
import '../../../../core/models/search_detail.dart';
import '../../../../core/utils/logger.dart';

class Wastes with ChangeNotifier {
  List<Waste> _wasteItems = [];
  List<WasteCart> _wasteCartItems = [];
  List<int> _wasteCartItemsId = [];
  late String _token;

  List<RequestWasteItem> _collectItems = [];

  SearchDetail _searchDetails = SearchDetail();

  late RequestWasteItem _requestWasteItem;

  Future<void> searchWastesItem() async {
    AppLogger.debug('Searching waste items');

    final url = Urls.rootUrl + Urls.pasmandsEndPoint;
    AppLogger.debug('Waste search URL: $url');

    try {
      final response = await get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      });
      AppLogger.debug('Waste search response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body) as List<dynamic>;
        AppLogger.debug('Loaded ${extractedData.length} waste items');

        List<Waste> wastes =
            extractedData.map((i) => Waste.fromJson(i)).toList();

        _wasteItems = wastes;
      } else {
        _wasteItems = [];
      }
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to search waste items',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }

  Future<void> addWasteCart(Waste waste, int weight) async {
    AppLogger.debug('Adding waste to cart: ${waste.id}');
    try {
      _wasteCartItems.add(WasteCart(
          id: waste.id,
          name: waste.name,
          excerpt: waste.excerpt,
          prices: waste.prices,
          featured_image: waste.featured_image,
          status: waste.status,
          weight: weight));
      _wasteCartItemsId.add(waste.id);
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to add waste to cart',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }

  Future<void> updateWasteCart(WasteCart waste, int quantity) async {
    AppLogger.debug('Updating waste cart item: ${waste.id}');
    try {
      _wasteCartItems.firstWhere((prod) => prod.id == waste.id).weight =
          quantity;
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to update waste cart',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }

  Future<void> removeWasteCart(int wasteId) async {
    AppLogger.debug('Removing waste from cart: $wasteId');

    _wasteCartItems
        .remove(_wasteCartItems.firstWhere((prod) => prod.id == wasteId));
    _wasteCartItemsId
        .remove(_wasteCartItemsId.firstWhere((prod) => prod == wasteId));

    notifyListeners();
  }

  String get token => _token;

  List<WasteCart> get wasteCartItems => _wasteCartItems;

  List<Waste> get wasteItems => _wasteItems;

  List<int> get wasteCartItemsId => _wasteCartItemsId;

  Future<void> sendRequest(RequestWaste request, bool isLogin) async {
    AppLogger.debug('Sending waste request');
    try {
      if (isLogin) {
        final prefs = await SharedPreferences.getInstance();
        _token = prefs.getString('token')!;

        final url = Urls.rootUrl + Urls.collectsEndPoint;
        AppLogger.debug('Waste request URL: $url');

        final response = await post(Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            },
            body: jsonEncode(request));

        final extractedData = json.decode(response.body);
        AppLogger.debug('Waste request sent successfully');
      }
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to send waste request',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }

  late String _selectedHours;
  late DateTime _selectedDay;

  String get selectedHours => _selectedHours;

  set selectedHours(String value) {
    _selectedHours = value;
  }

  DateTime get selectedDay => _selectedDay;

  set selectedDay(DateTime value) {
    _selectedDay = value;
  }

  String searchEndPoint = '';
  String searchKey = '';
  var _sPage = 1;
  var _sPerPage = 10;
  var _sOrder = 'desc';
  var _sOrderBy = 'date';
  var _sCategory;

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

    if (!(_sCategory == '' || _sCategory == null)) {
      searchEndPoint = searchEndPoint + '&category=$_sCategory';
    }
    AppLogger.debug('Search endpoint: $searchEndPoint');
  }

  Future<void> searchCollectItems() async {
    AppLogger.debug('Searching collect items');

    final url = Urls.rootUrl + Urls.collectsEndPoint + '$searchEndPoint';
    AppLogger.debug('Collect search URL: $url');

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token')!;

      final response = await get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      });
      AppLogger.debug('Collect search response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body);
        AppLogger.debug('Collect items retrieved');

        CollectMain collectMain = CollectMain.fromJson(extractedData);
        AppLogger.debug('Max page: ${collectMain.searchDetail.max_page}');

        _collectItems = collectMain.requestWasteItem;
        AppLogger.debug('Loaded ${_collectItems.length} collect items');
        _searchDetails = collectMain.searchDetail;
      } else {
        _collectItems = [];
      }
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to search collect items',
          error: error, stackTrace: stackTrace);
      // throw (error);
    }
  }

  Future<void> retrieveCollectItem(int collectId) async {
    AppLogger.debug('Retrieving collect item: $collectId');

    final url = Urls.rootUrl + Urls.collectsEndPoint + "/$collectId";
    AppLogger.debug('Collect item URL: $url');

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token')!;

      final _dio = diolib.Dio();
      diolib.Response response = await _dio.get(
        url,
        options: diolib.Options(
          headers: {
            'Authorization': 'Bearer $_token',
            // 'Content-Type': 'application/json',
            // 'Accept': 'application/json'
          },
        ),
      );

      AppLogger.debug('Collect item response status: ${response.statusCode}');
      AppLogger.debug('Collect item data retrieved');

      RequestWasteItem requestWasteItem =
          RequestWasteItem.fromJson(response.data);
      AppLogger.debug('Collect item ID: ${requestWasteItem.id}');

      _requestWasteItem = requestWasteItem;
    } catch (error, stackTrace) {
      AppLogger.error('Failed to retrieve collect item',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
    notifyListeners();
  }

  // Future<void> retrieveCollectItem(int collectId) async {
  //   debugPrint('retrieveCollectItem');
  //
  //   final url = Urls.rootUrl + Urls.collectsEndPoint + "/$collectId";
  //   debugPrint(url);
  //   Dio
  //
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     _token = prefs.getString('token')!;
  //     debugPrint('tooookkkeeennnnnn  $_token');
  //
  //     Response response = await get(Uri.parse(url), headers: {
  //       'Authorization': 'Bearer $_token',
  //       // 'Content-Type': 'application/json',
  //       // 'Accept': 'application/json'
  //     });
  //     debugPrint(
  //         "response.statusCode.toString() ${response.statusCode}");
  //     debugPrint(
  //         "response.toString() ${response.body.toString()}",wrapWidth: 1024);
  //     // final extractedDatajson = jsonEncode(response.bodyBytes);
  //     // debugPrint(extractedDatajson);
  //     final extractedData = jsonDecode(response.body);
  //     debugPrint(extractedData);
  //
  //     RequestWasteItem requestWasteItem =
  //         RequestWasteItem.fromJson(extractedData);
  //     debugPrint(requestWasteItem.id.toString());
  //
  //     _requestWasteItem = requestWasteItem;
  //   } catch (error) {
  //     debugPrint(error.toString());
  //     throw (error);
  //   }
  //   notifyListeners();
  // }

  get sCategory => _sCategory;

  get sOrderBy => _sOrderBy;

  get sOrder => _sOrder;

  get sPerPage => _sPerPage;

  get sPage => _sPage;

  RequestWasteItem get requestWasteItem => _requestWasteItem;

  SearchDetail get searchDetails => _searchDetails;

  List<RequestWasteItem> get CollectItems => _collectItems;

  set sCategory(value) {
    _sCategory = value;
  }

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
}
