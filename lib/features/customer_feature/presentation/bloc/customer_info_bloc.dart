import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/core/constants/urls.dart';
import 'package:recycleorigin/core/models/customer.dart';
import 'package:recycleorigin/core/models/order.dart';
import 'package:recycleorigin/core/models/search_detail.dart';
import 'package:recycleorigin/core/models/status.dart';
import 'package:recycleorigin/core/models/transaction.dart';
import 'package:recycleorigin/core/network/api_client.dart';
import 'package:recycleorigin/core/utils/logger.dart';
import 'package:recycleorigin/core/utils/result.dart';
import 'package:recycleorigin/features/customer_feature/business/entities/city.dart';
import 'package:recycleorigin/features/customer_feature/business/entities/country.dart';
import 'package:recycleorigin/features/customer_feature/business/entities/province.dart';
import 'package:recycleorigin/features/customer_feature/business/entities/transaction_main.dart';
import 'package:recycleorigin/features/customer_feature/presentation/bloc/customer_info_event.dart';
import 'package:recycleorigin/features/customer_feature/presentation/bloc/customer_info_state.dart';
import 'package:recycleorigin/features/store_feature/business/entities/order_details.dart';
import 'package:recycleorigin/features/store_feature/business/entities/shop.dart';

class CustomerInfoBloc extends Bloc<CustomerInfoEvent, CustomerInfoState> {
  CustomerInfoBloc(this._apiClient) : super(CustomerInfoState()) {
    on<CustomerLoadRequested>(_onCustomerLoadRequested);
    on<CustomerSendRequested>(_onCustomerSendRequested);
    on<CustomerSetRequested>(_onCustomerSetRequested);
    on<CustomerResetRequested>(_onCustomerResetRequested);
    on<CustomerOrderDetailsRequested>(_onCustomerOrderDetailsRequested);
    on<CustomerPayCashOrderRequested>(_onCustomerPayCashOrderRequested);
    on<CustomerSendNaghdOrderRequested>(_onCustomerSendNaghdOrderRequested);
    on<CustomerShopDataRequested>(_onCustomerShopDataRequested);
    on<CustomerSearchParamsChanged>(_onCustomerSearchParamsChanged);
    on<CustomerSearchEndpointBuilt>(_onCustomerSearchEndpointBuilt);
    on<CustomerTransactionsSearchRequested>(
      _onCustomerTransactionsSearchRequested,
    );
    on<CustomerTransactionItemRequested>(_onCustomerTransactionItemRequested);
    on<CustomerProvincesRequested>(_onCustomerProvincesRequested);
    on<CustomerCountriesRequested>(_onCustomerCountriesRequested);
    on<CustomerProvincesByCountryRequested>(
      _onCustomerProvincesByCountryRequested,
    );
    on<CustomerCitiesRequested>(_onCustomerCitiesRequested);
    on<CustomerTypesRequested>(_onCustomerTypesRequested);
    on<CustomerClearingRequestSent>(_onCustomerClearingRequestSent);
  }

  final ApiClient _apiClient;

  String get payUrl => state.payUrl;
  int get currentOrderId => state.currentOrderId;
  Shop get shop => state.shop;
  Customer get customer => state.customer;
  List<Order> get orders => state.orders;
  List<Transaction> get transactionItems => state.transactionItems;
  SearchDetail get searchDetails => state.searchDetails;
  Transaction get transactionItem => state.transactionItem;
  List<Province> get provincesItems => state.provincesItems;
  List<Country> get countriesItems => state.countriesItems;
  List<City> get citiesItems => state.citiesItems;
  List<Status> get typesItems => state.typesItems;
  String get searchEndPoint => state.searchEndPoint;
  String get searchKey => state.searchKey;
  int get sPage => state.sPage;
  int get sPerPage => state.sPerPage;
  String get sOrder => state.sOrder;
  String get sOrderBy => state.sOrderBy;

  Customer get customer_zero => buildEmptyCustomer();
  OrderDetails get order => state.order;
  OrderDetails getOrder() => state.order;
  Order findById(int id) => state.orders.firstWhere((prod) => prod.id == id);

  set customer(Customer value) => add(CustomerSetRequested(value));
  set order(OrderDetails value) => emit(state.copyWith(order: value));
  set sPage(value) => add(CustomerSearchParamsChanged(sPage: value as int));
  set sPerPage(value) =>
      add(CustomerSearchParamsChanged(sPerPage: value as int));
  set sOrder(value) =>
      add(CustomerSearchParamsChanged(sOrder: value as String));
  set sOrderBy(value) =>
      add(CustomerSearchParamsChanged(sOrderBy: value as String));

  Future<void> getCustomer() {
    final completer = Completer<void>();
    add(CustomerLoadRequested(completer: completer));
    return completer.future;
  }

  Future<void> sendCustomer(Customer customer) {
    final completer = Completer<void>();
    add(CustomerSendRequested(customer, completer: completer));
    return completer.future;
  }

  Future<void> getOrderDetails(int orderId) {
    final completer = Completer<void>();
    add(CustomerOrderDetailsRequested(orderId, completer: completer));
    return completer.future;
  }

  Future<void> payCashOrder(int orderId) {
    final completer = Completer<void>();
    add(CustomerPayCashOrderRequested(orderId, completer: completer));
    return completer.future;
  }

  Future<void> sendNaghdOrder() {
    final completer = Completer<void>();
    add(CustomerSendNaghdOrderRequested(completer: completer));
    return completer.future;
  }

  Future<void> fetchShopData() {
    final completer = Completer<void>();
    add(CustomerShopDataRequested(completer: completer));
    return completer.future;
  }

  void searchBuilder() => add(const CustomerSearchEndpointBuilt());

  Future<void> searchTransactionItems() {
    final completer = Completer<void>();
    add(CustomerTransactionsSearchRequested(completer: completer));
    return completer.future;
  }

  Future<void> retrieveItem(int collectId) {
    final completer = Completer<void>();
    add(CustomerTransactionItemRequested(collectId, completer: completer));
    return completer.future;
  }

  Future<void> getProvinces() {
    final completer = Completer<void>();
    add(CustomerProvincesRequested(completer: completer));
    return completer.future;
  }

  Future<void> getCountries() {
    final completer = Completer<void>();
    add(CustomerCountriesRequested(completer: completer));
    return completer.future;
  }

  Future<void> getProvincesByCountry(int countryId) {
    final completer = Completer<void>();
    add(CustomerProvincesByCountryRequested(countryId, completer: completer));
    return completer.future;
  }

  Future<void> getCities(int provinceId) {
    final completer = Completer<void>();
    add(CustomerCitiesRequested(provinceId, completer: completer));
    return completer.future;
  }

  Future<void> getTypes() {
    final completer = Completer<void>();
    add(CustomerTypesRequested(completer: completer));
    return completer.future;
  }

  Future<void> sendClearingRequest(String money, String shaba) {
    final completer = Completer<void>();
    add(CustomerClearingRequestSent(
        money: money, shaba: shaba, completer: completer));
    return completer.future;
  }

  Future<void> _onCustomerLoadRequested(
    CustomerLoadRequested event,
    Emitter<CustomerInfoState> emit,
  ) async {
    final path = 'recycleorigin/v1${Urls.customerEndPoint}';
    final result = await _apiClient.get<Map<String, dynamic>>(
      path,
      parser: (data) => data as Map<String, dynamic>,
    );

    result.onSuccess((extractedData) {
      emit(state.copyWith(customer: Customer.fromJson(extractedData)));
      event.completer?.complete();
    }).onFailure((error) {
      event.completer?.completeError(Exception(error));
    });
  }

  Future<void> _onCustomerSendRequested(
    CustomerSendRequested event,
    Emitter<CustomerInfoState> emit,
  ) async {
    final path = 'recycleorigin/v1${Urls.customerEndPoint}';
    final result = await _apiClient.post<Map<String, dynamic>>(
      path,
      data: {
        'customer_type': event.customer.customer_type.toJson(),
        'customer_data': event.customer.personalData.toJson(),
      },
      parser: (data) => data as Map<String, dynamic>,
    );

    switch (result) {
      case Success<Map<String, dynamic>>():
        try {
          await _refreshCustomerAfterSave(emit);
        } catch (error, stackTrace) {
          AppLogger.warning(
            'Profile saved but refresh failed: $error',
            error,
            stackTrace,
          );
        }
        event.completer?.complete();
      case Failure<Map<String, dynamic>>(:final message):
        event.completer?.completeError(Exception(message));
    }
  }

  Future<void> _refreshCustomerAfterSave(
    Emitter<CustomerInfoState> emit,
  ) async {
    final path = 'recycleorigin/v1${Urls.customerEndPoint}';
    final result = await _apiClient.get<Map<String, dynamic>>(
      path,
      parser: (data) => data as Map<String, dynamic>,
    );

    result.onSuccess((extractedData) {
      emit(state.copyWith(customer: Customer.fromJson(extractedData)));
    }).onFailure((error) {
      throw Exception(error);
    });
  }

  void _onCustomerSetRequested(
    CustomerSetRequested event,
    Emitter<CustomerInfoState> emit,
  ) {
    emit(state.copyWith(customer: event.customer));
  }

  void _onCustomerResetRequested(
    CustomerResetRequested event,
    Emitter<CustomerInfoState> emit,
  ) {
    emit(state.copyWith(customer: buildEmptyCustomer()));
  }

  Future<void> _onCustomerOrderDetailsRequested(
    CustomerOrderDetailsRequested event,
    Emitter<CustomerInfoState> emit,
  ) async {
    final path =
        'recycleorigin/v1${Urls.orderInfoEndPoint}?order_id=${event.orderId}';
    final result = await _apiClient.get<Map<String, dynamic>>(
      path,
      parser: (data) => data as Map<String, dynamic>,
    );
    result.onSuccess((extractedData) {
      emit(
        state.copyWith(
          currentOrderId: event.orderId,
          order: OrderDetails.fromJson(extractedData),
        ),
      );
      event.completer?.complete();
    }).onFailure((error) {
      event.completer?.completeError(Exception(error));
    });
  }

  Future<void> _onCustomerPayCashOrderRequested(
    CustomerPayCashOrderRequested event,
    Emitter<CustomerInfoState> emit,
  ) async {
    final path =
        'recycleorigin/v1${Urls.payEndPoint}?order_id=${event.orderId}';
    final result = await _apiClient.get<dynamic>(
      path,
      parser: (data) => data,
    );
    result.onSuccess((extractedData) {
      final url = extractedData is String
          ? extractedData
          : extractedData is Map && extractedData.containsKey('url')
              ? extractedData['url'] as String
              : extractedData.toString();
      emit(state.copyWith(payUrl: url));
      event.completer?.complete();
    }).onFailure((error) {
      event.completer?.completeError(Exception(error));
    });
  }

  Future<void> _onCustomerSendNaghdOrderRequested(
    CustomerSendNaghdOrderRequested event,
    Emitter<CustomerInfoState> emit,
  ) async {
    final path = 'recycleorigin/v1${Urls.orderInfoEndPoint}?paytype=naghd';
    final result = await _apiClient.post<Map<String, dynamic>>(
      path,
      parser: (data) => data as Map<String, dynamic>,
    );
    result.onSuccess((extractedData) {
      emit(state.copyWith(currentOrderId: extractedData['order_id'] as int));
      event.completer?.complete();
    }).onFailure((error) {
      event.completer?.completeError(Exception(error));
    });
  }

  Future<void> _onCustomerShopDataRequested(
    CustomerShopDataRequested event,
    Emitter<CustomerInfoState> emit,
  ) async {
    final path = 'recycleorigin/v1${Urls.shopEndPoint}';
    final result = await _apiClient.get<Map<String, dynamic>>(
      path,
      parser: (data) => data as Map<String, dynamic>,
    );
    result.onSuccess((extractedData) {
      emit(state.copyWith(shop: Shop.fromJson(extractedData)));
      event.completer?.complete();
    }).onFailure((error) {
      event.completer?.completeError(Exception(error));
    });
  }

  void _onCustomerSearchParamsChanged(
    CustomerSearchParamsChanged event,
    Emitter<CustomerInfoState> emit,
  ) {
    emit(
      state.copyWith(
        searchKey: event.searchKey ?? state.searchKey,
        sPage: event.sPage ?? state.sPage,
        sPerPage: event.sPerPage ?? state.sPerPage,
        sOrder: event.sOrder ?? state.sOrder,
        sOrderBy: event.sOrderBy ?? state.sOrderBy,
      ),
    );
  }

  void _onCustomerSearchEndpointBuilt(
    CustomerSearchEndpointBuilt event,
    Emitter<CustomerInfoState> emit,
  ) {
    var searchEndPoint = '';
    if (state.searchKey.isNotEmpty) {
      searchEndPoint = '?search=${state.searchKey}';
      searchEndPoint =
          '$searchEndPoint&page=${state.sPage}&per_page=${state.sPerPage}';
    } else {
      searchEndPoint = '?page=${state.sPage}&per_page=${state.sPerPage}';
    }
    if (state.sOrder.isNotEmpty) {
      searchEndPoint = '$searchEndPoint&order=${state.sOrder}';
    }
    if (state.sOrderBy.isNotEmpty) {
      searchEndPoint = '$searchEndPoint&orderby=${state.sOrderBy}';
    }
    emit(state.copyWith(searchEndPoint: searchEndPoint));
  }

  Future<void> _onCustomerTransactionsSearchRequested(
    CustomerTransactionsSearchRequested event,
    Emitter<CustomerInfoState> emit,
  ) async {
    final path =
        'recycleorigin/v1${Urls.transactionsEndPoint}${state.searchEndPoint}';
    final result = await _apiClient.get<Map<String, dynamic>>(
      path,
      parser: (data) => data as Map<String, dynamic>,
    );
    result.onSuccess((extractedData) {
      final main = TransactionMain.fromJson(extractedData);
      emit(
        state.copyWith(
          transactionItems: main.transactions,
          searchDetails: main.searchDetail,
        ),
      );
      event.completer?.complete();
    }).onFailure((error) {
      AppLogger.error('Failed to search transaction items: $error');
      emit(state.copyWith(transactionItems: <Transaction>[]));
      event.completer?.complete();
    });
  }

  Future<void> _onCustomerTransactionItemRequested(
    CustomerTransactionItemRequested event,
    Emitter<CustomerInfoState> emit,
  ) async {
    final path = 'recycleorigin/v1${Urls.collectsEndPoint}/${event.collectId}';
    final result = await _apiClient.get<Map<String, dynamic>>(
      path,
      parser: (data) => data as Map<String, dynamic>,
    );
    result.onSuccess((extractedData) {
      emit(
          state.copyWith(transactionItem: Transaction.fromJson(extractedData)));
      event.completer?.complete();
    }).onFailure((error) {
      event.completer?.completeError(Exception(error));
    });
  }

  Future<void> _onCustomerProvincesRequested(
    CustomerProvincesRequested event,
    Emitter<CustomerInfoState> emit,
  ) async {
    final result = await _apiClient.get<List<dynamic>>(
      'recycleorigin/v1${Urls.provincesEndPoint}',
      parser: (data) => data as List<dynamic>,
    );
    result.onSuccess((data) {
      emit(
        state.copyWith(
          provincesItems: data.map((i) => Province.fromJson(i)).toList(),
        ),
      );
      event.completer?.complete();
    }).onFailure((error) {
      emit(state.copyWith(provincesItems: <Province>[]));
      event.completer?.complete();
    });
  }

  Future<void> _onCustomerCountriesRequested(
    CustomerCountriesRequested event,
    Emitter<CustomerInfoState> emit,
  ) async {
    final result = await _apiClient.get<List<dynamic>>(
      'recycleorigin/v1${Urls.countriesEndPoint}',
      parser: (data) => data as List<dynamic>,
    );
    result.onSuccess((data) {
      emit(
        state.copyWith(
          countriesItems: data.map((i) => Country.fromJson(i)).toList(),
        ),
      );
      event.completer?.complete();
    }).onFailure((error) {
      emit(state.copyWith(countriesItems: <Country>[]));
      event.completer?.complete();
    });
  }

  Future<void> _onCustomerProvincesByCountryRequested(
    CustomerProvincesByCountryRequested event,
    Emitter<CustomerInfoState> emit,
  ) async {
    final result = await _apiClient.get<List<dynamic>>(
      'recycleorigin/v1${Urls.provincesEndPoint}',
      queryParameters: <String, dynamic>{'country_id': event.countryId},
      parser: (data) => data as List<dynamic>,
    );
    result.onSuccess((data) {
      emit(
        state.copyWith(
          provincesItems: data.map((i) => Province.fromJson(i)).toList(),
        ),
      );
      event.completer?.complete();
    }).onFailure((error) {
      emit(state.copyWith(provincesItems: <Province>[]));
      event.completer?.complete();
    });
  }

  Future<void> _onCustomerCitiesRequested(
    CustomerCitiesRequested event,
    Emitter<CustomerInfoState> emit,
  ) async {
    final result = await _apiClient.get<List<dynamic>>(
      'recycleorigin/v1${Urls.provincesEndPoint}/${event.provinceId}',
      parser: (data) => data as List<dynamic>,
    );
    result.onSuccess((data) {
      emit(state.copyWith(
          citiesItems: data.map((i) => City.fromJson(i)).toList()));
      event.completer?.complete();
    }).onFailure((error) {
      emit(state.copyWith(citiesItems: <City>[]));
      event.completer?.complete();
    });
  }

  Future<void> _onCustomerTypesRequested(
    CustomerTypesRequested event,
    Emitter<CustomerInfoState> emit,
  ) async {
    final result = await _apiClient.get<List<dynamic>>(
      'recycleorigin/v1${Urls.typesEndPoint}',
      parser: (data) => data as List<dynamic>,
    );
    result.onSuccess((data) {
      emit(state.copyWith(
          typesItems: data.map((i) => Status.fromJson(i)).toList()));
      event.completer?.complete();
    }).onFailure((error) {
      emit(state.copyWith(typesItems: <Status>[]));
      event.completer?.complete();
    });
  }

  Future<void> _onCustomerClearingRequestSent(
    CustomerClearingRequestSent event,
    Emitter<CustomerInfoState> emit,
  ) async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      'recycleorigin/v1${Urls.clearingEndPoint}',
      data: {'money': event.money, 'shaba': event.shaba},
      parser: (data) => data as Map<String, dynamic>,
    );
    result.onSuccess((_) {
      event.completer?.complete();
    }).onFailure((error) {
      event.completer?.completeError(Exception(error));
    });
  }
}
