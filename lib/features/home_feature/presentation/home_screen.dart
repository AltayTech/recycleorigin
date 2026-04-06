import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_dialog.dart';
import '../../articles_feature/presentation/pages/article_screen.dart';
import '../../auth_feature/presentation/bloc/auth_bloc.dart';
import '../../auth_feature/presentation/bloc/auth_state.dart';
import '../../collect_feature/presentation/pages/waste_cart_screen.dart';
import '../../customer_feature/presentation/screens/profile_screen.dart';
import '../../store_feature/presentation/bloc/products_bloc.dart';
import '../../store_feature/presentation/screens/product_screen.dart';
import '../../support_tickets/presentation/screens/support_tickets_list_screen.dart';
import '../../wallet_feature/presentation/pages/wallet_screen.dart';
import '../../waste_feature/collect_list_screen.dart';
import 'package:recycleorigin/l10n/l10n.dart';

import 'widgets/home_hero_section.dart';
import 'widgets/services_grid.dart';

/// The main dashboard surface of the customer app.
///
/// Responsibilities are kept thin on purpose: orchestrate child
/// widgets, wire navigation callbacks, and react to auth-status
/// changes via [BlocListener].
class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static const _animationDuration = Duration(milliseconds: 800);

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadInitialData();
    });
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _loadInitialData() {
    context.read<ProductsBloc>().retrieveCategory();
    context.read<AuthBloc>().getTokenFromDB();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _openWasteCart() =>
      Navigator.of(context).pushNamed(WasteCartScreen.routeName);

  void _openCollectList() =>
      Navigator.of(context).pushNamed(CollectListScreen.routeName);

  void _openWallet() => Navigator.of(context).pushNamed(WalletScreen.routeName);

  void _openArticles() =>
      Navigator.of(context).pushNamed(ArticlesScreen.routeName);

  void _openStore() =>
      Navigator.of(context).pushNamed(ProductsScreen.routeName);

  void _openProfile() =>
      Navigator.of(context).pushNamed(ProfileScreen.routeName);

  void _openSupport() =>
      Navigator.of(context).pushNamed(SupportTicketsListScreen.routeName);

  // ---------------------------------------------------------------------------
  // Dialogs
  // ---------------------------------------------------------------------------

  Future<void> _showStatusDialog({
    required String title,
    required String description,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => CustomDialog(
        title: title,
        buttonText: ctx.l10n.accept,
        description: description,
        image: Image.asset(
          'assets/images/main_page_request_ic.png',
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Auth listener
  // ---------------------------------------------------------------------------

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state.isFirstLogin) {
      _showStatusDialog(
        title: context.l10n.welcome,
        description: context.l10n.forarticles,
      );
      context.read<AuthBloc>().isFirstLogin = false;
    }

    if (state.isFirstLogout) {
      _showStatusDialog(
        title: context.l10n.dearuser,
        description: context.l10n.logoutsuccess,
      );
      context.read<AuthBloc>().isFirstLogout = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Service descriptors
  // ---------------------------------------------------------------------------

  List<ServiceDescriptor> _buildServiceDescriptors(
    BuildContext context,
  ) {
    return [
      ServiceDescriptor(
        title: context.l10n.wallet,
        assetPath: 'assets/images/main_page_wallet_ic.png',
        color: Colors.green,
        onTap: _openWallet,
      ),
      ServiceDescriptor(
        title: context.l10n.store,
        assetPath: 'assets/images/main_page_shop_ic.png',
        color: Colors.purple,
        onTap: _openStore,
      ),
      ServiceDescriptor(
        title: context.l10n.articles,
        assetPath: 'assets/images/main_page_paper_ic.png',
        color: Colors.orange,
        onTap: _openArticles,
      ),
      ServiceDescriptor(
        title: context.l10n.profile,
        icon: Icons.person_rounded,
        color: Colors.indigo,
        onTap: _openProfile,
      ),
    ];
  }

  List<HeroQuickLink> _buildQuickLinks(BuildContext context) {
    return [
      HeroQuickLink(
        label: context.l10n.navMyRequestsTab,
        icon: Icons.inventory_2_outlined,
        onTap: _openCollectList,
      ),
      HeroQuickLink(
        label: context.l10n.supportHelpLabel,
        icon: Icons.support_agent_rounded,
        onTap: _openSupport,
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          prev.isFirstLogin != curr.isFirstLogin ||
          prev.isFirstLogout != curr.isFirstLogout,
      listener: _onAuthStateChanged,
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.bg,
                AppTheme.bg.withValues(alpha: 0.96),
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: HomeHeroSection(
                        onPrimaryActionPressed: _openWasteCart,
                        quickLinks: _buildQuickLinks(context),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 4),
                ),
                ServicesGrid(
                  descriptors: _buildServiceDescriptors(context),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
