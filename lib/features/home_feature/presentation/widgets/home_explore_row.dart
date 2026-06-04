import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import 'package:recycleorigin/l10n/l10n.dart';

/// Secondary shortcuts for destinations not in bottom navigation.
class HomeExploreRow extends StatelessWidget {
  const HomeExploreRow({
    super.key,
    required this.onArticlesTap,
    required this.onGuideTap,
  });

  final VoidCallback onArticlesTap;
  final VoidCallback onGuideTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      child: Row(
        children: [
          Expanded(
            child: _ExploreTile(
              title: context.l10n.articles,
              icon: Icons.article_outlined,
              color: AppTheme.serviceArticles,
              onTap: onArticlesTap,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: _ExploreTile(
              title: context.l10n.guideTitle,
              icon: Icons.menu_book_outlined,
              color: AppTheme.primaryDark,
              onTap: onGuideTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreTile extends StatelessWidget {
  const _ExploreTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: context.appColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          side: BorderSide(color: color.withValues(alpha: 0.12)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingMd + 2,
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: AppTheme.spacingSm + 2),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: context.colors.onSurface.withValues(alpha: 0.35),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
