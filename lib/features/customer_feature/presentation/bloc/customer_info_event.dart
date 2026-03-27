import 'dart:async';

import 'package:recycleorigin/core/models/customer.dart';

abstract class CustomerInfoEvent {
  const CustomerInfoEvent();
}

class CustomerLoadRequested extends CustomerInfoEvent {
  const CustomerLoadRequested({this.completer});
  final Completer<void>? completer;
}

class CustomerSendRequested extends CustomerInfoEvent {
  const CustomerSendRequested(this.customer, {this.completer});
  final Customer customer;
  final Completer<void>? completer;
}

class CustomerSetRequested extends CustomerInfoEvent {
  const CustomerSetRequested(this.customer);
  final Customer customer;
}

class CustomerResetRequested extends CustomerInfoEvent {
  const CustomerResetRequested();
}

class CustomerOrderDetailsRequested extends CustomerInfoEvent {
  const CustomerOrderDetailsRequested(this.orderId, {this.completer});
  final int orderId;
  final Completer<void>? completer;
}

class CustomerPayCashOrderRequested extends CustomerInfoEvent {
  const CustomerPayCashOrderRequested(this.orderId, {this.completer});
  final int orderId;
  final Completer<void>? completer;
}

class CustomerSendNaghdOrderRequested extends CustomerInfoEvent {
  const CustomerSendNaghdOrderRequested({this.completer});
  final Completer<void>? completer;
}

class CustomerShopDataRequested extends CustomerInfoEvent {
  const CustomerShopDataRequested({this.completer});
  final Completer<void>? completer;
}

class CustomerSearchParamsChanged extends CustomerInfoEvent {
  const CustomerSearchParamsChanged({
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

class CustomerSearchEndpointBuilt extends CustomerInfoEvent {
  const CustomerSearchEndpointBuilt();
}

class CustomerTransactionsSearchRequested extends CustomerInfoEvent {
  const CustomerTransactionsSearchRequested({this.completer});
  final Completer<void>? completer;
}

class CustomerTransactionItemRequested extends CustomerInfoEvent {
  const CustomerTransactionItemRequested(this.collectId, {this.completer});
  final int collectId;
  final Completer<void>? completer;
}

class CustomerProvincesRequested extends CustomerInfoEvent {
  const CustomerProvincesRequested({this.completer});
  final Completer<void>? completer;
}

class CustomerCountriesRequested extends CustomerInfoEvent {
  const CustomerCountriesRequested({this.completer});
  final Completer<void>? completer;
}

class CustomerProvincesByCountryRequested extends CustomerInfoEvent {
  const CustomerProvincesByCountryRequested(
    this.countryId, {
    this.completer,
  });
  final int countryId;
  final Completer<void>? completer;
}

class CustomerCitiesRequested extends CustomerInfoEvent {
  const CustomerCitiesRequested(this.provinceId, {this.completer});
  final int provinceId;
  final Completer<void>? completer;
}

class CustomerTypesRequested extends CustomerInfoEvent {
  const CustomerTypesRequested({this.completer});
  final Completer<void>? completer;
}

class CustomerClearingRequestSent extends CustomerInfoEvent {
  const CustomerClearingRequestSent({
    required this.money,
    required this.shaba,
    this.completer,
  });
  final String money;
  final String shaba;
  final Completer<void>? completer;
}
