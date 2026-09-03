import 'package:recycleorigin/core/models/order.dart';
import 'package:recycleorigin/core/models/search_detail.dart';

/// Immutable snapshot for shop orders list and detail.
class OrdersState {
  OrdersState({
    this.token = '',
    this.searchEndPoint = '',
    this.searchKey = '',
    this.sPage = 1,
    this.sPerPage = 10,
    this.sOrder = 'desc',
    this.sOrderBy = 'date',
    List<Order>? ordersItems,
    SearchDetail? searchDetails,
    this.orderItem,
  }) : ordersItems = ordersItems ?? const [],
       searchDetails = searchDetails ?? SearchDetail();

  final String token;
  final String searchEndPoint;
  final String searchKey;
  final int sPage;
  final int sPerPage;
  final String sOrder;
  final String sOrderBy;
  final List<Order> ordersItems;
  final SearchDetail searchDetails;
  final Order? orderItem;

  OrdersState copyWith({
    String? token,
    String? searchEndPoint,
    String? searchKey,
    int? sPage,
    int? sPerPage,
    String? sOrder,
    String? sOrderBy,
    List<Order>? ordersItems,
    SearchDetail? searchDetails,
    Order? orderItem,
  }) {
    return OrdersState(
      token: token ?? this.token,
      searchEndPoint: searchEndPoint ?? this.searchEndPoint,
      searchKey: searchKey ?? this.searchKey,
      sPage: sPage ?? this.sPage,
      sPerPage: sPerPage ?? this.sPerPage,
      sOrder: sOrder ?? this.sOrder,
      sOrderBy: sOrderBy ?? this.sOrderBy,
      ordersItems: ordersItems ?? this.ordersItems,
      searchDetails: searchDetails ?? this.searchDetails,
      orderItem: orderItem ?? this.orderItem,
    );
  }
}
