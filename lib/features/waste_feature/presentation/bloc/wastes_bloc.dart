import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart' as diolib;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:recycleorigin/core/constants/urls.dart';
import 'package:recycleorigin/core/models/search_detail.dart';
import 'package:recycleorigin/core/storage/secure_storage.dart';
import 'package:recycleorigin/core/utils/logger.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/collect_main.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/request_waste.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/request_waste_item.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/waste.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/wasteCart.dart';
import 'package:recycleorigin/features/waste_feature/presentation/bloc/wastes_event.dart';
import 'package:recycleorigin/features/waste_feature/presentation/bloc/wastes_state.dart';

/// Manages waste items, cart, collect requests, and scheduling fields.
class WastesBloc extends Bloc<WastesEvent, WastesState> {
  WastesBloc() : super(WastesState()) {
    on<WastesSearchWastesItemRequested>(_onSearchWastesItem);
    on<WastesAddWasteCartRequested>(_onAddWasteCart);
    on<WastesUpdateWasteCartRequested>(_onUpdateWasteCart);
    on<WastesRemoveWasteCartRequested>(_onRemoveWasteCart);
    on<WastesSendRequestRequested>(_onSendRequest);
    on<WastesSelectedHoursSet>(_onSelectedHoursSet);
    on<WastesSelectedDaySet>(_onSelectedDaySet);
    on<WastesSearchParamsChanged>(_onSearchParamsChanged);
    on<WastesSearchBuilderApplied>(_onSearchBuilderApplied);
    on<WastesSearchCollectItemsRequested>(_onSearchCollectItems);
    on<WastesRetrieveCollectItemRequested>(_onRetrieveCollectItem);
    on<WastesMarkRequestsListDirty>(_onMarkRequestsListDirty);
    on<WastesSubmitDriverRatingRequested>(_onSubmitDriverRating);
  }

  String get token => state.token;
  List<WasteCart> get wasteCartItems => state.wasteCartItems;
  List<Waste> get wasteItems => state.wasteItems;
  List<int> get wasteCartItemsId => state.wasteCartItemsId;
  String get selectedHours => state.selectedHours;
  set selectedHours(String value) => add(WastesSelectedHoursSet(value));
  DateTime get selectedDay => state.selectedDay;
  set selectedDay(DateTime value) => add(WastesSelectedDaySet(value));
  String get searchEndPoint => state.searchEndPoint;
  String get searchKey => state.searchKey;
  Object? get sCategory => state.sCategory;
  set sCategory(Object? value) => add(WastesSearchParamsChanged(sCategory: value));
  int get sPage => state.sPage;
  set sPage(int value) => add(WastesSearchParamsChanged(sPage: value));
  int get sPerPage => state.sPerPage;
  set sPerPage(int value) => add(WastesSearchParamsChanged(sPerPage: value));
  String get sOrder => state.sOrder;
  set sOrder(String value) => add(WastesSearchParamsChanged(sOrder: value));
  String get sOrderBy => state.sOrderBy;
  set sOrderBy(String value) => add(WastesSearchParamsChanged(sOrderBy: value));
  RequestWasteItem? get requestWasteItem => state.requestWasteItem;
  SearchDetail get searchDetails => state.searchDetails;
  List<RequestWasteItem> get CollectItems => state.collectItems;
  bool get requestsListDirty => state.requestsListDirty;

  void searchBuilder() {
    add(const WastesSearchBuilderApplied());
  }

  void markRequestsListDirty() {
    add(const WastesMarkRequestsListDirty());
  }

  Future<void> searchWastesItem() {
    final c = Completer<void>();
    add(WastesSearchWastesItemRequested(completer: c));
    return c.future;
  }

  Future<void> addWasteCart(Waste waste, int weight) {
    final c = Completer<void>();
    add(WastesAddWasteCartRequested(waste, weight, completer: c));
    return c.future;
  }

  Future<void> updateWasteCart(WasteCart waste, int quantity) {
    final c = Completer<void>();
    add(WastesUpdateWasteCartRequested(waste, quantity, completer: c));
    return c.future;
  }

  Future<void> removeWasteCart(int wasteId) {
    final c = Completer<void>();
    add(WastesRemoveWasteCartRequested(wasteId, completer: c));
    return c.future;
  }

  Future<void> sendRequest(RequestWaste request, bool isLogin) {
    final c = Completer<void>();
    add(WastesSendRequestRequested(request, isLogin, completer: c));
    return c.future;
  }

  Future<void> searchCollectItems() {
    final c = Completer<void>();
    add(WastesSearchCollectItemsRequested(completer: c));
    return c.future;
  }

  Future<void> retrieveCollectItem(int collectId) {
    final c = Completer<void>();
    add(WastesRetrieveCollectItemRequested(collectId, completer: c));
    return c.future;
  }

  Future<void> submitDriverRating(int collectId, int score, String comment) {
    final c = Completer<void>();
    add(WastesSubmitDriverRatingRequested(
      collectId,
      score,
      comment,
      completer: c,
    ));
    return c.future;
  }

  void _onMarkRequestsListDirty(
    WastesMarkRequestsListDirty event,
    Emitter<WastesState> emit,
  ) {
    emit(state.copyWith(requestsListDirty: true));
  }

  void _onSelectedHoursSet(
    WastesSelectedHoursSet event,
    Emitter<WastesState> emit,
  ) {
    emit(state.copyWith(selectedHours: event.value));
  }

  void _onSelectedDaySet(
    WastesSelectedDaySet event,
    Emitter<WastesState> emit,
  ) {
    emit(state.copyWith(selectedDay: event.value));
  }

  void _onSearchParamsChanged(
    WastesSearchParamsChanged event,
    Emitter<WastesState> emit,
  ) {
    emit(state.copyWith(
      searchKey: event.searchKey,
      sPage: event.sPage,
      sPerPage: event.sPerPage,
      sOrder: event.sOrder,
      sOrderBy: event.sOrderBy,
      sCategory: event.sCategory,
    ));
  }

  void _onSearchBuilderApplied(
    WastesSearchBuilderApplied event,
    Emitter<WastesState> emit,
  ) {
    final s = state;
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

  Future<void> _onSearchWastesItem(
    WastesSearchWastesItemRequested event,
    Emitter<WastesState> emit,
  ) async {
    AppLogger.debug('Searching waste items');
    final url = Urls.rootUrl + Urls.wastesEndPoint;
    AppLogger.debug('Waste search URL: $url');
    try {
      final response = await get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      AppLogger.debug('Waste search response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body) as List<dynamic>;
        AppLogger.debug('Loaded ${extractedData.length} waste items');
        final wastes =
            extractedData.map((i) => Waste.fromJson(i)).toList();
        emit(state.copyWith(wasteItems: wastes));
      } else {
        emit(state.copyWith(wasteItems: []));
      }
      event.completer?.complete();
    } catch (e, st) {
      AppLogger.error('Failed to search waste items', error: e, stackTrace: st);
      event.completer?.completeError(e, st);
      rethrow;
    }
  }

  Future<void> _onAddWasteCart(
    WastesAddWasteCartRequested event,
    Emitter<WastesState> emit,
  ) async {
    try {
      AppLogger.debug('Adding waste to cart: ${event.waste.id}');
      final w = event.waste;
      final nextCart = List<WasteCart>.from(state.wasteCartItems)
        ..add(WasteCart(
          id: w.id,
          name: w.name,
          excerpt: w.excerpt,
          prices: w.prices,
          featured_image: w.featured_image,
          status: w.status,
          weight: event.weight,
        ));
      final nextIds = List<int>.from(state.wasteCartItemsId)..add(w.id);
      emit(state.copyWith(
        wasteCartItems: nextCart,
        wasteCartItemsId: nextIds,
      ));
      event.completer?.complete();
    } catch (e, st) {
      AppLogger.error('Failed to add waste to cart', error: e, stackTrace: st);
      event.completer?.completeError(e, st);
      rethrow;
    }
  }

  Future<void> _onUpdateWasteCart(
    WastesUpdateWasteCartRequested event,
    Emitter<WastesState> emit,
  ) async {
    try {
      AppLogger.debug('Updating waste cart item: ${event.waste.id}');
      final next = state.wasteCartItems.map((prod) {
        if (prod.id == event.waste.id) {
          return WasteCart(
            id: prod.id,
            name: prod.name,
            excerpt: prod.excerpt,
            prices: prod.prices,
            featured_image: prod.featured_image,
            status: prod.status,
            weight: event.quantity,
          );
        }
        return prod;
      }).toList();
      emit(state.copyWith(wasteCartItems: next));
      event.completer?.complete();
    } catch (e, st) {
      AppLogger.error('Failed to update waste cart', error: e, stackTrace: st);
      event.completer?.completeError(e, st);
      rethrow;
    }
  }

  Future<void> _onRemoveWasteCart(
    WastesRemoveWasteCartRequested event,
    Emitter<WastesState> emit,
  ) async {
    try {
      AppLogger.debug('Removing waste from cart: ${event.wasteId}');
      final cart = List<WasteCart>.from(state.wasteCartItems)
        ..removeWhere((p) => p.id == event.wasteId);
      final ids = List<int>.from(state.wasteCartItemsId)
        ..removeWhere((id) => id == event.wasteId);
      emit(state.copyWith(wasteCartItems: cart, wasteCartItemsId: ids));
      event.completer?.complete();
    } catch (e, st) {
      AppLogger.error('Failed to remove waste from cart',
          error: e, stackTrace: st);
      event.completer?.completeError(e, st);
      rethrow;
    }
  }

  Future<void> _onSendRequest(
    WastesSendRequestRequested event,
    Emitter<WastesState> emit,
  ) async {
    AppLogger.debug('Sending waste request');
    try {
      if (event.isLogin) {
        var token = await SecureStorage.getToken() ?? '';
        if (token.isEmpty) {
          throw Exception('Not logged in. Please sign in again.');
        }
        final url = Urls.rootUrl + Urls.collectsEndPoint;
        AppLogger.debug('Waste request URL: $url');
        final response = await post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(event.request),
        );
        if (response.statusCode < 200 || response.statusCode >= 300) {
          final body = json.decode(response.body);
          final message = body is Map && body['error'] != null
              ? body['error'].toString()
              : 'Failed to send request (${response.statusCode})';
          throw Exception(message);
        }
        AppLogger.debug('Waste request sent successfully');
        emit(state.copyWith(token: token, requestsListDirty: true));
      }
      event.completer?.complete();
    } catch (e, st) {
      AppLogger.error('Failed to send waste request', error: e, stackTrace: st);
      event.completer?.completeError(e, st);
      rethrow;
    }
  }

  Future<void> _onSearchCollectItems(
    WastesSearchCollectItemsRequested event,
    Emitter<WastesState> emit,
  ) async {
    AppLogger.debug('Searching collect items');
    final url = Urls.rootUrl + Urls.collectsEndPoint + state.searchEndPoint;
    AppLogger.debug('Collect search URL: $url');
    try {
      var token = await SecureStorage.getToken() ?? '';
      if (token.isEmpty) {
        emit(state.copyWith(collectItems: []));
        event.completer?.complete();
        return;
      }
      final response = await get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      AppLogger.debug('Collect search response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body);
        AppLogger.debug('Collect items retrieved');
        final collectMain = CollectMain.fromJson(extractedData);
        AppLogger.debug('Max page: ${collectMain.searchDetail.max_page}');
        emit(state.copyWith(
          collectItems: collectMain.requestWasteItem,
          searchDetails: collectMain.searchDetail,
          token: token,
          requestsListDirty: false,
        ));
      } else {
        emit(state.copyWith(collectItems: [], token: token));
      }
      event.completer?.complete();
    } catch (e, st) {
      AppLogger.error('Failed to search collect items', error: e, stackTrace: st);
      event.completer?.complete();
    }
  }

  Future<void> _onRetrieveCollectItem(
    WastesRetrieveCollectItemRequested event,
    Emitter<WastesState> emit,
  ) async {
    AppLogger.debug('Retrieving collect item: ${event.collectId}');
    final url = Urls.rootUrl + Urls.collectsEndPoint + '/${event.collectId}';
    AppLogger.debug('Collect item URL: $url');
    try {
      var token = await SecureStorage.getToken() ?? '';
      if (token.isEmpty) {
        throw Exception('Not logged in. Please sign in again.');
      }
      final dio = diolib.Dio();
      final response = await dio.get<dynamic>(
        url,
        options: diolib.Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      AppLogger.debug('Collect item response status: ${response.statusCode}');
      AppLogger.debug('Collect item data retrieved');
      final requestWasteItem =
          RequestWasteItem.fromJson(response.data as Map<String, dynamic>);
      AppLogger.debug('Collect item ID: ${requestWasteItem.id}');
      emit(state.copyWith(
        requestWasteItem: requestWasteItem,
        token: token,
      ));
      event.completer?.complete();
    } catch (e, st) {
      AppLogger.error('Failed to retrieve collect item',
          error: e, stackTrace: st);
      event.completer?.completeError(e, st);
      rethrow;
    }
  }

  Future<void> _onSubmitDriverRating(
    WastesSubmitDriverRatingRequested event,
    Emitter<WastesState> emit,
  ) async {
    final url =
        Urls.rootUrl + Urls.collectRatePath(event.collectId);
    try {
      final token = await SecureStorage.getToken() ?? '';
      if (token.isEmpty) {
        throw Exception('Not logged in.');
      }
      final response = await post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'score': event.score,
          'comment': event.comment,
        }),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final decoded = json.decode(response.body);
        final message = decoded is Map && decoded['error'] != null
            ? decoded['error'].toString()
            : 'Failed (${response.statusCode})';
        throw Exception(message);
      }
      final getUrl =
          Urls.rootUrl + Urls.collectsEndPoint + '/${event.collectId}';
      final dio = diolib.Dio();
      final refreshed = await dio.get<dynamic>(
        getUrl,
        options: diolib.Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      final item = RequestWasteItem.fromJson(
        refreshed.data as Map<String, dynamic>,
      );
      emit(state.copyWith(requestWasteItem: item));
      event.completer?.complete();
    } catch (e, st) {
      AppLogger.error('Submit driver rating failed', error: e, stackTrace: st);
      event.completer?.completeError(e, st);
      rethrow;
    }
  }
}
