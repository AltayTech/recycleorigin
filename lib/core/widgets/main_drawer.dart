import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/features/Charities/presentation/pages/charity_screen.dart';
import 'package:recycleorigin/features/customer_feature/presentation/providers/customer_info_provider.dart';
import 'package:recycleorigin/features/meassage_feature/presentation/pages/messages_screen.dart';

import '../../features/customer_feature/presentation/providers/authentication_provider.dart';
import '../../features/customer_feature/presentation/screens/login_screen.dart';
import '../../features/customer_feature/presentation/screens/profile_screen.dart';
import '../../features/store_feature/presentation/screens/cart_screen.dart';
import '../../features/store_feature/presentation/screens/product_screen.dart';
import '../screens/navigation_bottom_screen.dart';

/// Modern drawer menu with improved design and user experience
/// Features:
/// - Clean Material Design 3 styling
/// - User profile section with avatar
/// - Organized menu sections
/// - Smooth animations and interactions
/// - Better visual hierarchy
/// - Responsive design
class MainDrawer extends StatefulWidget {
  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
    bool isLogout = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isLogout ? Colors.red.shade300 : Colors.white,
                size: 24,
              ),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isLogout ? Colors.red.shade300 : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;

    return Drawer(
      child: Container(
        color: Color(0xFF2E7D32),
        child: SafeArea(
          child: Column(
            children: [
              // Minimal Header
              Container(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    // App Logo
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.recycling,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),

                    SizedBox(height: 16),

                    Text(
                      "Recycle Origin",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Container(
                height: 1,
                margin: EdgeInsets.symmetric(horizontal: 20),
                color: Colors.white.withOpacity(0.2),
              ),

              SizedBox(height: 8),

              // Menu Items
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildDrawerItem(
                        icon: Icons.home_rounded,
                        title: "Home",
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            NavigationBottomScreen.routeName,
                            (Route<dynamic> route) => false,
                          );
                        },
                      ),

                      _buildDrawerItem(
                        icon: Icons.store_rounded,
                        title: "Store",
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed(
                            ProductsScreen.routeName,
                            arguments: 0,
                          );
                        },
                      ),

                      _buildDrawerItem(
                        icon: Icons.shopping_cart_rounded,
                        title: "Shopping Cart",
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed(CartScreen.routeName);
                        },
                      ),

                      _buildDrawerItem(
                        icon: Icons.support_agent_rounded,
                        title: "Support & Help",
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context)
                              .pushNamed(MessageScreen.routeName);
                        },
                      ),

                      // Profile/Login Item
                      Consumer<AuthenticationProvider>(
                        builder: (_, auth, ch) => _buildDrawerItem(
                          icon: auth.isAuth
                              ? Icons.person_rounded
                              : Icons.login_rounded,
                          title: auth.isAuth ? "Profile" : "Sign In",
                          onTap: () {
                            Navigator.of(context).pop();
                            auth.isAuth
                                ? Navigator.of(context)
                                    .pushNamed(ProfileScreen.routeName)
                                : Navigator.of(context)
                                    .pushNamed(LoginScreen.routeName);
                          },
                        ),
                      ),

                      // Logout (only if authenticated)
                      Consumer<AuthenticationProvider>(
                        builder: (_, auth, ch) => auth.isAuth
                            ? _buildDrawerItem(
                                icon: Icons.logout_rounded,
                                title: "Sign Out",
                                isLogout: true,
                                onTap: () async {
                                  // Show simple confirmation
                                  bool? shouldLogout = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Sign Out"),
                                        content: Text("Are you sure?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: Text("Sign Out",
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (shouldLogout == true) {
                                    Provider.of<CustomerInfoProvider>(context,
                                                listen: false)
                                            .customer =
                                        Provider.of<CustomerInfoProvider>(
                                                context,
                                                listen: false)
                                            .customer_zero;
                                    await Provider.of<AuthenticationProvider>(
                                            context,
                                            listen: false)
                                        .removeToken();
                                    Provider.of<AuthenticationProvider>(context,
                                            listen: false)
                                        .isFirstLogout = true;
                                    Navigator.of(context).pop();
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                      NavigationBottomScreen.routeName,
                                      (Route<dynamic> route) => false,
                                    );
                                  }
                                },
                              )
                            : SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),

              // Minimal Footer
              Container(
                padding: EdgeInsets.all(20),
                child: Text(
                  "v1.1.8",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
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
