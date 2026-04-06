import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'package:recycleorigin/l10n/l10n.dart';

/// Headline + subtitle that welcome the user on the home screen.
class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
      child: Column(
        children: [
          Text(
            context.l10n.homeWelcomeHeadline,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.h1,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.homeWelcomeSubtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: AppTheme.h1.withValues(alpha: 0.7),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
