import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/core/theme/theme_context_extensions.dart';
import 'package:recycleorigin/core/utils/result.dart';
import 'package:recycleorigin/features/clearing_feature/presentation/pages/clear_screen.dart';
import 'package:recycleorigin/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigin/core/network/api_provider.dart';
import 'package:recycleorigin/features/wallet_feature/business/entities/wallet.dart';
import 'package:recycleorigin/features/wallet_feature/business/entities/wallet_transaction.dart';
import 'package:recycleorigin/features/wallet_feature/data/wallet_repository.dart';
import 'package:recycleorigin/features/wallet_feature/presentation/widgets/transaction_item.dart';
import 'package:recycleorigin/features/wallet_feature/presentation/widgets/wallet_balance_card.dart';
import '../../../auth_feature/presentation/screens/login_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/l10n/l10n.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  static const routeName = '/walletScreen';

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ScrollController _scrollController = ScrollController();
  late final WalletRepository _walletRepository;

  bool _isLoading = false;
  String? _errorMessage;
  int _page = 1;
  int _maxPage = 1;
  Wallet _wallet = const Wallet();
  List<WalletTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _walletRepository = WalletRepository(ApiProvider.client);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _page < _maxPage) {
        _loadMore();
      }
    }
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthBloc>();
    if (!authProvider.isAuth) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final walletResult = await _walletRepository.fetchWallet();
    final txResult = await _walletRepository.fetchTransactions(page: 1);

    if (!mounted) {
      return;
    }

    switch (walletResult) {
      case Success(:final value):
        _wallet = value;
      case Failure(:final message):
        setState(() {
          _isLoading = false;
          _errorMessage = message;
        });
        return;
    }

    switch (txResult) {
      case Success(:final value):
        setState(() {
          _page = 1;
          _transactions = value.transactions;
          _maxPage = value.maxPages;
          _isLoading = false;
          _errorMessage = null;
        });
      case Failure(:final message):
        setState(() {
          _isLoading = false;
          _errorMessage = message;
        });
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoading = true);
    final nextPage = _page + 1;
    final txResult = await _walletRepository.fetchTransactions(page: nextPage);

    if (!mounted) {
      return;
    }

    switch (txResult) {
      case Success(:final value):
        setState(() {
          _page = nextPage;
          _transactions.addAll(value.transactions);
          _maxPage = value.maxPages;
          _isLoading = false;
        });
      case Failure(:final message):
        setState(() {
          _isLoading = false;
          _errorMessage = message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthBloc>();
    final isLogin = authProvider.isAuth;

    return Scaffold(
      backgroundColor: context.appColors.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.appBarIconColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.l10n.wallet,
          style: const TextStyle(
            color: AppTheme.appBarIconColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.appBarColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: !isLogin
          ? _buildNotLoggedInState()
          : _errorMessage != null && _transactions.isEmpty && !_isLoading
          ? _buildErrorState()
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          WalletBalanceCard(
                            balance: _wallet.balance,
                            currency: _wallet.currency,
                          ),
                          const SizedBox(height: 24),
                          _buildActionButtons(context),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.walletRecentTransactions,
                                style: TextStyle(
                                  color: context.colors.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_transactions.isNotEmpty)
                                Text(
                                  context.l10n.walletItemsCount(
                                    _transactions.length,
                                  ),
                                  style: TextStyle(
                                    color: context.appColors.subtitleColor,
                                    fontSize: 14,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  _transactions.isEmpty && !_isLoading
                      ? SliverToBoxAdapter(child: _buildEmptyState())
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return WalletTransactionItem(
                              transaction: _transactions[index],
                            );
                          }, childCount: _transactions.length),
                        ),
                  if (_isLoading)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: SpinKitFadingCircle(
                            color: AppTheme.primary,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
                ],
              ),
            ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: context.colors.error),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.appColors.subtitleColor),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: Text(context.l10n.retryLabel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(ClearScreen.routeName);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: context.appColors.danger,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: context.appColors.danger.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.attach_money,
                    color: context.appColors.onHeroForeground,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.walletWithdrawRequestButton,
                    style: TextStyle(
                      color: context.appColors.onHeroForeground,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: context.colors.outline,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.walletNoTransactionsYet,
            style: TextStyle(
              color: context.appColors.subtitleColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedInState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: context.colors.outline,
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.pleaseLoginToViewWallet,
              style: TextStyle(
                fontSize: 18,
                color: context.appColors.subtitleColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(LoginScreen.routeName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                context.l10n.login,
                style: TextStyle(
                  color: context.appColors.onHeroForeground,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
