import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:recycleorigin/core/constants/urls.dart';
import 'package:recycleorigin/core/models/search_detail.dart';
import 'package:recycleorigin/core/utils/logger.dart';
import 'package:recycleorigin/features/clearing_feature/business/entities/clearing.dart';
import 'package:recycleorigin/features/clearing_feature/business/entities/clearing_main.dart';
import 'package:recycleorigin/features/clearing_feature/presentation/bloc/clearings_event.dart';
import 'package:recycleorigin/features/clearing_feature/presentation/bloc/clearings_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages clearing / delivery search and scheduling fields.
class ClearingsBloc extends Bloc<ClearingsEvent, ClearingsState> {
  ClearingsBloc() : super(ClearingsState()) {
    on<ClearingsSearchParamsChanged>(_onSearchParamsChanged);
    on<ClearingsSearchBuilderApplied>(_onSearchBuilderApplied);
    on<ClearingsSearchItemsRequested>(_onSearchItems);
    on<ClearingsSelectedHoursSet>(_onSelectedHoursSet);
    on<ClearingsSelectedDaySet>(_onSelectedDaySet);
  }

  String get selectedHours => state.selectedHours;
  set selectedHours(String value) => add(ClearingsSelectedHoursSet(value));
  DateTime get selectedDay => state.selectedDay;
  set selectedDay(DateTime value) => add(ClearingsSelectedDaySet(value));
  String get searchEndPoint => state.searchEndPoint;
  String get searchKey => state.searchKey;
  set searchKey(String value) =>
      add(ClearingsSearchParamsChanged(searchKey: value));
  Object? get sCategory => state.sCategory;
  set sCategory(Object? value) =>
      add(ClearingsSearchParamsChanged(sCategory: value));
  int get sPage => state.sPage;
  set sPage(int value) => add(ClearingsSearchParamsChanged(sPage: value));
  int get sPerPage => state.sPerPage;
  set sPerPage(int value) => add(ClearingsSearchParamsChanged(sPerPage: value));
  String get sOrder => state.sOrder;
  set sOrder(String value) => add(ClearingsSearchParamsChanged(sOrder: value));
  String get sOrderBy => state.sOrderBy;
  set sOrderBy(String value) =>
      add(ClearingsSearchParamsChanged(sOrderBy: value));
  List<Clearing> get deliveriesItems => state.deliveriesItems;
  SearchDetail get searchDetails => state.searchDetails;

  void searchBuilder() {
    add(const ClearingsSearchBuilderApplied());
  }

  Future<void> searchCleaingsItems() {
    final c = Completer<void>();
    add(ClearingsSearchItemsRequested(completer: c));
    return c.future;
  }

  void _onSelectedHoursSet(
    ClearingsSelectedHoursSet event,
    Emitter<ClearingsState> emit,
  ) {
    emit(state.copyWith(selectedHours: event.value));
  }

  void _onSelectedDaySet(
    ClearingsSelectedDaySet event,
    Emitter<ClearingsState> emit,
  ) {
    emit(state.copyWith(selectedDay: event.value));
  }

  void _onSearchParamsChanged(
    ClearingsSearchParamsChanged event,
    Emitter<ClearingsState> emit,
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
    ClearingsSearchBuilderApplied event,
    Emitter<ClearingsState> emit,
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
    if (!(s.sCategory == '' || s.sCategory == null)) {
      searchEndPoint = '$searchEndPoint&category=${s.sCategory}';
    }
    AppLogger.debug('Search endpoint: $searchEndPoint');
    emit(s.copyWith(searchEndPoint: searchEndPoint));
  }

  Future<void> _onSearchItems(
    ClearingsSearchItemsRequested event,
    Emitter<ClearingsState> emit,
  ) async {
    AppLogger.debug('Searching clearing items');
    final url = Urls.rootUrl + Urls.clearingEndPoint + state.searchEndPoint;
    AppLogger.debug('Clearing search URL: $url');
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token')!;
      final response = await get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      AppLogger.debug(
          'Clearing search response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body);
        AppLogger.debug('Clearing items retrieved');
        final deliveryMain = ClearingMain.fromJson(extractedData);
        AppLogger.debug('Max page: ${deliveryMain.searchDetail.max_page}');
        emit(state.copyWith(
          deliveriesItems: deliveryMain.clearings,
          searchDetails: deliveryMain.searchDetail,
          token: token,
        ));
      } else {
        emit(state.copyWith(deliveriesItems: [], token: token));
      }
      event.completer?.complete();
    } catch (e, st) {
      AppLogger.error('Failed to search clearing items',
          error: e, stackTrace: st);
      event.completer?.completeError(e, st);
      rethrow;
    }
  }
}
