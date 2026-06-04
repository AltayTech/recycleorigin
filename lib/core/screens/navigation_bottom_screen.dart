import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../features/customer_feature/presentation/screens/profile_screen.dart';
import '../../features/home_feature/presentation/home_screen.dart';
import '../../features/store_feature/presentation/screens/product_screen.dart';
import '../../features/waste_feature/collect_list_screen.dart';
import '../../l10n/app_localizations.dart';
import '../navigation/navigation_shell_scope.dart';
import '../theme/theme_context_extensions.dart';
import '../widgets/main_drawer.dart';
import '../widgets/shell_app_bar.dart';
import '../widgets/shell_store_cart_action.dart';

/// Main shell: shared drawer, bottom navigation, and tab bodies.
class NavigationBottomScreen extends StatefulWidget {
  static const routeName = '/NBS';

  const NavigationBottomScreen({super.key});

  @override
  State<NavigationBottomScreen> createState() => _NavigationBottomScreenState();
}

class _NavigationBottomScreenState extends State<NavigationBottomScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;
  late DateTime _lastBackPress;
  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _lastBackPress = DateTime.now().subtract(const Duration(seconds: 3));
    _tabs = <Widget>[
      const HomeScreen(),
      const CollectListScreen(),
      ProductsScreen(),
      const ProfileScreen(),
    ];
  }

  void _onDestinationSelected(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  Future<void> _completePopIfAllowed() async {
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.pop(context);
      return;
    }
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return;
    }
    final allowPop = await _onWillPop();
    if (!mounted) return;
    if (allowPop) {
      Navigator.of(context).pop();
    }
  }

  Future<bool> _onWillPop() async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    if (now.difference(_lastBackPress) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      FToast().showToast(
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.inverseSurface.withValues(alpha: 0.84),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              l10n.forexit,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.onInverseSurface,
                fontSize: MediaQuery.textScalerOf(context).scale(13),
              ),
            ),
          ),
        ),
      );
      return false;
    }
    return true;
  }

  String _titleForTab(AppLocalizations l10n) {
    return switch (_selectedIndex) {
      1 => l10n.collectRequestListAppBarTitle,
      2 => l10n.storeProductsAppBarTitle,
      _ => l10n.profile,
    };
  }

  List<Widget> _actionsForTab() {
    if (_selectedIndex == 2) {
      return const <Widget>[ShellStoreCartAction()];
    }
    return const <Widget>[];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appColors = context.appColors;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        unawaited(_completePopIfAllowed());
      },
      child: NavigationShellScope(
        scaffoldKey: _scaffoldKey,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: _selectedIndex == 0
              ? null
              : ShellAppBar(
                  title: _titleForTab(l10n),
                  scaffoldKey: _scaffoldKey,
                  actions: _actionsForTab(),
                ),
          drawer: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: appColors.scaffoldBackground.withValues(
                alpha: 0.96,
              ),
            ),
            child: const MainDrawer(),
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: _tabs,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded),
                label: l10n.home,
              ),
              NavigationDestination(
                icon: const Icon(Icons.inventory_2_outlined),
                selectedIcon: const Icon(Icons.inventory_2_rounded),
                label: l10n.navMyRequestsTab,
              ),
              NavigationDestination(
                icon: const Icon(Icons.storefront_outlined),
                selectedIcon: const Icon(Icons.storefront_rounded),
                label: l10n.store,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline_rounded),
                selectedIcon: const Icon(Icons.person_rounded),
                label: l10n.profile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
