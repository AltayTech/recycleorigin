import 'package:recycleorigin/core/models/category.dart';
import 'package:recycleorigin/core/models/search_detail.dart';
import 'package:recycleorigin/features/store_feature/business/entities/product.dart';
import 'package:recycleorigin/features/store_feature/business/entities/product_cart.dart';

/// Immutable snapshot of the shop / product catalog and cart.
class ProductsState {
  ProductsState({
    List<Product>? items,
    List<ProductCart>? cartItems,
    List<Category>? categoryItems,
    List<String>? filterTitle,
    this.searchEndPoint = '',
    this.searchKey = '',
    this.sPage = 1,
    this.sPerPage = 10,
    this.sOrder = 'desc',
    this.sOrderBy = 'date',
    this.sCategory,
    this.isFiltered = false,
    SearchDetail? searchDetails,
    Product? item,
  })  : items = items ?? const [],
        cartItems = cartItems ?? const [],
        categoryItems = categoryItems ?? const [],
        filterTitle = filterTitle ?? const [],
        searchDetails =
            searchDetails ?? SearchDetail(max_page: 1, total: 10),
        item = item ?? Product();

  final List<Product> items;
  final List<ProductCart> cartItems;
  final List<Category> categoryItems;
  final List<String> filterTitle;
  final String searchEndPoint;
  final String searchKey;
  final int sPage;
  final int sPerPage;
  final String sOrder;
  final String sOrderBy;
  final Object? sCategory;
  final bool isFiltered;
  final SearchDetail searchDetails;
  final Product item;

  ProductsState copyWith({
    List<Product>? items,
    List<ProductCart>? cartItems,
    List<Category>? categoryItems,
    List<String>? filterTitle,
    String? searchEndPoint,
    String? searchKey,
    int? sPage,
    int? sPerPage,
    String? sOrder,
    String? sOrderBy,
    Object? sCategory,
    bool clearSCategory = false,
    bool? isFiltered,
    SearchDetail? searchDetails,
    Product? item,
  }) {
    return ProductsState(
      items: items ?? this.items,
      cartItems: cartItems ?? this.cartItems,
      categoryItems: categoryItems ?? this.categoryItems,
      filterTitle: filterTitle ?? this.filterTitle,
      searchEndPoint: searchEndPoint ?? this.searchEndPoint,
      searchKey: searchKey ?? this.searchKey,
      sPage: sPage ?? this.sPage,
      sPerPage: sPerPage ?? this.sPerPage,
      sOrder: sOrder ?? this.sOrder,
      sOrderBy: sOrderBy ?? this.sOrderBy,
      sCategory:
          clearSCategory ? null : (sCategory ?? this.sCategory),
      isFiltered: isFiltered ?? this.isFiltered,
      searchDetails: searchDetails ?? this.searchDetails,
      item: item ?? this.item,
    );
  }
}
