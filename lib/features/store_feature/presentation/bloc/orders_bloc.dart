import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/core/constants/urls.dart';
import 'package:recycleorigin/core/models/order.dart';
import 'package:recycleorigin/core/models/search_detail.dart';
import 'package:recycleorigin/core/network/api_client.dart';
import 'package:recycleorigin/core/utils/logger.dart';
import 'package:recycleorigin/features/store_feature/business/entities/order_main.dart';
import 'package:recycleorigin/features/store_feature/presentation/bloc/orders_event.dart';
import 'package:recycleorigin/features/store_feature/presentation/bloc/orders_state.dart';

/// Manages authenticated user's orders.
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc(this._apiClient) : super(OrdersState()) {
    on<OrdersSearchParamsChanged>(_onSearchParamsChanged);
    on<OrdersSearchBuilderApplied>(_onSearchBuilderApplied);
    on<OrdersSearchOrderItemsRequested>(_onSearchOrderItems);
    on<OrdersRetrieveOrderItemRequested>(_onRetrieveOrderItem);
  }

  final ApiClient _apiClient;

  String get searchEndPoint => state.searchEndPoint;
  String get searchKey => state.searchKey;
  int get sPage => state.sPage;
  set sPage(int value) => add(OrdersSearchParamsChanged(sPage: value));
  int get sPerPage => state.sPerPage;
  set sPerPage(int value) => add(OrdersSearchParamsChanged(sPerPage: value));
  String get sOrder => state.sOrder;
  set sOrder(String value) => add(OrdersSearchParamsChanged(sOrder: value));
  String get sOrderBy => state.sOrderBy;
  set sOrderBy(String value) => add(OrdersSearchParamsChanged(sOrderBy: value));
  SearchDetail get searchDetails => state.searchDetails;
  List<Order> get ordersItems => state.ordersItems;
  Order? get orderItem => state.orderItem;

  void searchBuilder() {
    add(const OrdersSearchBuilderApplied());
  }

  Future<void> searchOrderItems() {
    final c = Completer<void>();
    add(OrdersSearchOrderItemsRequested(completer: c));
    return c.future;
  }

  Future<void> retrieveOrderItem(int orderId) {
    final c = Completer<void>();
    add(OrdersRetrieveOrderItemRequested(orderId, completer: c));
    return c.future;
  }

  void _onSearchParamsChanged(
    OrdersSearchParamsChanged event,
    Emitter<OrdersState> emit,
  ) {
    emit(state.copyWith(
      searchKey: event.searchKey,
      sPage: event.sPage,
      sPerPage: event.sPerPage,
      sOrder: event.sOrder,
      sOrderBy: event.sOrderBy,
    ));
  }

  void _onSearchBuilderApplied(
    OrdersSearchBuilderApplied event,
    Emitter<OrdersState> emit,
  ) {
    final s = state;
    var searchEndPoint = '';
    if (s.searchKey != '') {
      searchEndPoint = '?search=${s.searchKey}';
      searchEndPoint = '$searchEndPoint&page=${s.sPage}&per_page=${s.sPerPage}';
    } else {
      searchEndPoint = '?page=${s.sPage}&per_page=${s.sPerPage}';
    }
    if (s.sOrder != '') {
      searchEndPoint = '$searchEndPoint&order=${s.sOrder}';
    }
    if (s.sOrderBy != '') {
      searchEndPoint = '$searchEndPoint&orderby=${s.sOrderBy}';
    }
    AppLogger.debug('Search endpoint: $searchEndPoint');
    emit(s.copyWith(searchEndPoint: searchEndPoint));
  }

  Future<void> _onSearchOrderItems(
    OrdersSearchOrderItemsRequested event,
    Emitter<OrdersState> emit,
  ) async {
    AppLogger.debug('Searching order items');
    final path =
        'recycleorigin/v1${Urls.orderEndPoint}${state.searchEndPoint}';
    AppLogger.debug('Order search path: $path');
    try {
      final result = await _apiClient.get<Map<String, dynamic>>(
        path,
        parser: (data) => data as Map<String, dynamic>,
      );
      final extractedData = result.valueOrNull;
      if (extractedData != null) {
        AppLogger.debug('Order items retrieved');
        final ordersMain = OrdersMain.fromJson(extractedData);
        AppLogger.debug('Max page: ${ordersMain.searchDetail.max_page}');
        emit(state.copyWith(
          ordersItems: ordersMain.transactions,
          searchDetails: ordersMain.searchDetail,
        ));
      } else {
        emit(state.copyWith(ordersItems: []));
      }
      event.completer?.complete();
    } catch (e, st) {
      AppLogger.error('Failed to search order items', error: e, stackTrace: st);
      event.completer?.completeError(e, st);
      rethrow;
    }
  }

  Future<void> _onRetrieveOrderItem(
    OrdersRetrieveOrderItemRequested event,
    Emitter<OrdersState> emit,
  ) async {
    AppLogger.debug('Retrieving order item: ${event.orderId}');
    final path = 'recycleorigin/v1${Urls.orderEndPoint}/${event.orderId}';
    AppLogger.debug('Order item path: $path');
    try {
      final result = await _apiClient.get<Map<String, dynamic>>(
        path,
        parser: (data) => data as Map<String, dynamic>,
      );
      final extractedData = result.valueOrNull;
      if (extractedData == null) {
        throw Exception(result.errorOrNull ?? 'Order not found');
      }
      AppLogger.debug('Order item data retrieved');
      final order = Order.fromJson(extractedData);
      emit(state.copyWith(orderItem: order));
      event.completer?.complete();
    } catch (e, st) {
      AppLogger.error('Failed to retrieve order item',
          error: e, stackTrace: st);
      event.completer?.completeError(e, st);
      rethrow;
    }
  }
}
