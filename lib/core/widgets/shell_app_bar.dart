import 'package:flutter/material.dart';

import '../navigation/navigation_shell_scope.dart';
import '../theme/app_theme.dart';
import '../theme/theme_context_extensions.dart';

/// Material 3 app bar for the bottom-navigation shell (brand gradient, drawer).
///
/// Uses [AppColorsExtension] hero gradient tokens so light and dark themes
/// keep correct contrast for title and action icons.
class ShellAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ShellAppBar({
    super.key,
    required this.title,
    this.actions = const <Widget>[],
    this.scaffoldKey,
  });

  final String title;
  final List<Widget> actions;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _openDrawer(BuildContext context) {
    final key = scaffoldKey ?? NavigationShellScope.scaffoldKeyOf(context);
    (key?.currentState ?? Scaffold.maybeOf(context))?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final appBarTheme = theme.appBarTheme;
    final foreground =
        appBarTheme.foregroundColor ?? appColors.onHeroForeground;
    final titleStyle =
        appBarTheme.titleTextStyle ??
        theme.textTheme.titleLarge?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        );

    final gradientEnd = Color.lerp(
      appColors.heroGradientStart,
      appColors.heroGradientEnd,
      0.55,
    )!;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        color: foreground,
        tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        onPressed: () => _openDrawer(context),
      ),
      title: Text(title, style: titleStyle),
      centerTitle: appBarTheme.centerTitle ?? true,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      foregroundColor: foreground,
      iconTheme: appBarTheme.iconTheme,
      actionsIconTheme: appBarTheme.actionsIconTheme,
      systemOverlayStyle:
          appBarTheme.systemOverlayStyle ??
          AppTheme.systemUiOverlay(theme.brightness),
      actions: actions,
      flexibleSpace: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              appColors.heroGradientStart,
              gradientEnd,
              appColors.heroGradientEnd,
            ],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: appColors.heroGradientEnd.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.45 : 0.22,
              ),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }
}
