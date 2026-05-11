/// Constants for Articles feature UI
class ArticlesConstants {
  ArticlesConstants._();

  // Spacing
  static const double horizontalPadding = 16.0;
  static const double verticalPadding = 12.0;
  static const double itemSpacing = 8.0;
  static const double categoryTabHeight = 48.0;
  static const double categoryTabPadding = 20.0;
  static const double categoryTabBorderWidth = 3.0;

  // Sizes
  static const double articleItemHeightRatio = 0.35;
  static const double articleImageAspectRatio = 16 / 9;
  static const double categoryChipHeight = 40.0;
  static const double categoryChipPadding = 12.0;

  // Text Sizes
  static const double titleFontSize = 16.0;
  static const double bodyFontSize = 14.0;
  static const double captionFontSize = 12.0;
  static const double categoryFontSize = 14.0;

  // Animation
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounceDuration = Duration(milliseconds: 300);

  // Pagination
  static const int itemsPerPage = 10;
  static const double paginationThreshold = 0.8; // Load more when 80% scrolled

  // UI Messages
  static const String noArticlesMessage = 'No articles found';
  static const String errorMessage = 'Failed to load articles';
  static const String retryButton = 'Retry';
  static const String allCategoriesLabel = 'All';
  static const String articlesCountLabel = 'Articles';
}
