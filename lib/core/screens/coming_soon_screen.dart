import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/theme_context_extensions.dart';
import 'package:recycleorigin/l10n/l10n.dart';

/// Placeholder for features that are not launched yet.
class ComingSoonScreen extends StatelessWidget {
  static const routeName = '/comingSoon';

  const ComingSoonScreen({super.key, this.title, this.message});

  /// Defaults to [AppLocalizations.comingSoonTitle].
  final String? title;

  /// Defaults to [AppLocalizations.storeComingSoonMessage].
  final String? message;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final resolvedTitle = title ?? l10n.comingSoonTitle;
    final resolvedMessage = message ?? l10n.storeComingSoonMessage;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: AppTheme.spacingMd),
                Text(
                  resolvedTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  resolvedMessage,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.72),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
