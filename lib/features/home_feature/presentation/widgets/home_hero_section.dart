import 'package:flutter/material.dart';

import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import 'package:recycleorigin/l10n/l10n.dart';

import 'primary_action_button.dart';

/// Lightweight action surfaced under the main hero CTA.
class HeroQuickLink {
  const HeroQuickLink({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

/// High-priority hero banner for the home screen.
///
/// Focuses the primary flow (waste collection request) while still
/// surfacing secondary quick-link shortcuts for repeat actions.
/// Layout adapts from a stacked column on phones to a side-by-side
/// row on wider viewports (>= 720 dp).
class HomeHeroSection extends StatelessWidget {
  const HomeHeroSection({
    super.key,
    required this.onPrimaryActionPressed,
    required this.quickLinks,
  });

  final VoidCallback onPrimaryActionPressed;
  final List<HeroQuickLink> quickLinks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppColorsExtension>()!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingMd + 4,
        AppTheme.spacingMd,
        AppTheme.spacingMd + 4,
        AppTheme.spacingSm + 4,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ext.heroGradientStart,
              Color.lerp(
                ext.heroGradientStart,
                AppTheme.accent,
                0.45,
              )!,
              ext.heroGradientEnd,
            ],
          ),
          boxShadow: AppTheme.heroShadow(ext.heroGradientStart),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Stack(
            children: [
              const Positioned(
                top: -32,
                right: -18,
                child: _GlowOrb(size: 144),
              ),
              const Positioned(
                bottom: -52,
                left: -14,
                child: _GlowOrb(size: 124),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = AppBreakpoints.isExpandedWidth(
                      constraints.maxWidth,
                    );
                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _HeroCopy(
                              onPrimaryActionPressed: onPrimaryActionPressed,
                              quickLinks: quickLinks,
                            ),
                          ),
                          const SizedBox(
                            width: AppTheme.spacingLg,
                          ),
                          const Expanded(
                            flex: 2,
                            child: _HeroVisual(),
                          ),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeroCopy(
                          onPrimaryActionPressed: onPrimaryActionPressed,
                          quickLinks: quickLinks,
                        ),
                        const SizedBox(
                          height: AppTheme.spacingMd + 4,
                        ),
                        const _HeroVisual(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Private child widgets ────────────────────────────────────────

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.onPrimaryActionPressed,
    required this.quickLinks,
  });

  final VoidCallback onPrimaryActionPressed;
  final List<HeroQuickLink> quickLinks;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final onHero = context.appColors.onHeroForeground;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WelcomeBadge(onHero: onHero),
        const SizedBox(height: AppTheme.spacingMd),
        Text(
          context.l10n.homeWelcomeHeadline,
          style: textTheme.headlineMedium?.copyWith(
            color: onHero,
            height: 1.1,
            fontWeight: FontWeight.w800,
          ),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppTheme.spacingSm + 2),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Text(
            context.l10n.homeWelcomeSubtitle,
            style: textTheme.titleMedium?.copyWith(
              color: onHero.withValues(alpha: 0.9),
              height: 1.35,
            ),
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd + 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: PrimaryActionButton(
            onPressed: onPrimaryActionPressed,
            useLightSurface: true,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Wrap(
          spacing: AppTheme.spacingSm + 4,
          runSpacing: AppTheme.spacingSm + 4,
          children:
              quickLinks
                  .map((item) => _HeroQuickLinkChip(item: item, onHero: onHero))
                  .toList(),
        ),
      ],
    );
  }
}

class _WelcomeBadge extends StatelessWidget {
  const _WelcomeBadge({required this.onHero});

  final Color onHero;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm + 4,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: onHero.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(
          color: onHero.withValues(alpha: 0.28),
        ),
      ),
      child: Text(
        context.l10n.welcome,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: onHero,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
      ),
    );
  }
}

class _HeroQuickLinkChip extends StatelessWidget {
  const _HeroQuickLinkChip({required this.item, required this.onHero});

  final HeroQuickLink item;
  final Color onHero;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: item.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          child: Ink(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: onHero.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border: Border.all(
                color: onHero.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, color: onHero, size: 18),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: onHero,
                        fontWeight: FontWeight.w600,
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

class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    final onHero = context.appColors.onHeroForeground;
    return AspectRatio(
      aspectRatio: 1.06,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: onHero.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppTheme.spacingLg),
          border: Border.all(
            color: onHero.withValues(alpha: 0.18),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                child: Image.asset(
                  'assets/images/main_page_header.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      AppTheme.radiusMd,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        onHero.withValues(alpha: 0.02),
                        Colors.black.withValues(alpha: 0.18),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.colors.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(
                      AppTheme.radiusSm + 6,
                    ),
                  ),
                  child: Icon(
                    Icons.eco_rounded,
                    color: AppTheme.primary,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.appColors.onHeroForeground.withValues(alpha: 0.08),
        ),
      ),
    );
  }
}
