import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/logic/en_to_ar_number_convertor.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import '../../business/entities/article.dart';
import '../constants/articles_constants.dart';
import '../pages/article_detail_screen.dart';

/// Widget for displaying an article item in the articles list
class ArticleItemArticlesScreen extends StatelessWidget {
  const ArticleItemArticlesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final article = Provider.of<Article>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Container(
      margin: const EdgeInsets.only(bottom: ArticlesConstants.itemSpacing),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(
              ArticleDetailScreen.routeName,
              arguments: article.id,
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(ArticlesConstants.itemSpacing),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Article Image
                _buildArticleImage(context, article, screenWidth),
                const SizedBox(width: ArticlesConstants.itemSpacing),
                // Article Content
                Expanded(
                  child: _buildArticleContent(
                    context,
                    article,
                    textScaleFactor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArticleImage(
    BuildContext context,
    Article article,
    double screenWidth,
  ) {
    final imageSize = screenWidth * ArticlesConstants.articleItemHeightRatio;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: imageSize,
        height: imageSize,
        color: context.appColors.scaffoldBackground,
        child: article.featured_image.isNotEmpty
            ? Image.network(
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
                      strokeWidth: 2,
                      color: AppTheme.primary,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder(context);
                },
              )
            : _buildImagePlaceholder(context),
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      color: context.appColors.scaffoldBackground,
      child: Icon(
        Icons.article_outlined,
        color: context.appColors.subtitleColor,
        size: 32,
      ),
    );
  }

  Widget _buildArticleContent(
    BuildContext context,
    Article article,
    double textScaleFactor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title
        Text(
          article.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.colors.onSurface,
            fontSize: textScaleFactor * ArticlesConstants.titleFontSize,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: ArticlesConstants.itemSpacing),
        // Footer with date and category
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Date
            _buildDateInfo(context, article, textScaleFactor),
            // Category
            if (article.category.isNotEmpty)
              _buildCategoryChip(article.category.first.name, textScaleFactor),
          ],
        ),
      ],
    );
  }

  Widget _buildDateInfo(
    BuildContext context,
    Article article,
    double textScaleFactor,
  ) {
    try {
      final date = DateTime.parse(article.post_date_gmt);
      final formattedDate =
          '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            size: 14,
            color: context.appColors.subtitleColor,
          ),
          const SizedBox(width: 4),
          Text(
            EnArConvertor().replaceArNumber(formattedDate),
            style: TextStyle(
              color: context.appColors.subtitleColor,
              fontSize: textScaleFactor * ArticlesConstants.captionFontSize,
            ),
          ),
        ],
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildCategoryChip(String categoryName, double textScaleFactor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ArticlesConstants.categoryChipPadding,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        categoryName,
        style: TextStyle(
          color: AppTheme.primary,
          fontSize: textScaleFactor * ArticlesConstants.captionFontSize,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
