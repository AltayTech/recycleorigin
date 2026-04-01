import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigin/core/models/transaction.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/features/clearing_feature/presentation/pages/clear_screen.dart';
import 'package:recycleorigin/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigin/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigin/features/customer_feature/presentation/bloc/customer_info_state.dart';
import 'package:recycleorigin/features/wallet_feature/presentation/widgets/transaction_item.dart';
import 'package:recycleorigin/features/wallet_feature/presentation/widgets/wallet_balance_card.dart';
import '../../../auth_feature/presentation/screens/login_screen.dart';
import '../../../../core/models/search_detail.dart';
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
  SearchDetail _searchDetail = SearchDetail();
  List<Transaction> _transactions = [];

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
      if (!_isLoading && _page < _searchDetail.max_page) {
        _loadMore();
      }
    }
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthBloc>();
    if (!authProvider.isAuth) return;

    setState(() => _isLoading = true);

    try {
      final customerProvider = context.read<CustomerInfoBloc>();

      // Reset page
      _page = 1;
      customerProvider.sPage = 1;

      // Fetch customer info
      await customerProvider.getCustomer();

      // Fetch transactions
      customerProvider.searchBuilder();
      await customerProvider.searchTransactionItems();

      if (mounted) {
        setState(() {
          _searchDetail = customerProvider.searchDetails;
          _transactions = customerProvider.transactionItems;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Ideally show error snackbar here
      }
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoading = true);
    try {
      _page++;
      final customerProvider = context.read<CustomerInfoBloc>();
      customerProvider.sPage = _page;

      // Assuming searchTransactionItems appends or we need to fetch and append.
      // The original code seemed to re-fetch or use pagination state internally.
      // Based on original code:
      await customerProvider
          .searchTransactionItems(); // This likely updates the provider's list

      final newTransactions = customerProvider.transactionItems;

      if (mounted) {
        setState(() {
          // If the provider replaces the list, we might need to handle it.
          // But original code did: loadedProducts = await ... transactionItems; loadedProductstolist.addAll(loadedProducts);
          // Let's assume transactionItems returns the *new* items for the page.
          _transactions.addAll(newTransactions);
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
      backgroundColor: const Color(0xffF9F9F9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Wallet',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                          BlocBuilder<CustomerInfoBloc, CustomerInfoState>(
                            builder: (context, state) => WalletBalanceCard(
                                balance: state.customer.money),
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
                                  color: AppTheme.h1,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_transactions.isNotEmpty)
                                Text(
                                  '${_transactions.length} items',
                                  style: TextStyle(
                                    color: AppTheme.grey,
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
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return TransactionItem(
                                transaction: _transactions[index],
                              );
                            },
                            childCount: _transactions.length,
                          ),
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
                color: const Color(0xffFF595E),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xffFF595E).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.attach_money, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.walletWithdrawRequestButton,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Add more buttons here if needed (e.g. Donate)
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
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.walletNoTransactionsYet,
            style: TextStyle(
              color: AppTheme.grey,
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
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.pleaseLoginToViewWallet,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
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
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
