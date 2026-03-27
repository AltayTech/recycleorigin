import 'dart:async';

/// Events for [OrdersBloc].
sealed class OrdersEvent {
  const OrdersEvent();
}

class OrdersSearchParamsChanged extends OrdersEvent {
  const OrdersSearchParamsChanged({
    this.searchKey,
    this.sPage,
    this.sPerPage,
    this.sOrder,
    this.sOrderBy,
  });
  final String? searchKey;
  final int? sPage;
  final int? sPerPage;
  final String? sOrder;
  final String? sOrderBy;
}

class OrdersSearchBuilderApplied extends OrdersEvent {
  const OrdersSearchBuilderApplied();
}

class OrdersSearchOrderItemsRequested extends OrdersEvent {
  const OrdersSearchOrderItemsRequested({this.completer});
  final Completer<void>? completer;
}

class OrdersRetrieveOrderItemRequested extends OrdersEvent {
  const OrdersRetrieveOrderItemRequested(this.orderId, {this.completer});
  final int orderId;
  final Completer<void>? completer;
}
