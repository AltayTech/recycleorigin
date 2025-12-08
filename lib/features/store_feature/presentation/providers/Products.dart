import 'package:flutter/material.dart';

import '../../../../core/models/category.dart';
import '../../business/entities/color_code_card.dart';
import '../../business/entities/color_code_product_detail.dart';
import '../../business/entities/order_send_details.dart';
import '../../business/entities/product.dart';
import '../../business/entities/product_cart.dart';
import '../../business/entities/product_main.dart';
import '../../../../core/models/search_detail.dart';
import '../../../../core/constants/urls.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';

class Products with ChangeNotifier {
  final ApiClient _apiClient;

  Products(this._apiClient);
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

    final path = 'pasmands/v1${Urls.categoriesEndPoint}';
    AppLogger.debug('Categories path: $path');

    final result = await _apiClient.get<List<dynamic>>(
      path,
      parser: (data) => data as List<dynamic>,
    );

    result.onSuccess((extractedData) {
      AppLogger.debug('Loaded ${extractedData.length} categories');

      List<Category> categories =
          extractedData.map((i) => Category.fromJson(i)).toList();

      _categoryItems = categories;
      notifyListeners();
    }).onFailure((error) {
      AppLogger.error('Failed to retrieve categories: $error');
    });
  }

  Future<void> searchItem() async {
    AppLogger.debug('Searching products');

    final path = 'pasmands/v1${Urls.productsEndPoint}$searchEndPoint';
    AppLogger.debug('Products search path: $path');

    final result = await _apiClient.get<Map<String, dynamic>>(
      path,
      parser: (data) => data as Map<String, dynamic>,
    );

    result.onSuccess((extractedData) {
      AppLogger.debug('Products retrieved');

      ProductMain productMain = ProductMain.fromJson(extractedData);
      AppLogger.debug('Max page: ${productMain.productsDetail.max_page}');

      _items = productMain.products;
      _searchDetails = productMain.productsDetail;
      notifyListeners();
    }).onFailure((error) {
      AppLogger.error('Failed to search products: $error');
      _items = [];
      notifyListeners();
    });
  }

  Future<void> retrieveItem(int productId) async {
    AppLogger.debug('Retrieving product: $productId');

    final path = 'pasmands/v1${Urls.productsEndPoint}/$productId';
    AppLogger.debug('Product path: $path');

    final result = await _apiClient.get<Map<String, dynamic>>(
      path,
      parser: (data) => data as Map<String, dynamic>,
    );

    result.onSuccess((extractedData) {
      AppLogger.debug('Product data retrieved');

      Product product = Product.fromJson(extractedData);
      AppLogger.debug('Product ID: ${product.id}');

      _item = product;
      notifyListeners();
    }).onFailure((error) {
      AppLogger.error('Failed to retrieve product: $error');
      throw Exception(error);
    });
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

    final path = 'pasmands/v1${Urls.orderEndPoint}';
    AppLogger.debug('Order path: $path');

    final result = await _apiClient.post<Map<String, dynamic>>(
      path,
      data: request.toJson(),
      parser: (data) => data as Map<String, dynamic>,
    );

    result.onSuccess((_) {
      AppLogger.debug('Order request sent successfully');
      notifyListeners();
    }).onFailure((error) {
      AppLogger.error('Failed to send order request: $error');
      throw Exception(error);
    });
  }
}
