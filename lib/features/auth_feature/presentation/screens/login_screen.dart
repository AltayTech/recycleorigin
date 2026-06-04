import 'package:flutter/material.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/core/theme/theme_context_extensions.dart';
import 'package:recycleorigin/core/widgets/drawer_or_back_leading.dart';
import 'package:recycleorigin/features/auth_feature/presentation/screens/auth_card.dart';
import 'package:recycleorigin/l10n/l10n.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final l10n = context.l10n;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final onHero = appColors.onHeroForeground;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      drawer: mainDrawerIfRootRoute(context),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              appColors.heroGradientStart,
              Color.lerp(
                appColors.heroGradientStart,
                appColors.heroGradientEnd,
                0.5,
              )!,
              appColors.heroGradientEnd,
            ],
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.12),
                Colors.black.withValues(alpha: 0.45),
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final minChildHeight = constraints.maxHeight.isFinite
                        ? constraints.maxHeight
                        : 0.0;
                    return SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: AppTheme.spacingMd,
                        right: AppTheme.spacingMd,
                        top: AppTheme.spacingLg,
                        bottom: AppTheme.spacingLg + bottomInset,
                      ),
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: minChildHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.recycleorigin,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontFamily: 'BFarnaz',
                                fontWeight: FontWeight.w900,
                                color: onHero,
                                shadows: [
                                  Shadow(
                                    blurRadius: 14,
                                    color: Colors.black.withValues(alpha: 0.35),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppTheme.spacingXl),
                            Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 420),
                                child: Card(
                                  elevation: 8,
                                  shadowColor: AppTheme.primary.withValues(
                                    alpha: 0.28,
                                  ),
                                  color: appColors.cardBackground,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusMd,
                                    ),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(
                                      AppTheme.spacingMd,
                                    ),
                                    child: AuthCard(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Material(
                    type: MaterialType.transparency,
                    child: Builder(
                      builder: (ctx) {
                        final nav = Navigator.of(ctx);
                        final style = IconButton.styleFrom(
                          backgroundColor: onHero.withValues(alpha: 0.14),
                        );
                        if (nav.canPop()) {
                          return IconButton(
                            tooltip:
                                MaterialLocalizations.of(ctx).backButtonTooltip,
                            onPressed: () => nav.maybePop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                            color: onHero,
                            style: style,
                          );
                        }
                        return IconButton(
                          tooltip: l10n.authOpenMenuTooltip,
                          onPressed: () => Scaffold.of(ctx).openDrawer(),
                          icon: const Icon(Icons.menu_rounded),
                          color: onHero,
                          style: style,
                        );
                      },
                    ),
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
