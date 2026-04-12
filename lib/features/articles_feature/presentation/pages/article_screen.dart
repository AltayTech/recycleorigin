import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../../core/logic/en_to_ar_number_convertor.dart';
import '../../../../core/models/category.dart';
import '../../../../core/models/search_detail.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/drawer_or_back_leading.dart';
import '../../business/entities/article.dart';
import '../constants/articles_constants.dart';
import '../bloc/articles_bloc.dart';
import '../bloc/articles_state.dart';
import '../widgets/article_item_article_screen.dart';

/// Main screen for displaying articles with category filtering
class ArticlesScreen extends StatefulWidget {
  static const routeName = '/articlesScreen';

  const ArticlesScreen({Key? key}) : super(key: key);

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  late final ScrollController _scrollController;
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _selectedCategoryId = 0;
  SearchDetail _searchDetails = SearchDetail();
  final List<Article> _articles = [];
  final List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent *
                ArticlesConstants.paginationThreshold &&
        !_isLoadingMore &&
        _currentPage < _searchDetails.max_page) {
      _loadMoreArticles();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeData();
      _isInitialized = true;
    }
  }

  Future<void> _initializeData() async {
    final articlesProvider = context.read<ArticlesBloc>();

    // Load categories
    await articlesProvider.retrieveCategory();

    // Initialize search
    articlesProvider.sPage = 1;
    articlesProvider.searchBuilder();

    // Load initial articles
    await _loadArticles();
  }

  Future<void> _loadArticles({bool isRefresh = false}) async {
    if (!isRefresh) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final articlesProvider = context.read<ArticlesBloc>();
      await articlesProvider.searchItem();

      final newArticles = articlesProvider.articleItems;
      _searchDetails = articlesProvider.searchDetails;

      setState(() {
        if (isRefresh) {
          _articles.clear();
        }
        _articles.addAll(newArticles);
        _categories.clear();
        _categories.addAll(articlesProvider.categoryItems);
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = ArticlesConstants.errorMessage;
      });
    }
  }

  Future<void> _loadMoreArticles() async {
    if (_isLoadingMore || _currentPage >= _searchDetails.max_page) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      final articlesProvider = context.read<ArticlesBloc>();
      articlesProvider.sPage = _currentPage;
      articlesProvider.searchBuilder();
      await articlesProvider.searchItem();

      final newArticles = articlesProvider.articleItems;
      setState(() {
        _articles.addAll(newArticles);
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        _currentPage--; // Revert page on error
      });
    }
  }

  Future<void> _onCategorySelected(int categoryId) async {
    if (_selectedCategoryId == categoryId) return;

    setState(() {
      _selectedCategoryId = categoryId;
      _currentPage = 1;
      _articles.clear();
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final articlesProvider = context.read<ArticlesBloc>();
      articlesProvider.sPage = 1;
      articlesProvider.sCategory = categoryId != 0 ? categoryId.toString() : '';
      articlesProvider.searchBuilder();
      await articlesProvider.searchItem();

      final newArticles = articlesProvider.articleItems;
      _searchDetails = articlesProvider.searchDetails;

      setState(() {
        _articles.addAll(newArticles);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = ArticlesConstants.errorMessage;
      });
    }
  }

  Future<void> _onRefresh() async {
    _currentPage = 1;
    final articlesProvider = context.read<ArticlesBloc>();
    articlesProvider.sPage = 1;
    articlesProvider.searchBuilder();
    await _loadArticles(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        title: const Text(
          'Articles',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.appBarColor,
        iconTheme: const IconThemeData(color: AppTheme.appBarIconColor),
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppTheme.primary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Category Filter Section
            SliverToBoxAdapter(
              child: _buildCategoryFilter(context),
            ),

            // Results Count Section
            if (!_isLoading && _errorMessage == null)
              SliverToBoxAdapter(
                child: _buildResultsCount(context),
              ),

            // Content Section
            if (_isLoading && _articles.isEmpty)
              SliverFillRemaining(
                child: _buildLoadingIndicator(),
              )
            else if (_errorMessage != null && _articles.isEmpty)
              SliverFillRemaining(
                child: _buildErrorState(context),
              )
            else if (_articles.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(context),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ArticlesConstants.horizontalPadding,
                  vertical: ArticlesConstants.itemSpacing,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < _articles.length) {
                        return ChangeNotifierProvider.value(
                          value: _articles[index],
                          child: const ArticleItemArticlesScreen(),
                        );
                      } else if (_isLoadingMore) {
                        return _buildLoadingMoreIndicator();
                      }
                      return const SizedBox.shrink();
                    },
                    childCount: _articles.length + (_isLoadingMore ? 1 : 0),
                  ),
                ),
              ),
          ],
        ),
      ),
      drawer: mainDrawerIfRootRoute(context),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return Container(
      color: AppTheme.white,
      height: ArticlesConstants.categoryTabHeight,
      margin: const EdgeInsets.only(
        top: ArticlesConstants.itemSpacing,
        bottom: ArticlesConstants.itemSpacing,
      ),
      child: Row(
        children: [
          // "All" category button
          _buildCategoryChip(
            label: ArticlesConstants.allCategoriesLabel,
            isSelected: _selectedCategoryId == 0,
            onTap: () => _onCategorySelected(0),
          ),
          // Category list
          Expanded(
            child: BlocBuilder<ArticlesBloc, ArticlesState>(
              builder: (context, state) {
                final categories = state.categoryItems;
                if (categories.isEmpty && !_isLoading) {
                  return const SizedBox.shrink();
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _buildCategoryChip(
                      label: category.name,
                      isSelected: _selectedCategoryId == category.term_id,
                      onTap: () => _onCategorySelected(category.term_id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.bg : Colors.transparent,
          border: isSelected
              ? Border(
                  bottom: BorderSide(
                    color: AppTheme.primary,
                    width: ArticlesConstants.categoryTabBorderWidth,
                  ),
                )
              : null,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: ArticlesConstants.categoryTabPadding,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.primary : AppTheme.h1,
              fontSize: ArticlesConstants.categoryFontSize,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsCount(BuildContext context) {
    if (_searchDetails.total <= 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ArticlesConstants.horizontalPadding,
        vertical: ArticlesConstants.itemSpacing,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '${ArticlesConstants.articlesCountLabel}: ',
            style: TextStyle(
              fontSize: ArticlesConstants.captionFontSize,
              color: AppTheme.h1.withOpacity(0.7),
            ),
          ),
          Text(
            EnArConvertor().replaceArNumber(_searchDetails.total.toString()),
            style: TextStyle(
              fontSize: ArticlesConstants.bodyFontSize,
              color: AppTheme.h1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: SpinKitFadingCircle(
        color: AppTheme.primary,
        size: 50.0,
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.all(ArticlesConstants.verticalPadding),
      child: Center(
        child: SpinKitFadingCircle(
          color: AppTheme.primary,
          size: 40.0,
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ArticlesConstants.horizontalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.grey,
            ),
            const SizedBox(height: ArticlesConstants.verticalPadding),
            Text(
              _errorMessage ?? ArticlesConstants.errorMessage,
              style: TextStyle(
                fontSize: ArticlesConstants.bodyFontSize,
                color: AppTheme.h1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ArticlesConstants.verticalPadding),
            ElevatedButton.icon(
              onPressed: () {
                _currentPage = 1;
                _loadArticles();
              },
              icon: const Icon(Icons.refresh),
              label: const Text(ArticlesConstants.retryButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ArticlesConstants.horizontalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: AppTheme.grey.withOpacity(0.5),
            ),
            const SizedBox(height: ArticlesConstants.verticalPadding),
            Text(
              ArticlesConstants.noArticlesMessage,
              style: TextStyle(
                fontSize: ArticlesConstants.bodyFontSize,
                color: AppTheme.h1.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
