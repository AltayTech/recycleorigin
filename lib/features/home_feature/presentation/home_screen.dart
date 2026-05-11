import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/auth_snackbars.dart';
import '../../articles_feature/presentation/pages/article_screen.dart';
import '../../auth_feature/presentation/bloc/auth_bloc.dart';
import '../../auth_feature/presentation/bloc/auth_state.dart';
import '../../collect_feature/presentation/pages/waste_cart_screen.dart';
import '../../guid_feature/presentation/pages/guide_screen.dart';
import '../../customer_feature/presentation/screens/profile_screen.dart';
import '../../store_feature/presentation/bloc/products_bloc.dart';
import '../../store_feature/presentation/screens/product_screen.dart';
import '../../support_tickets/presentation/screens/support_tickets_list_screen.dart';
import '../../wallet_feature/presentation/pages/wallet_screen.dart';
import '../../waste_feature/collect_list_screen.dart';
import 'package:recycleorigin/l10n/l10n.dart';

import 'widgets/home_hero_section.dart';
import 'widgets/section_header.dart';
import 'widgets/services_grid.dart';

/// The main dashboard surface of the customer app.
///
/// Keeps responsibilities thin: orchestrate child widgets, wire
/// navigation callbacks, and react to auth-status changes.
class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static const _entranceDuration = Duration(milliseconds: 700);
  static const _staggerDelay = Duration(milliseconds: 120);

  late final AnimationController _controller;
  late final Animation<double> _heroFade;
  late final Animation<Offset> _heroSlide;
  late final Animation<double> _gridFade;
  late final Animation<Offset> _gridSlide;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadInitialData();
    });
  }

  void _initAnimations() {
    _controller = AnimationController(
      duration: _entranceDuration + _staggerDelay,
      vsync: this,
    );

    final heroCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.8, curve: Curves.easeOutCubic),
    );
    _heroFade = heroCurve;
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(heroCurve);

    final gridCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 1.0, curve: Curves.easeOutCubic),
    );
    _gridFade = gridCurve;
    _gridSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(gridCurve);
  }

  void _loadInitialData() {
    context.read<ProductsBloc>().retrieveCategory();
    context.read<AuthBloc>().getTokenFromDB();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Navigation ─────────────────────────────────────────────────

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

  void _openGuide() => Navigator.of(context).pushNamed(GuideScreen.routeName);

  // ── Auth listener ──────────────────────────────────────────────

  void _onAuthStateChanged(
    BuildContext context,
    AuthState state,
  ) {
    if (state.isFirstLogin) {
      showLoginSuccessSnackBar(context, context.l10n);
      context.read<AuthBloc>().isFirstLogin = false;
    }

    if (state.isFirstLogout) {
      showLogoutSuccessSnackBar(context, context.l10n);
      context.read<AuthBloc>().isFirstLogout = false;
    }
  }

  // ── Descriptors ────────────────────────────────────────────────

  List<ServiceDescriptor> _buildServiceDescriptors(
    BuildContext context,
  ) =>
      [
        ServiceDescriptor(
          title: context.l10n.wallet,
          assetPath: 'assets/images/main_page_wallet_ic.png',
          color: const Color(0xFF22C55E),
          onTap: _openWallet,
        ),
        ServiceDescriptor(
          title: context.l10n.store,
          assetPath: 'assets/images/main_page_shop_ic.png',
          color: const Color(0xFF8B5CF6),
          onTap: _openStore,
        ),
        ServiceDescriptor(
          title: context.l10n.articles,
          assetPath: 'assets/images/main_page_paper_ic.png',
          color: const Color(0xFFF59E0B),
          onTap: _openArticles,
        ),
        ServiceDescriptor(
          title: context.l10n.profile,
          icon: Icons.person_rounded,
          color: const Color(0xFF6366F1),
          onTap: _openProfile,
        ),
      ];

  List<HeroQuickLink> _buildQuickLinks(BuildContext context) => [
        HeroQuickLink(
          label: context.l10n.navMyRequestsTab,
          icon: Icons.inventory_2_outlined,
          onTap: _openCollectList,
        ),
        HeroQuickLink(
          label: context.l10n.guideTitle,
          icon: Icons.menu_book_outlined,
          onTap: _openGuide,
        ),
        HeroQuickLink(
          label: context.l10n.supportHelpLabel,
          icon: Icons.support_agent_rounded,
          onTap: _openSupport,
        ),
      ];

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          prev.isFirstLogin != curr.isFirstLogin ||
          prev.isFirstLogout != curr.isFirstLogout,
      listener: _onAuthStateChanged,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.scaffoldBackgroundColor,
                theme.scaffoldBackgroundColor.withValues(alpha: 0.96),
                theme.colorScheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppBreakpoints.contentMaxWidth,
                ),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    // ── Hero ─────────────────────────────────
                    SliverToBoxAdapter(
                      child: SlideTransition(
                        position: _heroSlide,
                        child: FadeTransition(
                          opacity: _heroFade,
                          child: HomeHeroSection(
                            onPrimaryActionPressed: _openWasteCart,
                            quickLinks: _buildQuickLinks(context),
                          ),
                        ),
                      ),
                    ),

                    // ── Section header ───────────────────────
                    SliverToBoxAdapter(
                      child: SlideTransition(
                        position: _gridSlide,
                        child: FadeTransition(
                          opacity: _gridFade,
                          child: SectionHeader(
                            title: context.l10n.homeServicesTitle,
                          ),
                        ),
                      ),
                    ),

                    // ── Services grid ────────────────────────
                    SliverToBoxAdapter(
                      child: SlideTransition(
                        position: _gridSlide,
                        child: FadeTransition(
                          opacity: _gridFade,
                          child: ServicesGrid(
                            descriptors: _buildServiceDescriptors(context),
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppTheme.spacingLg),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
