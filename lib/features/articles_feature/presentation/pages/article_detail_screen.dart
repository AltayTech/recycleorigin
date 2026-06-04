import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/logic/en_to_ar_number_convertor.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/drawer_or_back_leading.dart';
import '../../business/entities/article.dart';
import '../constants/articles_constants.dart';
import '../bloc/articles_bloc.dart';
import 'package:recycleorigin/l10n/l10n.dart';

/// Screen for displaying article details
class ArticleDetailScreen extends StatefulWidget {
  static const routeName = '/articleDetailScreen';

  const ArticleDetailScreen({Key? key}) : super(key: key);

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  bool _isLoading = true;
  bool _isInitialized = false;
  String? _errorMessage;
  Article? _article;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadArticle();
      _isInitialized = true;
    }
  }

  Future<void> _loadArticle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final articleId = ModalRoute.of(context)?.settings.arguments as int?;
      if (articleId == null) {
        throw Exception('Article ID not provided');
      }

      final articlesBloc = context.read<ArticlesBloc>();
      await articlesBloc.retrieveItem(articleId);
      final article = articlesBloc.item;

      setState(() {
        _article = article;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load article';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        title: Text(
          'Article',
          style: const TextStyle(color: AppTheme.appBarIconColor),
        ),
        backgroundColor: AppTheme.appBarColor,
        iconTheme: const IconThemeData(color: AppTheme.appBarIconColor),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? _buildLoadingIndicator()
          : _errorMessage != null
              ? _buildErrorState(context)
              : _article == null
                  ? _buildEmptyState(context)
                  : _buildArticleContent(context, screenWidth, textScaleFactor),
      drawer: mainDrawerIfRootRoute(context),
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
              color: context.appColors.subtitleColor,
            ),
            const SizedBox(height: ArticlesConstants.verticalPadding),
            Text(
              _errorMessage ?? 'Failed to load article',
              style: TextStyle(
                fontSize: ArticlesConstants.bodyFontSize,
                color: context.colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ArticlesConstants.verticalPadding),
            ElevatedButton.icon(
              onPressed: _loadArticle,
              icon: Icon(Icons.refresh),
              label: Text(ArticlesConstants.retryButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: context.appColors.onHeroForeground,
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
              color: context.appColors.subtitleColor.withOpacity(0.5),
            ),
            const SizedBox(height: ArticlesConstants.verticalPadding),
            Text(
              'Article not found',
              style: TextStyle(
                fontSize: ArticlesConstants.bodyFontSize,
                color: context.colors.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleContent(
      BuildContext context, double screenWidth, double textScaleFactor) {
    if (_article == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured Image
          _buildFeaturedImage(_article!, screenWidth),

          // Article Header
          Padding(
            padding: const EdgeInsets.all(ArticlesConstants.horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category and Date
                _buildArticleMeta(_article!, textScaleFactor),
                const SizedBox(height: ArticlesConstants.itemSpacing),

                // Title
                _buildArticleTitle(_article!, textScaleFactor),
                const SizedBox(height: ArticlesConstants.verticalPadding),

                // Content
                _buildArticleHtmlContent(_article!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedImage(Article article, double screenWidth) {
    if (article.featured_image.isEmpty) {
      return Container(
        width: double.infinity,
        height: screenWidth * 0.6,
        color: context.appColors.scaffoldBackground,
        child: Icon(
          Icons.article_outlined,
          size: 64,
          color: context.appColors.subtitleColor,
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: screenWidth * 0.6,
      color: context.appColors.scaffoldBackground,
      child: Image.network(
        article.featured_image,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: AppTheme.primary,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: context.appColors.scaffoldBackground,
            child: Icon(
              Icons.broken_image_outlined,
              size: 64,
              color: context.appColors.subtitleColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildArticleMeta(Article article, double textScaleFactor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Category
        if (article.category.isNotEmpty)
          _buildCategoryChip(article.category.first.name, textScaleFactor),
        const Spacer(),
        // Date
        _buildDateInfo(article, textScaleFactor),
      ],
    );
  }

  Widget _buildCategoryChip(String categoryName, double textScaleFactor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ArticlesConstants.categoryChipPadding,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        categoryName,
        style: TextStyle(
          color: AppTheme.primary,
          fontSize: textScaleFactor * ArticlesConstants.captionFontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDateInfo(Article article, double textScaleFactor) {
    try {
      final date = DateTime.parse(article.post_date_gmt);
      final formattedDate =
          '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            size: 16,
            color: context.appColors.subtitleColor,
          ),
          const SizedBox(width: 6),
          Text(
            EnArConvertor().replaceArNumber(formattedDate),
            style: TextStyle(
              color: context.appColors.subtitleColor,
              fontSize: textScaleFactor * ArticlesConstants.bodyFontSize,
            ),
          ),
        ],
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildArticleTitle(Article article, double textScaleFactor) {
    return Text(
      article.title,
      style: TextStyle(
        color: context.colors.onSurface,
        fontSize: textScaleFactor * 20.0,
        fontWeight: FontWeight.bold,
        height: 1.4,
      ),
    );
  }

  Widget _buildArticleHtmlContent(Article article) {
    if (article.content.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
            vertical: ArticlesConstants.verticalPadding),
        child: Text(
          context.l10n.articleNoContentMessage,
          style: TextStyle(
            color: context.appColors.subtitleColor,
            fontSize: ArticlesConstants.bodyFontSize,
          ),
        ),
      );
    }

    return HtmlWidget(
      article.content,
      textStyle: TextStyle(
        fontSize: ArticlesConstants.bodyFontSize,
        color: context.colors.onSurface,
        height: 1.6,
      ),
      onTapUrl: (url) async {
        // Handle URL taps - could open in browser
        return true;
      },
    );
  }
}
