import 'package:flutter/material.dart';

/// Exposes the bottom-navigation shell [ScaffoldState] to tab children so
/// they can open the shared drawer without duplicating [MainDrawer].
class NavigationShellScope extends InheritedWidget {
  const NavigationShellScope({
    super.key,
    required this.scaffoldKey,
    required super.child,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;

  static NavigationShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NavigationShellScope>();
  }

  static GlobalKey<ScaffoldState>? scaffoldKeyOf(BuildContext context) {
    return maybeOf(context)?.scaffoldKey;
  }

  /// True when this widget is a tab inside [NavigationBottomScreen].
  static bool isActive(BuildContext context) {
    return maybeOf(context) != null;
  }

  @override
  bool updateShouldNotify(NavigationShellScope oldWidget) {
    return scaffoldKey != oldWidget.scaffoldKey;
  }
}
