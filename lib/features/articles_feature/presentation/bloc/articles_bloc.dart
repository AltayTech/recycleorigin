import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:recycleorigin/core/constants/urls.dart';
import 'package:recycleorigin/core/models/category.dart';
import 'package:recycleorigin/core/models/search_detail.dart';
import 'package:recycleorigin/core/utils/logger.dart';
import 'package:recycleorigin/features/articles_feature/business/entities/article.dart';
import 'package:recycleorigin/features/articles_feature/business/entities/article_main.dart';
import 'package:recycleorigin/features/articles_feature/presentation/bloc/articles_event.dart';
import 'package:recycleorigin/features/articles_feature/presentation/bloc/articles_state.dart';

/// Manages article categories, listing, and detail.
class ArticlesBloc extends Bloc<ArticlesEvent, ArticlesState> {
  ArticlesBloc() : super(ArticlesState()) {
    on<ArticlesSearchParamsChanged>(_onSearchParamsChanged);
    on<ArticlesSearchBuilderApplied>(_onSearchBuilderApplied);
    on<ArticlesSearchItemRequested>(_onSearchItem);
    on<ArticlesRetrieveCategoryRequested>(_onRetrieveCategory);
    on<ArticlesRetrieveItemRequested>(_onRetrieveItem);
  }

  Object? get sCategory => state.sCategory;
  set sCategory(Object? value) =>
      add(ArticlesSearchParamsChanged(sCategory: value));
  int get sPage => state.sPage;
  set sPage(int value) => add(ArticlesSearchParamsChanged(sPage: value));
  int get sPerPage => state.sPerPage;
  set sPerPage(int value) => add(ArticlesSearchParamsChanged(sPerPage: value));
  String get searchEndPoint => state.searchEndPoint;
  String get searchKey => state.searchKey;
  set searchKey(String value) =>
      add(ArticlesSearchParamsChanged(searchKey: value));
  Article get item => state.item;
  SearchDetail get searchDetails => state.searchDetails;
  List<Category> get categoryItems => state.categoryItems;
  List<int> get wasteCartItemsId => state.wasteCartItemsId;
  List<Article> get articleItems => state.articleItems;

  void searchBuilder() {
    add(const ArticlesSearchBuilderApplied());
  }

  Future<void> searchItem() {
    final c = Completer<void>();
    add(ArticlesSearchItemRequested(completer: c));
    return c.future;
  }

  Future<void> retrieveCategory() {
    final c = Completer<void>();
    add(ArticlesRetrieveCategoryRequested(completer: c));
    return c.future;
  }

  Future<void> retrieveItem(int articleId) {
    final c = Completer<void>();
    add(ArticlesRetrieveItemRequested(articleId, completer: c));
    return c.future;
  }

  void _onSearchParamsChanged(
    ArticlesSearchParamsChanged event,
    Emitter<ArticlesState> emit,
  ) {
    emit(state.copyWith(
      searchKey: event.searchKey,
      sPage: event.sPage,
      sPerPage: event.sPerPage,
      sCategory: event.sCategory,
    ));
  }

  void _onSearchBuilderApplied(
    ArticlesSearchBuilderApplied event,
    Emitter<ArticlesState> emit,
  ) {
    final s = state;
    var searchEndPoint = '';
    if (s.searchKey != '') {
      searchEndPoint = '?search=${s.searchKey}';
      searchEndPoint = '$searchEndPoint&page=${s.sPage}&per_page=${s.sPerPage}';
    } else {
      searchEndPoint = '?page=${s.sPage}&per_page=${s.sPerPage}';
    }
    if (!(s.sCategory == '' || s.sCategory == null)) {
      searchEndPoint = '$searchEndPoint&cat=${s.sCategory}';
    }
    AppLogger.debug('Search endpoint: $searchEndPoint');
    emit(s.copyWith(searchEndPoint: searchEndPoint));
  }

  Future<void> _onSearchItem(
    ArticlesSearchItemRequested event,
    Emitter<ArticlesState> emit,
  ) async {
    AppLogger.debug('Searching articles');
    final url = Urls.rootUrl + Urls.articlesEndPoint + state.searchEndPoint;
    AppLogger.debug('Articles search URL: $url');
    try {
      final response = await get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      AppLogger.debug(
          'Articles search response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body);
        AppLogger.debug('Articles retrieved');
        final articleMain = ArticleMain.fromJson(extractedData);
        emit(state.copyWith(
          articleItems: articleMain.articles,
          searchDetails: articleMain.articlesDetail,
        ));
      } else {
        emit(state.copyWith(articleItems: []));
      }
      event.completer?.complete();
    } catch (e, st) {
      AppLogger.error('Failed to search articles', error: e, stackTrace: st);
      event.completer?.complete();
    }
  }

  Future<void> _onRetrieveCategory(
    ArticlesRetrieveCategoryRequested event,
    Emitter<ArticlesState> emit,
  ) async {
    AppLogger.debug('Retrieving article categories');
    final url = Urls.rootUrl + Urls.articlesCatEndPoint;
    AppLogger.debug('Article categories URL: $url');
    try {
      final response = await get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      final extractedData = json.decode(response.body) as List<dynamic>;
      AppLogger.debug('Loaded ${extractedData.length} article categories');
      final categories =
          extractedData.map((i) => Category.fromJson(i)).toList();
      emit(state.copyWith(categoryItems: categories));
      event.completer?.complete();
    } catch (e, st) {
      AppLogger.error('Failed to retrieve article categories',
          error: e, stackTrace: st);
      event.completer?.complete();
    }
  }

  Future<void> _onRetrieveItem(
    ArticlesRetrieveItemRequested event,
    Emitter<ArticlesState> emit,
  ) async {
    AppLogger.debug('Retrieving article: ${event.articleId}');
    final url = Urls.rootUrl + Urls.articlesEndPoint + '/${event.articleId}';
    AppLogger.debug('Article URL: $url');
    try {
      final response = await get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      final extractedData = json.decode(response.body) as dynamic;
      AppLogger.debug('Article data retrieved');
      final article = Article.fromJson(extractedData);
      AppLogger.debug('Article ID: ${article.id}');
      emit(state.copyWith(item: article));
      event.completer?.complete();
    } catch (e, st) {
      AppLogger.error('Failed to retrieve article', error: e, stackTrace: st);
      event.completer?.completeError(e, st);
      rethrow;
    }
  }
}
