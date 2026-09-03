import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:recycleorigin/core/constants/urls.dart';
import 'package:recycleorigin/core/storage/secure_storage.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/core/theme/theme_context_extensions.dart';
import 'package:recycleorigin/features/clearing_feature/presentation/pages/clear_screen.dart';
import 'package:recycleorigin/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigin/core/network/api_provider.dart';
import 'package:recycleorigin/core/utils/result.dart';
import 'package:recycleorigin/features/wallet_feature/business/entities/wallet.dart';
import 'package:recycleorigin/features/wallet_feature/business/entities/wallet_transaction.dart';
import 'package:recycleorigin/features/wallet_feature/data/wallet_repository.dart';
import 'package:recycleorigin/features/wallet_feature/presentation/widgets/transaction_item.dart';
import 'package:recycleorigin/features/wallet_feature/presentation/widgets/wallet_balance_card.dart';
import '../../../auth_feature/presentation/screens/login_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/l10n/l10n.dart';

class WalletScreen extends StatefulWidget {
  static const routeName = '/walletScreen';

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  int _page = 1;
  int _maxPage = 1;
  Wallet _wallet = const Wallet();
  List<WalletTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
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

  Future<Map<String, String>> _authHeaders() async {
    final token = await SecureStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthBloc>();
    if (!authProvider.isAuth) return;

    setState(() => _isLoading = true);

    try {
      final headers = await _authHeaders();
      final walletResult = await WalletRepository(
        ApiProvider.client,
      ).fetchWallet();
      if (walletResult case Success(:final value) when mounted) {
        _wallet = value;
      }

      // Load full transaction history.
      _page = 1;
      final txUrl = Uri.parse(
        Urls.rootUrl + Urls.walletTransactionsEndPoint,
      ).replace(queryParameters: {'page': '1', 'per_page': '20'});
      final txResp = await http.get(txUrl, headers: headers);
      if (txResp.statusCode == 200 && mounted) {
        final txData = jsonDecode(txResp.body) as Map<String, dynamic>;
        final txList = txData['data'] as List<dynamic>? ?? [];
        _transactions = txList
            .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
            .toList();
        final details = txData['details'] as Map<String, dynamic>?;
        _maxPage = details?['max_pages'] as int? ?? 1;
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoading = true);
    try {
      _page++;
      final headers = await _authHeaders();
      final txUrl = Uri.parse(
        Urls.rootUrl + Urls.walletTransactionsEndPoint,
      ).replace(queryParameters: {'page': '$_page', 'per_page': '20'});
      final txResp = await http.get(txUrl, headers: headers);
      if (txResp.statusCode == 200 && mounted) {
        final txData = jsonDecode(txResp.body) as Map<String, dynamic>;
        final txList = txData['data'] as List<dynamic>? ?? [];
        final newTx = txList
            .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() {
          _transactions.addAll(newTx);
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
          'Wallet',
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
                                'Recent Transactions',
                                style: TextStyle(
                                  color: context.colors.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_transactions.isNotEmpty)
                                Text(
                                  '${_transactions.length} items',
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
