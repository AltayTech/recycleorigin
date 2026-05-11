import 'package:recycleorigin/core/models/category.dart';
import 'package:recycleorigin/core/models/search_detail.dart';
import 'package:recycleorigin/features/articles_feature/business/entities/article.dart';
import 'package:recycleorigin/features/articles_feature/business/entities/article_cat.dart';

Article buildEmptyArticle() => Article(
      id: 0,
      title: '',
      content: '',
      post_date_gmt: '',
      category: const <ArticleCat>[],
      featured_image: '',
    );

/// Immutable snapshot for article listing and detail.
class ArticlesState {
  ArticlesState({
    List<Article>? articleItems,
    List<int>? wasteCartItemsId,
    SearchDetail? searchDetails,
    this.searchEndPoint = '',
    this.searchKey = '',
    this.sPage = 1,
    this.sPerPage = 10,
    this.sCategory,
    List<Category>? categoryItems,
    Article? item,
  })  : articleItems = articleItems ?? const [],
        wasteCartItemsId = wasteCartItemsId ?? const [],
        searchDetails =
            searchDetails ?? SearchDetail(max_page: 1, total: 10),
        categoryItems = categoryItems ?? const [],
        item = item ?? buildEmptyArticle();

  final List<Article> articleItems;
  final List<int> wasteCartItemsId;
  final SearchDetail searchDetails;
  final String searchEndPoint;
  final String searchKey;
  final int sPage;
  final int sPerPage;
  final Object? sCategory;
  final List<Category> categoryItems;
  final Article item;

  ArticlesState copyWith({
    List<Article>? articleItems,
    List<int>? wasteCartItemsId,
    SearchDetail? searchDetails,
    String? searchEndPoint,
    String? searchKey,
    int? sPage,
    int? sPerPage,
    Object? sCategory,
    List<Category>? categoryItems,
    Article? item,
  }) {
    return ArticlesState(
      articleItems: articleItems ?? this.articleItems,
      wasteCartItemsId: wasteCartItemsId ?? this.wasteCartItemsId,
      searchDetails: searchDetails ?? this.searchDetails,
      searchEndPoint: searchEndPoint ?? this.searchEndPoint,
      searchKey: searchKey ?? this.searchKey,
      sPage: sPage ?? this.sPage,
      sPerPage: sPerPage ?? this.sPerPage,
      sCategory: sCategory ?? this.sCategory,
      categoryItems: categoryItems ?? this.categoryItems,
      item: item ?? this.item,
    );
  }
}
