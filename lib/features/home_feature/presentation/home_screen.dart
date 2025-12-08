import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_dialog.dart';
import '../../articles_feature/presentation/pages/article_screen.dart';
import '../../collect_feature/presentation/pages/waste_cart_screen.dart';
import '../../customer_feature/presentation/providers/authentication_provider.dart';
import '../../store_feature/presentation/providers/Products.dart';
import '../../store_feature/presentation/screens/product_screen.dart';
import '../../wallet_feature/presentation/pages/wallet_screen.dart';
import '../../waste_feature/collect_list_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();

    // Defer initialization logic to after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  void _initData() {
    if (!mounted) return;

    // Fetch initial data
    final productsProvider = Provider.of<Products>(context, listen: false);
    productsProvider.retrieveCategory();

    final authProvider = Provider.of<AuthenticationProvider>(
      context,
      listen: false,
    );
    authProvider.getTokenFromDB();

    if (authProvider.isFirstLogin) {
      _showLoginDialog(context);
      authProvider.isFirstLogin = false;
    }

    if (authProvider.isFirstLogout) {
      _showLoginDialogExit(context);
      authProvider.isFirstLogout = false;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showLoginDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (ctx) => CustomDialog(
        title: "Welcome",
        buttonText: "accept",
        description:
            "In order to get profile information go to profile section",
        image: Image.asset('assets/images/main_page_request_ic.png'),
      ),
    );
  }

  void _showLoginDialogExit(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (ctx) => CustomDialog(
        title: "Dear User",
        buttonText: "accept",
        description: "You Logout successfully",
        image: Image.asset('assets/images/main_page_request_ic.png'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.bg, AppTheme.bg.withOpacity(0.95), Colors.white],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Header Section
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: const _HomeHeader(),
                ),
              ),

              // 2. Welcome Message
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: const _WelcomeSection(),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // 3. Main Action Button
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: const _PrimaryActionButton(),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // 4. Services Title
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Our Services",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppTheme.h1,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ) ??
                            TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.h1,
                            ),
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // 5. Services Grid
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: const _ServicesGrid(),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Responsive height
    final double height = MediaQuery.of(context).size.height * 0.25;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/main_page_header.png',
              fit: BoxFit.cover,
            ),
            // Gradient Overlay for text legibility if needed
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.1)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          Text(
            "Welcome to Recycle Origin",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.h1,
                      letterSpacing: 0.3,
                    ) ??
                TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.h1,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            "Make a difference for our planet",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.h1.withOpacity(0.7),
                      fontWeight: FontWeight.w400,
                    ) ??
                TextStyle(fontSize: 14, color: AppTheme.h1.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.3),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
          gradient: LinearGradient(
            colors: [AppTheme.primary, AppTheme.accent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(WasteCartScreen.routeName);
            },
            borderRadius: BorderRadius.circular(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.recycling, color: Colors.white, size: 26),
                SizedBox(width: 12),
                Text(
                  "Request Collection",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
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

class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 1.1,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      padding: EdgeInsets.zero,
      children: [
        _ServiceCard(
          title: "Request",
          icon: Icons.assignment, // Fallback icon
          imageUrl: 'assets/images/main_page_request_ic.png',
          onTap: () =>
              Navigator.of(context).pushNamed(CollectListScreen.routeName),
          color: Colors.blue,
        ),
        _ServiceCard(
          title: "Wallet",
          icon: Icons.account_balance_wallet,
          imageUrl: 'assets/images/main_page_wallet_ic.png',
          onTap: () => Navigator.of(context).pushNamed(WalletScreen.routeName),
          color: Colors.green,
        ),
        _ServiceCard(
          title: "Articles",
          icon: Icons.article,
          imageUrl: 'assets/images/main_page_paper_ic.png',
          onTap: () =>
              Navigator.of(context).pushNamed(ArticlesScreen.routeName),
          color: Colors.orange,
        ),
        _ServiceCard(
          title: "Store",
          icon: Icons.store,
          imageUrl: 'assets/images/main_page_shop_ic.png',
          onTap: () =>
              Navigator.of(context).pushNamed(ProductsScreen.routeName),
          color: Colors.purple,
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String imageUrl;
  final VoidCallback onTap;
  final Color color;

  const _ServiceCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.imageUrl,
    required this.onTap,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.08), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.asset(
                    imageUrl,
                    height: 36,
                    width: 36,
                    color: color,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.h1,
                          ) ??
                      TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.h1,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
