import 'package:flutter/material.dart';
import 'package:recycleorigin/core/models/customer.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/core/utils/app_info_service.dart';
import 'package:recycleorigin/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigin/features/support_tickets/presentation/screens/support_tickets_list_screen.dart';

import '../../features/auth_feature/presentation/bloc/auth_bloc.dart';
import '../../features/guid_feature/presentation/pages/guide_screen.dart';
import '../../features/auth_feature/presentation/bloc/auth_state.dart';
import '../../features/auth_feature/presentation/screens/login_screen.dart';
import '../../features/customer_feature/presentation/screens/profile_screen.dart';
import '../../features/store_feature/presentation/screens/cart_screen.dart';
import '../../features/store_feature/presentation/screens/product_screen.dart';
import '../screens/navigation_bottom_screen.dart';
import '../screens/settings_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../l10n/l10n.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  static const _horizontalPadding = 14.0;
  static const _tileRadius = 16.0;
  String _appVersion = 'v1.0.0';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final appInfo = AppInfoService.instance;
      if (!appInfo.isInitialized) {
        await appInfo.initialize();
      }
      if (mounted) {
        setState(() {
          _appVersion = appInfo.shortVersion;
        });
      }
    } catch (e) {
      // Fallback to default version if loading fails
      if (mounted) {
        setState(() {
          _appVersion = 'v1.0.0';
        });
      }
    }
  }

  Widget _buildUserHeader({
    required bool isAuthenticated,
    required Customer? customer,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final extension = theme.extension<AppColorsExtension>();
    final gradientStart = extension?.heroGradientStart ?? colors.primary;
    final gradientEnd = extension?.heroGradientEnd ?? AppTheme.primary;

    final firstName = customer?.personalData.first_name ?? '';
    final lastName = customer?.personalData.last_name ?? '';
    final email = customer?.personalData.email ?? '';
    final displayName = firstName.isNotEmpty || lastName.isNotEmpty
        ? '$firstName $lastName'.trim()
        : email.isNotEmpty
            ? email
            : context.l10n.guestUserLabel;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[gradientStart, gradientEnd],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                    width: 1.2,
                  ),
                ),
                child: isAuthenticated &&
                        (firstName.isNotEmpty || lastName.isNotEmpty)
                    ? Center(
                        child: Text(
                          _nameInitials(displayName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAuthenticated
                          ? displayName
                          : context.l10n.recycleorigin,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAuthenticated && email.isNotEmpty
                          ? email
                          : context.l10n.settingsScreenIntro,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.86),
                        fontSize: 12,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickActionChip(
                icon: Icons.settings_rounded,
                label: context.l10n.settingsTitle,
                onTap: () => _navigateToRoute(SettingsScreen.routeName),
              ),
              _QuickActionChip(
                icon: isAuthenticated
                    ? Icons.person_rounded
                    : Icons.login_rounded,
                label:
                    isAuthenticated ? context.l10n.profile : context.l10n.login,
                onTap: () => _navigateToRoute(
                  isAuthenticated
                      ? ProfileScreen.routeName
                      : LoginScreen.routeName,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _nameInitials(String name) {
    final tokens = name.trim().split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
    final initials = tokens.take(2).map((t) => t[0]).join().toUpperCase();
    return initials.isEmpty ? 'U' : initials;
  }

  Widget _buildSectionTitle(String text) {
    final textStyle = Theme.of(context).textTheme.labelLarge;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        text,
        style: textStyle?.copyWith(
          color: Colors.white.withValues(alpha: 0.84),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildDestinationTile({
    required _DrawerDestination destination,
    required bool selected,
    required bool destructive,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    final selectedColor = colors.surface.withValues(alpha: 0.92);
    final defaultFg = Colors.white.withValues(alpha: 0.94);
    final destructiveFg = colors.errorContainer;
    final foreground = destructive ? destructiveFg : defaultFg;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: 2,
      ),
      child: Material(
        color: selected ? selectedColor : Colors.transparent,
        borderRadius: BorderRadius.circular(_tileRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(_tileRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(
                  destination.icon,
                  size: 22,
                  color: selected
                      ? colors.primary
                      : (destructive ? destructiveFg : foreground),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    destination.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? colors.primary
                          : (destructive ? destructiveFg : foreground),
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.primary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToRoute(String routeName, {Object? arguments}) async {
    try {
      Navigator.of(context).pop();
      if (arguments != null) {
        await Navigator.of(context).pushNamed(routeName, arguments: arguments);
      } else {
        await Navigator.of(context).pushNamed(routeName);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${context.l10n.navigationErrorPrefix}${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      final l10n = context.l10n;
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.signOutDialogTitle,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          content: Text(
            l10n.signOutDialogMessage,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancelLabel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(
                l10n.signOutConfirmButton,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );

      if (shouldLogout == true && mounted) {
        // Reset customer data
        context.read<CustomerInfoBloc>().customer =
            context.read<CustomerInfoBloc>().customer_zero;

        // Remove authentication token
        await context.read<AuthBloc>().removeToken();

        // Set first logout flag
        context.read<AuthBloc>().isFirstLogout = true;

        // Navigate to home
        if (mounted) {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamedAndRemoveUntil(
            NavigationBottomScreen.routeName,
            (Route<dynamic> route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.l10n.signOutErrorPrefix}${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRouteName = ModalRoute.of(context)?.settings.name ?? '';
    final l10n = context.l10n;

    return Drawer(
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              AppTheme.primary,
              AppTheme.primary.withValues(alpha: 0.92),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  final customerProvider = context.watch<CustomerInfoBloc>();
                  return _buildUserHeader(
                    isAuthenticated: authState.isAuth,
                    customer:
                        authState.isAuth ? customerProvider.customer : null,
                  );
                },
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildSectionTitle(l10n.home),
                    _buildDestinationTile(
                      destination: _DrawerDestination(
                        icon: Icons.home_rounded,
                        title: l10n.home,
                        routeName: NavigationBottomScreen.routeName,
                      ),
                      selected:
                          currentRouteName == NavigationBottomScreen.routeName,
                      destructive: false,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          NavigationBottomScreen.routeName,
                          (Route<dynamic> route) => false,
                        );
                      },
                    ),
                    _buildDestinationTile(
                      destination: _DrawerDestination(
                        icon: Icons.settings_rounded,
                        title: l10n.settingsTitle,
                        routeName: SettingsScreen.routeName,
                      ),
                      selected: currentRouteName == SettingsScreen.routeName,
                      destructive: false,
                      onTap: () => _navigateToRoute(SettingsScreen.routeName),
                    ),
                    _buildSectionTitle(l10n.store),
                    _buildDestinationTile(
                      destination: _DrawerDestination(
                        icon: Icons.store_rounded,
                        title: l10n.store,
                        routeName: ProductsScreen.routeName,
                      ),
                      selected: currentRouteName == ProductsScreen.routeName,
                      destructive: false,
                      onTap: () => _navigateToRoute(
                        ProductsScreen.routeName,
                        arguments: 0,
                      ),
                    ),
                    _buildDestinationTile(
                      destination: _DrawerDestination(
                        icon: Icons.shopping_cart_rounded,
                        title: l10n.shoppingCartLabel,
                        routeName: CartScreen.routeName,
                      ),
                      selected: currentRouteName == CartScreen.routeName,
                      destructive: false,
                      onTap: () => _navigateToRoute(CartScreen.routeName),
                    ),
                    _buildSectionTitle(l10n.supportHelpLabel),
                    _buildDestinationTile(
                      destination: _DrawerDestination(
                        icon: Icons.menu_book_rounded,
                        title: l10n.guideTitle,
                        routeName: GuideScreen.routeName,
                      ),
                      selected: currentRouteName == GuideScreen.routeName,
                      destructive: false,
                      onTap: () => _navigateToRoute(GuideScreen.routeName),
                    ),
                    _buildDestinationTile(
                      destination: _DrawerDestination(
                        icon: Icons.support_agent_rounded,
                        title: l10n.supportHelpLabel,
                        routeName: SupportTicketsListScreen.routeName,
                      ),
                      selected: currentRouteName ==
                          SupportTicketsListScreen.routeName,
                      destructive: false,
                      onTap: () =>
                          _navigateToRoute(SupportTicketsListScreen.routeName),
                    ),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        return Column(
                          children: [
                            _buildSectionTitle(
                                authState.isAuth ? l10n.profile : l10n.login),
                            _buildDestinationTile(
                              destination: _DrawerDestination(
                                icon: authState.isAuth
                                    ? Icons.person_rounded
                                    : Icons.login_rounded,
                                title: authState.isAuth
                                    ? l10n.profile
                                    : l10n.login,
                                routeName: authState.isAuth
                                    ? ProfileScreen.routeName
                                    : LoginScreen.routeName,
                              ),
                              selected: currentRouteName ==
                                  (authState.isAuth
                                      ? ProfileScreen.routeName
                                      : LoginScreen.routeName),
                              destructive: false,
                              onTap: () => _navigateToRoute(
                                authState.isAuth
                                    ? ProfileScreen.routeName
                                    : LoginScreen.routeName,
                              ),
                            ),
                            if (authState.isAuth)
                              _buildDestinationTile(
                                destination: _DrawerDestination(
                                  icon: Icons.logout_rounded,
                                  title: l10n.logout,
                                  routeName: '',
                                ),
                                selected: false,
                                destructive: true,
                                onTap: _handleLogout,
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.22),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white.withValues(alpha: 0.66),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _appVersion,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.66),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerDestination {
  const _DrawerDestination({
    required this.icon,
    required this.title,
    required this.routeName,
  });

  final IconData icon;
  final String title;
  final String routeName;
}
