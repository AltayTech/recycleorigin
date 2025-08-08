import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigin/features/wallet_feature/presentation/pages/wallet_screen.dart';
import 'package:recycleorigin/core/widgets/buton_bottom.dart';
import 'package:recycleorigin/core/widgets/main_item_button.dart';

import '../../store_feature/presentation/providers/Products.dart';
import '../../../core/theme/app_theme.dart';
import '../../customer_feature/presentation/providers/authentication_provider.dart';
import '../../articles_feature/presentation/pages/article_screen.dart';
import '../../waste_feature/collect_list_screen.dart';
import '../../collect_feature/presentation/pages/waste_cart_screen.dart';
import '../../../core/widgets/custom_dialog.dart';
import '../../store_feature/presentation/screens/product_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isInit = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
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

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      _isInit = false;
      Provider.of<Products>(context, listen: false).retrieveCategory();

      Provider.of<AuthenticationProvider>(context, listen: false)
          .getTokenFromDB();

      bool _isFirstLogin =
          Provider.of<AuthenticationProvider>(context, listen: false)
              .isFirstLogin;
      if (_isFirstLogin) {
        _showLoginDialog(context);
      }
      bool _isFirstLogout =
          Provider.of<AuthenticationProvider>(context, listen: false)
              .isFirstLogout;
      if (_isFirstLogout) {
        _showLoginDialogExit(context);
        Provider.of<AuthenticationProvider>(context, listen: false)
            .isFirstLogout = false;
      }

      Provider.of<AuthenticationProvider>(context, listen: false).isFirstLogin =
          false;
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  void _showLoginDialog(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog<String>(
        context: context,
        builder: (ctx) => CustomDialog(
          title: "Welcome",
          buttonText: "accept",
          description:
              "In order to get profile information go to profile section",
          image: Image.asset('assets/images/main_page_request_ic.png'),
        ),
      );
    });
  }

  void _showLoginDialogExit(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog<String>(
        context: context,
        builder: (ctx) => CustomDialog(
          title: "Dear User",
          buttonText: "accept",
          description: "You Logout successfully",
          image: Image.asset('assets/images/main_page_request_ic.png'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // Calculate responsive sizes based on screen dimensions
    double headerHeight = deviceHeight * 0.25; // 25% of screen height
    double buttonHeight = deviceHeight * 0.08; // 8% of screen height
    double gridItemHeight =
        (deviceHeight * 0.4) / 2; // Ensure grid fits in 40% of screen

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.bg,
            AppTheme.bg.withOpacity(0.95),
            Colors.white,
          ],
        ),
      ),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: deviceHeight,
          ),
          child: Column(
            children: <Widget>[
              // Header Section with responsive sizing
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  margin: EdgeInsets.fromLTRB(12, 16, 12, 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.12),
                        blurRadius: 15,
                        spreadRadius: 3,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: headerHeight,
                      child: Stack(
                        children: [
                          FadeInImage(
                            placeholder: AssetImage('assets/images/circle.gif'),
                            image: AssetImage(
                                'assets/images/main_page_header.png'),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.1),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Welcome Text Section with reduced spacing
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Column(
                      children: [
                        Text(
                          "Welcome to Recycle Origin",
                          style: TextStyle(
                            fontSize: textScaleFactor * 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.h1,
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Make a difference for our planet",
                          style: TextStyle(
                            fontSize: textScaleFactor * 14,
                            color: AppTheme.h1.withOpacity(0.7),
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12),

              // Primary Action Button with responsive sizing
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.25),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              WasteCartScreen.routeName,
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            height: buttonHeight,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppTheme.primary, AppTheme.accent],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.recycling,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Request Collection",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: textScaleFactor * 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Services Grid with calculated sizing
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            "Our Services",
                            style: TextStyle(
                              fontSize: textScaleFactor * 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.h1,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: deviceHeight * 0.4, // Fixed height for grid
                          child: GridView.count(
                            physics: NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 1.15,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            padding: EdgeInsets.all(4),
                            children: [
                              _buildServiceCard(
                                context,
                                title: "Request",
                                icon: Icons.assignment,
                                imageUrl:
                                    'assets/images/main_page_request_ic.png',
                                onTap: () => Navigator.of(context)
                                    .pushNamed(CollectListScreen.routeName),
                                color: Colors.blue,
                              ),
                              _buildServiceCard(
                                context,
                                title: "Wallet",
                                icon: Icons.account_balance_wallet,
                                imageUrl:
                                    'assets/images/main_page_wallet_ic.png',
                                onTap: () => Navigator.of(context)
                                    .pushNamed(WalletScreen.routeName),
                                color: Colors.green,
                              ),
                              _buildServiceCard(
                                context,
                                title: "Articles",
                                icon: Icons.article,
                                imageUrl:
                                    'assets/images/main_page_paper_ic.png',
                                onTap: () => Navigator.of(context)
                                    .pushNamed(ArticlesScreen.routeName),
                                color: Colors.orange,
                              ),
                              _buildServiceCard(
                                context,
                                title: "Store",
                                icon: Icons.store,
                                imageUrl: 'assets/images/main_page_shop_ic.png',
                                onTap: () => Navigator.of(context)
                                    .pushNamed(ProductsScreen.routeName),
                                color: Colors.purple,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String imageUrl,
    required VoidCallback onTap,
    required Color color,
  }) {
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 12,
            spreadRadius: 1,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  flex: 3,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      imageUrl,
                      height: 32,
                      width: 32,
                      color: color,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Flexible(
                  flex: 2,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: textScaleFactor * 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.h1,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
