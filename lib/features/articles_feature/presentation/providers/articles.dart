import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:recycleorigin/features/articles_feature/business/entities/article_main.dart';

import '../../business/entities/article.dart';
import '../../../../core/models/category.dart';
import '../../../../core/models/search_detail.dart';
import '../../../../core/constants/urls.dart';
import '../../../../core/utils/logger.dart';

class Articles with ChangeNotifier {
  List<Article> _articleItems = [];
  List<int> _wasteCartItemsId = [];
  SearchDetail _searchDetails = SearchDetail(max_page: 1, total: 10);

  late Article _item;

  String searchEndPoint = '';

  String searchKey = '';
  var _sPage = 1;
  var _sPerPage = 10;

  var _sCategory;

  List<Category> _categoryItems = [];

  void searchBuilder() {
    if (!(searchKey == '')) {
      searchEndPoint = '';

      searchEndPoint = searchEndPoint + '?search=$searchKey';
      searchEndPoint = searchEndPoint + '&page=$_sPage&per_page=$_sPerPage';
    } else {
      searchEndPoint = '';

      searchEndPoint = searchEndPoint + '?page=$_sPage&per_page=$_sPerPage';
    }

    if (!(_sCategory == '' || _sCategory == null)) {
      searchEndPoint = searchEndPoint + '&cat=$_sCategory';
    }
    AppLogger.debug('Search endpoint: $searchEndPoint');
  }

  get sCategory => _sCategory;

  set sCategory(value) {
    _sCategory = value;
  }

  Future<void> searchItem() async {
    AppLogger.debug('Searching articles');

    final url = Urls.rootUrl + Urls.articlesEndPoint + searchEndPoint;
    AppLogger.debug('Articles search URL: $url');

    try {
      final response = await get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      });
      AppLogger.debug('Articles search response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body);
        AppLogger.debug('Articles retrieved');

        ArticleMain articleMain = ArticleMain.fromJson(extractedData);

        _articleItems = articleMain.articles;
        _searchDetails = articleMain.articlesDetail;
      } else {
        _articleItems = [];
      }
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to search articles',
          error: error, stackTrace: stackTrace);
      // throw (error);
    }
  }

  Future<void> retrieveCategory() async {
    AppLogger.debug('Retrieving article categories');

    final url = Urls.rootUrl + Urls.articlesCatEndPoint;
    AppLogger.debug('Article categories URL: $url');

    try {
      final response = await get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      });

      final extractedData = json.decode(response.body) as List<dynamic>;
      AppLogger.debug('Loaded ${extractedData.length} article categories');

      List<Category> categories =
          extractedData.map((i) => Category.fromJson(i)).toList();

      _categoryItems = categories;
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to retrieve article categories',
          error: error, stackTrace: stackTrace);
      // throw (error);
    }
  }

  Future<void> retrieveItem(int articleId) async {
    AppLogger.debug('Retrieving article: $articleId');

    final url = Urls.rootUrl + Urls.articlesEndPoint + "/$articleId";
    AppLogger.debug('Article URL: $url');

    try {
      final response = await get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      });
      final extractedData = json.decode(response.body) as dynamic;
      AppLogger.debug('Article data retrieved');

      Article article = Article.fromJson(extractedData);
      AppLogger.debug('Article ID: ${article.id}');

      _item = article;
    } catch (error, stackTrace) {
      AppLogger.error('Failed to retrieve article',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
    notifyListeners();
  }

  set sPerPage(value) {
    _sPerPage = value;
  }

  set sPage(value) {
    _sPage = value;
  }

  Article get item => _item;

  SearchDetail get searchDetails => _searchDetails;

  List<Category> get categoryItems => _categoryItems;

  List<int> get wasteCartItemsId => _wasteCartItemsId;

  List<Article> get articleItems => _articleItems;

  get sPage => _sPage;

  get sPerPage => _sPerPage;
}
