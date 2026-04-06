import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_dialog.dart';
import '../../articles_feature/presentation/pages/article_screen.dart';
import '../../collect_feature/presentation/pages/waste_cart_screen.dart';
import '../../auth_feature/presentation/bloc/auth_bloc.dart';
import '../../auth_feature/presentation/bloc/auth_state.dart';
import '../../store_feature/presentation/bloc/products_bloc.dart';
import '../../store_feature/presentation/screens/product_screen.dart';
import '../../wallet_feature/presentation/pages/wallet_screen.dart';
import '../../waste_feature/collect_list_screen.dart';
import 'package:recycleorigin/l10n/l10n.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static const _kAnimationDuration = Duration(milliseconds: 800);

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: _kAnimationDuration,
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _initData();
    });
  }

  Future<void> _initData() async {
    context.read<ProductsBloc>().retrieveCategory();
    final authProvider = context.read<AuthBloc>();
    await authProvider.getTokenFromDB();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _showStatusDialog({
    required BuildContext context,
    required String title,
    required String description,
  }) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => CustomDialog(
        title: title,
        buttonText: ctx.l10n.accept,
        description: description,
        image: Image.asset('assets/images/main_page_request_ic.png'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.isFirstLogin != current.isFirstLogin ||
          previous.isFirstLogout != current.isFirstLogout,
      listener: (context, state) {
        if (state.isFirstLogin) {
          _showStatusDialog(
            context: context,
            title: context.l10n.welcome,
            description: context.l10n.forarticles,
          );
          context.read<AuthBloc>().isFirstLogin = false;
        }

        if (state.isFirstLogout) {
          _showStatusDialog(
            context: context,
            title: context.l10n.dearuser,
            description: context.l10n.logoutsuccess,
          );
          context.read<AuthBloc>().isFirstLogout = false;
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.bg,
                AppTheme.bg.withValues(alpha: 0.95),
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: const _HomeHeader(),
                  ),
                ),
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
                SliverToBoxAdapter(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: const _PrimaryActionButton(),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                const _ServicesGridSliver(),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height * 0.25;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.15),
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
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                  ],
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
  const _WelcomeSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          Text(
            context.l10n.homeWelcomeHeadline,
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
            context.l10n.homeWelcomeSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.h1.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w400,
                    ) ??
                TextStyle(
                  fontSize: 14,
                  color: AppTheme.h1.withValues(alpha: 0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton();

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
              color: AppTheme.primary.withValues(alpha: 0.3),
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
              children: [
                const Icon(Icons.recycling, color: Colors.white, size: 26),
                const SizedBox(width: 12),
                Text(
                  context.l10n.requestCollectionHeroTitle,
                  style: const TextStyle(
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

class _ServiceItem {
  const _ServiceItem({
    required this.title,
    required this.icon,
    required this.imageUrl,
    required this.onTap,
    required this.color,
  });

  final String title;
  final IconData icon;
  final String imageUrl;
  final VoidCallback onTap;
  final Color color;
}

class _ServicesGridSliver extends StatelessWidget {
  const _ServicesGridSliver();

  @override
  Widget build(BuildContext context) {
    final items = <_ServiceItem>[
      _ServiceItem(
        title: context.l10n.request,
        icon: Icons.assignment,
        imageUrl: 'assets/images/main_page_request_ic.png',
        onTap: () =>
            Navigator.of(context).pushNamed(CollectListScreen.routeName),
        color: Colors.blue,
      ),
      _ServiceItem(
        title: context.l10n.wallet,
        icon: Icons.account_balance_wallet,
        imageUrl: 'assets/images/main_page_wallet_ic.png',
        onTap: () => Navigator.of(context).pushNamed(WalletScreen.routeName),
        color: Colors.green,
      ),
      _ServiceItem(
        title: context.l10n.articles,
        icon: Icons.article,
        imageUrl: 'assets/images/main_page_paper_ic.png',
        onTap: () => Navigator.of(context).pushNamed(ArticlesScreen.routeName),
        color: Colors.orange,
      ),
      _ServiceItem(
        title: context.l10n.store,
        icon: Icons.store,
        imageUrl: 'assets/images/main_page_shop_ic.png',
        onTap: () => Navigator.of(context).pushNamed(ProductsScreen.routeName),
        color: Colors.purple,
      ),
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            return _ServiceCard(
              title: item.title,
              icon: item.icon,
              imageUrl: item.imageUrl,
              onTap: item.onTap,
              color: item.color,
            );
          },
          childCount: items.length,
        ),
      ),
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
    required this.title,
    required this.icon,
    required this.imageUrl,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.08), width: 1),
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
                    color: color.withValues(alpha: 0.1),
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
