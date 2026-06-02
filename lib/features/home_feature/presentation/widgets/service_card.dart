import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_context_extensions.dart';

/// A single tappable card representing one home-screen service.
///
/// Adapts its accent tint from the supplied [color], keeping the
/// card surface from the theme so it works in both light and
/// (future) dark modes.
class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.title,
    this.assetPath,
    this.icon,
    required this.color,
    required this.onTap,
  }) : assert(
          (assetPath == null) != (icon == null),
          'Provide either an assetPath or an icon.',
        );

  final String title;
  final String? assetPath;
  final IconData? icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppColorsExtension>()!;

    return Semantics(
      button: true,
      label: title,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ext.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: AppTheme.cardShadow(color),
          border: Border.all(
            color: color.withValues(alpha: 0.08),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            splashColor: color.withValues(alpha: 0.08),
            highlightColor: color.withValues(alpha: 0.04),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd + 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _IconBadge(
                        assetPath: assetPath,
                        icon: icon,
                        color: color,
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: context.colors.onSurface.withValues(alpha: 0.35),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colors.onSurface,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spacingSm + 4),
                  _AccentBar(color: color),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Coloured pill that shows beneath the card title as a visual
/// accent.
class _AccentBar extends StatelessWidget {
  const _AccentBar({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        height: 4,
        width: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded icon badge with a tinted background.
class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.assetPath,
    required this.icon,
    required this.color,
  });

  final String? assetPath;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm + 6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingSm + 4),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (assetPath != null) {
      return Image.asset(
        assetPath!,
        height: 32,
        width: 32,
        color: color,
        fit: BoxFit.contain,
      );
    }
    return Icon(icon, color: color, size: 30);
  }
}
