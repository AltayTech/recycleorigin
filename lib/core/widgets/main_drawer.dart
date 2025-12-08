import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigin/core/models/customer.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/core/utils/app_info_service.dart';
import 'package:recycleorigin/features/customer_feature/presentation/providers/customer_info_provider.dart';
import 'package:recycleorigin/features/meassage_feature/presentation/pages/messages_screen.dart';

import '../../features/customer_feature/presentation/providers/authentication_provider.dart';
import '../../features/customer_feature/presentation/screens/login_screen.dart';
import '../../features/customer_feature/presentation/screens/profile_screen.dart';
import '../../features/store_feature/presentation/screens/cart_screen.dart';
import '../../features/store_feature/presentation/screens/product_screen.dart';
import '../screens/navigation_bottom_screen.dart';

/// Production-grade drawer menu with Material Design 3 styling
///
/// Features:
/// - Clean, modern UI with proper visual hierarchy
/// - User profile section with avatar and name when authenticated
/// - Smooth animations and transitions
/// - Organized menu sections with proper spacing
/// - Accessibility support
/// - Responsive design
/// - Error handling
/// - Theme-aware colors
class MainDrawer extends StatefulWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Constants for maintainability
  static const double _headerPadding = 24.0;
  static const double _itemPadding = 20.0;
  static const double _itemVerticalPadding = 16.0;
  static const double _iconSize = 24.0;
  static const double _avatarSize = 64.0;
  static const double _logoSize = 80.0;
  static const double _dividerHeight = 1.0;
  static const double _spacingSmall = 8.0;
  static const double _spacingMedium = 16.0;
  static const double _spacingLarge = 24.0;
  static const Duration _animationDuration = Duration(milliseconds: 300);
  static const String _appName = 'Recycle Origin';

  // App version will be loaded dynamically
  String _appVersion = 'v1.0.0';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.2, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward();
    _loadAppVersion();
  }

  /// Loads app version dynamically from AppInfoService
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Builds a drawer menu item with proper styling and interactions
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
    bool isSelected = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textColor = isLogout
        ? Colors.red.shade300
        : isSelected
            ? colorScheme.onSurface
            : Colors.white;
    final iconColor = isLogout
        ? Colors.red.shade300
        : isSelected
            ? colorScheme.primary
            : Colors.white;
    final backgroundColor =
        isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: _itemPadding,
            vertical: _spacingSmall / 2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: _itemPadding,
            vertical: _itemVerticalPadding,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: _iconSize,
              ),
              const SizedBox(width: _itemPadding),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    letterSpacing: 0.15,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.chevron_right_rounded,
                  color: iconColor,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the user profile header section
  Widget _buildUserHeader({
    required bool isAuthenticated,
    required Customer? customer,
  }) {
    if (!isAuthenticated) {
      return _buildAppHeader();
    }

    final firstName = customer?.personalData.first_name ?? '';
    final lastName = customer?.personalData.last_name ?? '';
    final email = customer?.personalData.email ?? '';
    final displayName = firstName.isNotEmpty || lastName.isNotEmpty
        ? '$firstName $lastName'.trim()
        : email.isNotEmpty
            ? email
            : 'User';

    return Container(
      padding: const EdgeInsets.all(_headerPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            AppTheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          // User Avatar
          Container(
            height: _avatarSize,
            width: _avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: firstName.isNotEmpty || lastName.isNotEmpty
                ? Center(
                    child: Text(
                      displayName
                          .split(' ')
                          .map((n) => n.isNotEmpty ? n[0] : '')
                          .join('')
                          .toUpperCase()
                          .substring(
                              0, displayName.split(' ').length > 1 ? 2 : 1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
          ),
          const SizedBox(height: _spacingMedium),
          // User Name
          Text(
            displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (email.isNotEmpty && email != displayName) ...[
            const SizedBox(height: _spacingSmall / 2),
            Text(
              email,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the app header (when not authenticated)
  Widget _buildAppHeader() {
    return Container(
      padding: const EdgeInsets.all(_headerPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            AppTheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          // App Logo
          Container(
            height: _logoSize,
            width: _logoSize,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.recycling_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: _spacingMedium),
          // App Name
          Text(
            _appName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Handles navigation with proper error handling
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
            content: Text('Navigation error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Handles logout with confirmation dialog
  Future<void> _handleLogout() async {
    try {
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Sign Out',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );

      if (shouldLogout == true && mounted) {
        // Reset customer data
        Provider.of<CustomerInfoProvider>(context, listen: false).customer =
            Provider.of<CustomerInfoProvider>(context, listen: false)
                .customer_zero;

        // Remove authentication token
        await Provider.of<AuthenticationProvider>(context, listen: false)
            .removeToken();

        // Set first logout flag
        Provider.of<AuthenticationProvider>(context, listen: false)
            .isFirstLogout = true;

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
            content: Text('Error signing out: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primary,
              AppTheme.primary.withOpacity(0.95),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section (User Profile or App Logo)
              Consumer2<AuthenticationProvider, CustomerInfoProvider>(
                builder: (context, authProvider, customerProvider, _) {
                  return _buildUserHeader(
                    isAuthenticated: authProvider.isAuth,
                    customer:
                        authProvider.isAuth ? customerProvider.customer : null,
                  );
                },
              ),

              // Divider
              Container(
                height: _dividerHeight,
                margin: const EdgeInsets.symmetric(
                  horizontal: _itemPadding,
                  vertical: _spacingMedium,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(_dividerHeight / 2),
                ),
              ),

              // Menu Items Section
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // Home
                          _buildDrawerItem(
                            icon: Icons.home_rounded,
                            title: 'Home',
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                NavigationBottomScreen.routeName,
                                (Route<dynamic> route) => false,
                              );
                            },
                          ),

                          // Store
                          _buildDrawerItem(
                            icon: Icons.store_rounded,
                            title: 'Store',
                            onTap: () => _navigateToRoute(
                              ProductsScreen.routeName,
                              arguments: 0,
                            ),
                          ),

                          // Shopping Cart
                          _buildDrawerItem(
                            icon: Icons.shopping_cart_rounded,
                            title: 'Shopping Cart',
                            onTap: () => _navigateToRoute(CartScreen.routeName),
                          ),

                          // Support & Help
                          _buildDrawerItem(
                            icon: Icons.support_agent_rounded,
                            title: 'Support & Help',
                            onTap: () =>
                                _navigateToRoute(MessageScreen.routeName),
                          ),

                          const SizedBox(height: _spacingSmall),

                          // Profile/Login Item
                          Consumer<AuthenticationProvider>(
                            builder: (context, authProvider, _) {
                              return _buildDrawerItem(
                                icon: authProvider.isAuth
                                    ? Icons.person_rounded
                                    : Icons.login_rounded,
                                title:
                                    authProvider.isAuth ? 'Profile' : 'Sign In',
                                onTap: () {
                                  Navigator.of(context).pop();
                                  if (authProvider.isAuth) {
                                    Navigator.of(context)
                                        .pushNamed(ProfileScreen.routeName);
                                  } else {
                                    Navigator.of(context)
                                        .pushNamed(LoginScreen.routeName);
                                  }
                                },
                              );
                            },
                          ),

                          // Logout (only if authenticated)
                          Consumer<AuthenticationProvider>(
                            builder: (context, authProvider, _) {
                              if (!authProvider.isAuth) {
                                return const SizedBox.shrink();
                              }
                              return _buildDrawerItem(
                                icon: Icons.logout_rounded,
                                title: 'Sign Out',
                                isLogout: true,
                                onTap: _handleLogout,
                              );
                            },
                          ),

                          const SizedBox(height: _spacingLarge),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Footer Section
              Container(
                padding: const EdgeInsets.all(_itemPadding),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                      width: _dividerHeight,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white.withOpacity(0.6),
                      size: 16,
                    ),
                    const SizedBox(width: _spacingSmall),
                    Text(
                      _appVersion,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
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
