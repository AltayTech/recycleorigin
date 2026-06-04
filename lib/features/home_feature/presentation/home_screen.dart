import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/auth_snackbars.dart';
import '../../articles_feature/presentation/pages/article_screen.dart';
import '../../auth_feature/presentation/bloc/auth_bloc.dart';
import '../../auth_feature/presentation/bloc/auth_state.dart';
import '../../collect_feature/presentation/pages/waste_cart_screen.dart';
import '../../guid_feature/presentation/pages/guide_screen.dart';
import '../../impact_feature/data/impact_repository.dart';
import '../../impact_feature/presentation/bloc/impact_cubit.dart';
import '../../impact_feature/presentation/screens/impact_screen.dart';
import '../../store_feature/presentation/bloc/products_bloc.dart';
import '../../wallet_feature/data/wallet_repository.dart';
import '../../wallet_feature/presentation/bloc/wallet_summary_cubit.dart';
import '../../wallet_feature/presentation/pages/wallet_screen.dart';
import '../../waste_feature/business/entities/request_waste_item.dart';
import '../../waste_feature/collect_list_screen.dart';
import '../../waste_feature/presentation/bloc/wastes_bloc.dart';
import 'package:recycleorigin/l10n/l10n.dart';

import 'widgets/home_active_request_card.dart';
import 'widgets/home_explore_row.dart';
import 'widgets/home_greeting_header.dart';
import 'widgets/home_impact_snapshot.dart';
import 'widgets/home_section_title.dart';
import 'widgets/home_wallet_preview_card.dart';
import 'widgets/primary_action_button.dart';

/// Customer home dashboard: greeting, CTA, and glanceable data cards.
class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ImpactCubit(ImpactRepository(apiClient)),
        ),
        BlocProvider(
          create: (_) => WalletSummaryCubit(WalletRepository(apiClient)),
        ),
      ],
      child: const _HomeDashboardView(),
    );
  }
}

class _HomeDashboardView extends StatefulWidget {
  const _HomeDashboardView();

  @override
  State<_HomeDashboardView> createState() => _HomeDashboardViewState();
}

class _HomeDashboardViewState extends State<_HomeDashboardView> {
  RequestWasteItem? _latestRequest;
  bool _requestLoading = false;
  bool _requestError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProductsBloc>().retrieveCategory();
      context.read<AuthBloc>().getTokenFromDB();
      _refreshDashboardData();
    });
  }

  Future<void> _refreshDashboardData() async {
    final isAuth = context.read<AuthBloc>().state.isAuth;
    context.read<ImpactCubit>().load();
    await context.read<WalletSummaryCubit>().load(isAuthenticated: isAuth);
    if (isAuth) {
      await _loadLatestRequest();
    } else if (mounted) {
      setState(() {
        _latestRequest = null;
        _requestLoading = false;
        _requestError = false;
      });
    }
  }

  Future<void> _loadLatestRequest() async {
    if (!mounted) return;
    setState(() {
      _requestLoading = true;
      _requestError = false;
    });
    try {
      final bloc = context.read<WastesBloc>();
      bloc.sPage = 1;
      bloc.sOrder = 'desc';
      bloc.sOrderBy = 'date';
      bloc.sCategory = '';
      bloc.searchBuilder();
      await bloc.searchCollectItems();
      if (!mounted) return;
      setState(() {
        _latestRequest =
            bloc.CollectItems.isNotEmpty ? bloc.CollectItems.first : null;
        _requestLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _requestError = true;
        _requestLoading = false;
      });
    }
  }

  void _openWasteCart() =>
      Navigator.of(context).pushNamed(WasteCartScreen.routeName);

  void _openCollectList() =>
      Navigator.of(context).pushNamed(CollectListScreen.routeName);

  void _openWallet() => Navigator.of(context).pushNamed(WalletScreen.routeName);

  void _openArticles() =>
      Navigator.of(context).pushNamed(ArticlesScreen.routeName);

  void _openGuide() => Navigator.of(context).pushNamed(GuideScreen.routeName);

  void _openImpact() => Navigator.of(context).pushNamed(ImpactScreen.routeName);

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state.isFirstLogin) {
      showLoginSuccessSnackBar(context, context.l10n);
      context.read<AuthBloc>().isFirstLogin = false;
    }

    if (state.isFirstLogout) {
      showLogoutSuccessSnackBar(context, context.l10n);
      context.read<AuthBloc>().isFirstLogout = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          prev.isFirstLogin != curr.isFirstLogin ||
          prev.isFirstLogout != curr.isFirstLogout ||
          prev.isAuth != curr.isAuth,
      listener: (context, state) {
        _onAuthStateChanged(context, state);
        _refreshDashboardData();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: _refreshDashboardData,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppBreakpoints.contentMaxWidth,
                ),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    const SliverToBoxAdapter(child: HomeGreetingHeader()),
                    SliverToBoxAdapter(
                      child: PrimaryActionButton(
                        onPressed: _openWasteCart,
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppTheme.spacingMd),
                    ),
                    SliverToBoxAdapter(
                      child: HomeImpactSnapshot(onTap: _openImpact),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppTheme.spacingMd),
                    ),
                    SliverToBoxAdapter(
                      child: HomeWalletPreviewCard(onTap: _openWallet),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppTheme.spacingMd),
                    ),
                    SliverToBoxAdapter(
                      child: HomeSectionTitle(
                        title: context.l10n.homeDashboardActiveRequestTitle,
                        trailing: TextButton(
                          onPressed: _openCollectList,
                          child: Text(context.l10n.homeViewAllRequests),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: HomeActiveRequestCard(
                        request: _latestRequest,
                        isLoading: _requestLoading,
                        hasError: _requestError,
                        onTap: _openCollectList,
                        onRetry: _loadLatestRequest,
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppTheme.spacingLg),
                    ),
                    SliverToBoxAdapter(
                      child: HomeSectionTitle(
                        title: context.l10n.homeExploreTitle,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: HomeExploreRow(
                        onArticlesTap: _openArticles,
                        onGuideTap: _openGuide,
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppTheme.spacingXl),
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
