import 'package:flutter/material.dart';
import 'package:recycleorigin/core/navigation/navigation_shell_scope.dart';

import 'package:recycleorigin/core/widgets/main_drawer.dart';

/// App bar leading for screens that use [MainDrawer]: shows a platform-aware
/// back control when this route can pop, otherwise opens the drawer.
class DrawerOrBackLeading extends StatelessWidget {
  const DrawerOrBackLeading({super.key, this.iconColor, this.scaffoldKey});

  /// When set, overrides [IconTheme] for both back and menu icons.
  final Color? iconColor;

  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  Widget build(BuildContext context) {
    final nav = Navigator.of(context);
    final color = iconColor ?? IconTheme.of(context).color;
    if (nav.canPop()) {
      return BackButton(
        color: color,
        onPressed: () {
          nav.maybePop();
        },
      );
    }
    final shellKey = scaffoldKey ?? NavigationShellScope.scaffoldKeyOf(context);
    return IconButton(
      icon: const Icon(Icons.menu_rounded),
      color: color,
      tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
      onPressed: () {
        final state = shellKey?.currentState ?? Scaffold.maybeOf(context);
        state?.openDrawer();
      },
    );
  }
}

/// Attach [MainDrawer] only when this route is not stacked on another screen.
///
/// Avoids pairing a global drawer with a back affordance on pushed routes.
Widget? mainDrawerIfRootRoute(BuildContext context) {
  if (NavigationShellScope.maybeOf(context) != null) return null;
  if (Navigator.of(context).canPop()) return null;
  return Theme(
    data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
    child: const MainDrawer(),
  );
}
