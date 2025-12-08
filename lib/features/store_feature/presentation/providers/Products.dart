import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/models/category.dart';
import '../../business/entities/color_code_card.dart';
import '../../business/entities/color_code_product_detail.dart';
import '../../business/entities/order_send_details.dart';
import '../../business/entities/product.dart';
import '../../business/entities/product_cart.dart';
import '../../business/entities/product_main.dart';
import '../../../../core/models/search_detail.dart';
import '../../../../core/constants/urls.dart';
import '../../../../core/utils/logger.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  List<ProductCart> _cartItems = [];
  List<Category> _categoryItems = [];
  List<String> filterTitle = [];

  String searchEndPoint = '';

  String searchKey = '';
  var _sPage = 1;
  var _sPerPage = 10;
  var _sOrder = 'desc';
  var _sOrderBy = 'date';

  var _sCategory;

  set cartItems(List<ProductCart> value) {
    _cartItems = value;
  }

  bool _isFiltered = false;

  SearchDetail _searchDetails = SearchDetail(max_page: 1, total: 10);

  Future<void> checkFiltered() async {
    if (_sCategory == '') {
      _isFiltered = false;
    } else {
      _isFiltered = true;
    }
  }

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

  static Product _itemZero = Product();
  Product _item = _itemZero;

  late String _token;

  List<Product> get items {
    return _items;
  }

  int get cartItemsCount {
    return _cartItems.length;
  }

  Product get item {
    return _item;
  }

  List<ProductCart> get cartItems {
    return _cartItems;
  }

  get sCategory => _sCategory;

  set sCategory(value) {
    _sCategory = value;
  }

  Future<void> addShopCart(
    Product product,
    ColorCodeProductDetail colorId,
    int quantity,
  ) async {
    AppLogger.debug('Adding product to cart: ${product.id}');
    try {
      _cartItems.add(ProductCart(
          id: product.id,
          title: product.name,
          price: product.price,
          featured_media_url: product.featured_image.sizes.medium,
          productCount: quantity));
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to add product to cart',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }

  Future<void> updateShopCart(ProductCart product, ColorCodeCard colorId,
      int quantity, bool isLogin) async {
    AppLogger.debug('Updating cart item: ${product.id}');
    try {
      _cartItems.firstWhere((prod) => prod.id == product.id).productCount =
          quantity;
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to update cart item',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }

  Future<void> removeShopCart(int productId) async {
    AppLogger.debug('Removing product from cart: $productId');

    try {
      _cartItems.remove(_cartItems.firstWhere((prod) => prod.id == productId));
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to remove product from cart',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }

  Product findById() {
    return _item;
  }

  Future<void> retrieveCategory() async {
    AppLogger.debug('Fetching categories');

    final url = Urls.rootUrl + Urls.categoriesEndPoint;
    AppLogger.debug('Categories URL: $url');

    try {
      final response = await get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      });

      final extractedData = json.decode(response.body) as List<dynamic>;
      AppLogger.debug('Loaded ${extractedData.length} categories');

      List<Category> categories =
          extractedData.map((i) => Category.fromJson(i)).toList();

      _categoryItems = categories;
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to retrieve categories',
          error: error, stackTrace: stackTrace);
    }
  }

  Future<void> searchItem() async {
    AppLogger.debug('Searching products');

    final url = Urls.rootUrl + Urls.productsEndPoint + '$searchEndPoint';
    AppLogger.debug('Products search URL: $url');

    try {
      final response = await get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      });
      AppLogger.debug('Products search response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body);
        AppLogger.debug('Products retrieved');

        ProductMain productMain = ProductMain.fromJson(extractedData);
        AppLogger.debug('Max page: ${productMain.productsDetail.max_page}');

        _items = productMain.products;
        _searchDetails = productMain.productsDetail;
      } else {
        _items = [];
      }
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to search products',
          error: error, stackTrace: stackTrace);
      // throw (error);
    }
  }

  Future<void> retrieveItem(int productId) async {
    AppLogger.debug('Retrieving product: $productId');

    final url = Urls.rootUrl + Urls.productsEndPoint + "/$productId";
    AppLogger.debug('Product URL: $url');

    try {
      final response = await get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      });
      final extractedData = json.decode(response.body) as dynamic;
      AppLogger.debug('Product data retrieved');

      Product product = Product.fromJson(extractedData);
      AppLogger.debug('Product ID: ${product.id}');

      _item = product;
    } catch (error, stackTrace) {
      AppLogger.error('Failed to retrieve product',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
    notifyListeners();
  }

  set sPerPage(value) {
    _sPerPage = value;
  }

  set sOrder(value) {
    _sOrder = value;
  }

  set sOrderBy(value) {
    _sOrderBy = value;
  }

  set sPage(value) {
    _sPage = value;
  }

  bool get isFiltered => _isFiltered;

  SearchDetail get searchDetails => _searchDetails;

  set item(Product value) {
    _item = value;
  }

  Product get itemZero => _itemZero;

  List<Category> get categoryItems => _categoryItems;

  Future<void> sendRequest(
    OrderSendDetails request,
  ) async {
    AppLogger.debug('Sending order request');
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token')!;

      final url = Urls.rootUrl + Urls.orderEndPoint;
      AppLogger.debug('Order URL: $url');

      final response = await post(Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $_token',
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode(request));

      json.decode(response.body); // Validate response
      AppLogger.debug('Order request sent successfully');

      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to send order request',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }
}
