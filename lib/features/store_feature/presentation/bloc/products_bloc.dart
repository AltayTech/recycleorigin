import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/core/constants/urls.dart';
import 'package:recycleorigin/core/models/category.dart';
import 'package:recycleorigin/core/models/search_detail.dart';
import 'package:recycleorigin/core/network/api_client.dart';
import 'package:recycleorigin/core/utils/logger.dart';
import 'package:recycleorigin/features/store_feature/business/entities/color_code_card.dart';
import 'package:recycleorigin/features/store_feature/business/entities/color_code_product_detail.dart';
import 'package:recycleorigin/features/store_feature/business/entities/order_send_details.dart';
import 'package:recycleorigin/features/store_feature/business/entities/product.dart';
import 'package:recycleorigin/features/store_feature/business/entities/product_cart.dart';
import 'package:recycleorigin/features/store_feature/business/entities/product_main.dart';
import 'package:recycleorigin/features/store_feature/presentation/bloc/products_event.dart';
import 'package:recycleorigin/features/store_feature/presentation/bloc/products_state.dart';

/// Manages product catalog, search, cart, and order submission.
class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  ProductsBloc(this._apiClient) : super(ProductsState()) {
    on<ProductsCartItemsSet>(_onCartItemsSet);
    on<ProductsItemSet>(_onItemSet);
    on<ProductsSearchParamsChanged>(_onSearchParamsChanged);
    on<ProductsSearchBuilderApplied>(_onSearchBuilderApplied);
    on<ProductsCheckFilteredRequested>(_onCheckFiltered);
    on<ProductsAddShopCartRequested>(_onAddShopCart);
    on<ProductsUpdateShopCartRequested>(_onUpdateShopCart);
    on<ProductsRemoveShopCartRequested>(_onRemoveShopCart);
    on<ProductsRetrieveCategoryRequested>(_onRetrieveCategory);
    on<ProductsSearchItemRequested>(_onSearchItem);
    on<ProductsRetrieveItemRequested>(_onRetrieveItem);
    on<ProductsSendRequestRequested>(_onSendRequest);
  }

  final ApiClient _apiClient;

  static Product get itemZero => Product();

  List<Product> get items => state.items;
  int get cartItemsCount => state.cartItems.length;
  Product get item => state.item;
  List<ProductCart> get cartItems => state.cartItems;
  Object? get sCategory => state.sCategory;
  set sCategory(Object? value) => value == null
      ? add(const ProductsSearchParamsChanged(clearSCategory: true))
      : add(ProductsSearchParamsChanged(sCategory: value));
  bool get isFiltered => state.isFiltered;
  List<Category> get categoryItems => state.categoryItems;
  String get searchEndPoint => state.searchEndPoint;
  String get searchKey => state.searchKey;
  set searchKey(String value) =>
      add(ProductsSearchParamsChanged(searchKey: value));
  List<String> get filterTitle => state.filterTitle;
  SearchDetail get searchDetails => state.searchDetails;

  set cartItems(List<ProductCart> value) => add(ProductsCartItemsSet(value));
  set item(Product value) => add(ProductsItemSet(value));
  set sPage(int value) => add(ProductsSearchParamsChanged(sPage: value));
  set sPerPage(int value) => add(ProductsSearchParamsChanged(sPerPage: value));
  set sOrder(String value) => add(ProductsSearchParamsChanged(sOrder: value));
  set sOrderBy(String value) =>
      add(ProductsSearchParamsChanged(sOrderBy: value));

  Product findById() => state.item;

  Future<void> checkFiltered() async {
    add(const ProductsCheckFilteredRequested());
  }

  void searchBuilder() {
    add(const ProductsSearchBuilderApplied());
  }

  Future<void> addShopCart(
    Product product,
    ColorCodeProductDetail colorId,
    int quantity,
  ) {
    final c = Completer<void>();
    add(ProductsAddShopCartRequested(
      product,
      colorId,
      quantity,
      completer: c,
    ));
    return c.future;
  }

  Future<void> updateShopCart(
    ProductCart product,
    ColorCodeCard colorId,
    int quantity,
    bool isLogin,
  ) {
    final c = Completer<void>();
    add(ProductsUpdateShopCartRequested(
      product,
      colorId,
      quantity,
      isLogin,
      completer: c,
    ));
    return c.future;
  }

  Future<void> removeShopCart(int productId) {
    final c = Completer<void>();
    add(ProductsRemoveShopCartRequested(productId, completer: c));
    return c.future;
  }

  Future<void> retrieveCategory() {
    final c = Completer<void>();
    add(ProductsRetrieveCategoryRequested(completer: c));
    return c.future;
  }

  Future<void> searchItem() {
    final c = Completer<void>();
    add(ProductsSearchItemRequested(completer: c));
    return c.future;
  }

  Future<void> retrieveItem(int productId) {
    final c = Completer<void>();
    add(ProductsRetrieveItemRequested(productId, completer: c));
    return c.future;
  }

  Future<void> sendRequest(OrderSendDetails request) {
    final c = Completer<void>();
    add(ProductsSendRequestRequested(request, completer: c));
    return c.future;
  }

  void _onCartItemsSet(
    ProductsCartItemsSet event,
    Emitter<ProductsState> emit,
  ) {
    emit(state.copyWith(cartItems: event.cartItems));
  }

  void _onItemSet(ProductsItemSet event, Emitter<ProductsState> emit) {
    emit(state.copyWith(item: event.item));
  }

  void _onSearchParamsChanged(
    ProductsSearchParamsChanged event,
    Emitter<ProductsState> emit,
  ) {
    emit(state.copyWith(
      searchKey: event.searchKey,
      sPage: event.sPage,
      sPerPage: event.sPerPage,
      sOrder: event.sOrder,
      sOrderBy: event.sOrderBy,
      sCategory: event.sCategory,
      clearSCategory: event.clearSCategory,
    ));
  }

  void _applySearchBuilder(ProductsState s, Emitter<ProductsState> emit) {
    var searchEndPoint = '';
    if (s.searchKey != '') {
      searchEndPoint = '?search=${s.searchKey}';
      searchEndPoint =
          '$searchEndPoint&page=${s.sPage}&per_page=${s.sPerPage}';
    } else {
      searchEndPoint = '?page=${s.sPage}&per_page=${s.sPerPage}';
    }
    if (s.sOrder != '') {
      searchEndPoint = '$searchEndPoint&order=${s.sOrder}';
    }
    if (s.sOrderBy != '') {
      searchEndPoint = '$searchEndPoint&orderby=${s.sOrderBy}';
    }
    if (!(s.sCategory == '' || s.sCategory == null)) {
      searchEndPoint = '$searchEndPoint&category=${s.sCategory}';
    }
    AppLogger.debug('Search endpoint: $searchEndPoint');
    emit(s.copyWith(searchEndPoint: searchEndPoint));
  }

  void _onSearchBuilderApplied(
    ProductsSearchBuilderApplied event,
    Emitter<ProductsState> emit,
  ) {
    _applySearchBuilder(state, emit);
  }

  Future<void> _onCheckFiltered(
    ProductsCheckFilteredRequested event,
    Emitter<ProductsState> emit,
  ) async {
    final filtered = state.sCategory == '' ? false : true;
    emit(state.copyWith(isFiltered: filtered));
  }

  Future<void> _onAddShopCart(
    ProductsAddShopCartRequested event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      AppLogger.debug('Adding product to cart: ${event.product.id}');
      final next = List<ProductCart>.from(state.cartItems)
        ..add(ProductCart(
          id: event.product.id,
          title: event.product.name,
          price: event.product.price,
          featured_media_url: event.product.featured_image.sizes.medium,
          productCount: event.quantity,
        ));
      emit(state.copyWith(cartItems: next));
      event.completer?.complete();
    } catch (e, st) {
      AppLogger.error('Failed to add product to cart', error: e, stackTrace: st);
      event.completer?.completeError(e, st);
      rethrow;
    }
  }

  Future<void> _onUpdateShopCart(
    ProductsUpdateShopCartRequested event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      AppLogger.debug('Updating cart item: ${event.product.id}');
      final next = state.cartItems.map((p) {
        if (p.id == event.product.id) {
          return ProductCart(
            id: p.id,
            title: p.title,
            price: p.price,
            featured_media_url: p.featured_media_url,
            productCount: event.quantity,
          );
        }
        return p;
      }).toList(growable: false);
      emit(state.copyWith(cartItems: next));
      event.completer?.complete();
    } catch (e, st) {
      AppLogger.error('Failed to update cart item', error: e, stackTrace: st);
      event.completer?.completeError(e, st);
      rethrow;
    }
  }

  Future<void> _onRemoveShopCart(
    ProductsRemoveShopCartRequested event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      AppLogger.debug('Removing product from cart: ${event.productId}');
      final next = List<ProductCart>.from(state.cartItems)
        ..removeWhere((p) => p.id == event.productId);
      emit(state.copyWith(cartItems: next));
      event.completer?.complete();
    } catch (e, st) {
      AppLogger.error('Failed to remove product from cart',
          error: e, stackTrace: st);
      event.completer?.completeError(e, st);
      rethrow;
    }
  }

  Future<void> _onRetrieveCategory(
    ProductsRetrieveCategoryRequested event,
    Emitter<ProductsState> emit,
  ) async {
    AppLogger.debug('Fetching categories');
    final path = 'pasmands/v1${Urls.categoriesEndPoint}';
    AppLogger.debug('Categories path: $path');

    final result = await _apiClient.get<List<dynamic>>(
      path,
      parser: (data) => data as List<dynamic>,
    );

    result.onSuccess((extractedData) {
      AppLogger.debug('Loaded ${extractedData.length} categories');
      final categories =
          extractedData.map((i) => Category.fromJson(i)).toList();
      emit(state.copyWith(categoryItems: categories));
      event.completer?.complete();
    }).onFailure((error) {
      AppLogger.error('Failed to retrieve categories: $error');
      event.completer?.completeError(error);
    });
  }

  Future<void> _onSearchItem(
    ProductsSearchItemRequested event,
    Emitter<ProductsState> emit,
  ) async {
    AppLogger.debug('Searching products');
    final path = 'pasmands/v1${Urls.productsEndPoint}${state.searchEndPoint}';
    AppLogger.debug('Products search path: $path');

    final result = await _apiClient.get<Map<String, dynamic>>(
      path,
      parser: (data) => data as Map<String, dynamic>,
    );

    result.onSuccess((extractedData) {
      AppLogger.debug('Products retrieved');
      final productMain = ProductMain.fromJson(extractedData);
      AppLogger.debug('Max page: ${productMain.productsDetail.max_page}');
      emit(state.copyWith(
        items: productMain.products,
        searchDetails: productMain.productsDetail,
      ));
      event.completer?.complete();
    }).onFailure((error) {
      AppLogger.error('Failed to search products: $error');
      emit(state.copyWith(items: []));
      event.completer?.complete();
    });
  }

  Future<void> _onRetrieveItem(
    ProductsRetrieveItemRequested event,
    Emitter<ProductsState> emit,
  ) async {
    AppLogger.debug('Retrieving product: ${event.productId}');
    final path = 'pasmands/v1${Urls.productsEndPoint}/${event.productId}';
    AppLogger.debug('Product path: $path');

    final result = await _apiClient.get<Map<String, dynamic>>(
      path,
      parser: (data) => data as Map<String, dynamic>,
    );

    result.onSuccess((extractedData) {
      AppLogger.debug('Product data retrieved');
      final product = Product.fromJson(extractedData);
      AppLogger.debug('Product ID: ${product.id}');
      emit(state.copyWith(item: product));
      event.completer?.complete();
    }).onFailure((error) {
      AppLogger.error('Failed to retrieve product: $error');
      event.completer?.completeError(Exception(error));
    });
  }

  Future<void> _onSendRequest(
    ProductsSendRequestRequested event,
    Emitter<ProductsState> emit,
  ) async {
    AppLogger.debug('Sending order request');
    final path = 'pasmands/v1${Urls.orderEndPoint}';
    AppLogger.debug('Order path: $path');

    final result = await _apiClient.post<Map<String, dynamic>>(
      path,
      data: event.request.toJson(),
      parser: (data) => data as Map<String, dynamic>,
    );

    result.onSuccess((_) {
      AppLogger.debug('Order request sent successfully');
      event.completer?.complete();
    }).onFailure((error) {
      AppLogger.error('Failed to send order request: $error');
      event.completer?.completeError(Exception(error));
    });
  }
}
