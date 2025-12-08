import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recycleorigin/core/models/order.dart';
import 'package:recycleorigin/features/store_feature/business/entities/order_main.dart';
import 'package:recycleorigin/core/models/search_detail.dart';

import '../../../../core/constants/urls.dart';
import '../../../../core/utils/logger.dart';

class Orders with ChangeNotifier {
  late String _token;

  String searchEndPoint = '';
  String searchKey = '';
  var _sPage = 1;
  var _sPerPage = 10;
  var _sOrder = 'desc';
  var _sOrderBy = 'date';

  List<Order> _ordersItems = [];

  late SearchDetail _searchDetails;
  late Order _orderItem;

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

  Future<void> searchOrderItems() async {
    AppLogger.debug('Searching order items');

    final url = Urls.rootUrl + Urls.orderEndPoint + '$searchEndPoint';
    AppLogger.debug('Order search URL: $url');
    final prefs = await SharedPreferences.getInstance();

    _token = prefs.getString('token')!;

    try {
      final response = await get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      });
      AppLogger.debug('Order search response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body);
        AppLogger.debug('Order items retrieved');

        OrdersMain ordersMain = OrdersMain.fromJson(extractedData);
        AppLogger.debug('Max page: ${ordersMain.searchDetail.max_page}');

        _ordersItems = ordersMain.transactions;
        _searchDetails = ordersMain.searchDetail;
      } else {
        _ordersItems = [];
      }
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to search order items',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }

  Future<void> retrieveOrderItem(int ordrId) async {
    AppLogger.debug('Retrieving order item: $ordrId');

    final url = Urls.rootUrl + Urls.orderEndPoint + "/$ordrId";
    AppLogger.debug('Order item URL: $url');

    try {
      final response = await get(url as Uri, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      });
      final extractedData = json.decode(response.body) as dynamic;
      AppLogger.debug('Order item data retrieved');

      Order order = Order.fromJson(extractedData);

      _orderItem = order;
    } catch (error, stackTrace) {
      AppLogger.error('Failed to retrieve order item',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
    notifyListeners();
  }

  SearchDetail get searchDetails => _searchDetails;

  List<Order> get ordersItems => _ordersItems;

  get sOrderBy => _sOrderBy;

  get sOrder => _sOrder;

  get sPerPage => _sPerPage;

  get sPage => _sPage;

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

  Order get orderItem => _orderItem;
}
