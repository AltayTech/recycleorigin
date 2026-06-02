import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import 'package:recycleorigin/l10n/l10n.dart';

/// Full-width CTA that navigates to the waste-collection request
/// flow.
///
/// Two visual modes:
/// - **Light surface** (`useLightSurface: true`) — white
///   background with green text, used inside the gradient hero
///   banner.
/// - **Gradient surface** (default) — primary-to-accent gradient
///   with white text, used standalone.
class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    super.key,
    required this.onPressed,
    this.useLightSurface = false,
  });

  final VoidCallback onPressed;
  final bool useLightSurface;

  @override
  Widget build(BuildContext context) {
    final onHero = context.appColors.onHeroForeground;
    final fg = useLightSurface ? AppTheme.primary : onHero;
    final secondaryBg = useLightSurface
        ? AppTheme.primary.withValues(alpha: 0.1)
        : onHero.withValues(alpha: 0.16);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: useLightSurface ? 0 : AppTheme.spacingMd + 4,
        vertical: AppTheme.spacingXs,
      ),
      child: Semantics(
        button: true,
        label: context.l10n.requestCollectionHeroTitle,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: useLightSurface ? context.colors.surface : null,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm + 6),
            boxShadow: [
              BoxShadow(
                color: useLightSurface
                    ? context.colors.shadow.withValues(alpha: 0.12)
                    : AppTheme.primary.withValues(alpha: 0.3),
                blurRadius: useLightSurface ? 20 : 16,
                spreadRadius: useLightSurface ? 0 : 2,
                offset: const Offset(0, 10),
              ),
            ],
            gradient: useLightSurface
                ? null
                : const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.accent],
                  ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(
                AppTheme.radiusSm + 6,
              ),
              splashColor: fg.withValues(alpha: 0.08),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: AppTheme.spacingMd + 2,
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: secondaryBg,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSm + 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.recycling_rounded,
                            color: fg,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          context.l10n.requestCollectionHeroTitle,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: fg,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: fg,
                        size: 24,
                      ),
                      const SizedBox(
                        width: AppTheme.spacingMd + 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
