import 'package:flutter/material.dart';
import 'package:recycleorigin/l10n/app_localizations.dart';

/// Brief non-blocking feedback after a successful customer login.
void showLoginSuccessSnackBar(BuildContext context, AppLocalizations l10n) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      content: Row(
        children: <Widget>[
          Icon(
            Icons.check_circle_rounded,
            color: colorScheme.primary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.loginSuccessSnack,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onInverseSurface,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Brief non-blocking feedback after the customer signs out.
void showLogoutSuccessSnackBar(BuildContext context, AppLocalizations l10n) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      content: Row(
        children: <Widget>[
          Icon(Icons.logout_rounded, color: colorScheme.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.logoutSuccessSnack,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onInverseSurface,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
