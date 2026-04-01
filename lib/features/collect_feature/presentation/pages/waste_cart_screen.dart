import 'package:flutter/material.dart';
import 'package:recycleorigin/l10n/l10n.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart' as intl;
import 'package:recycleorigin/core/widgets/buton_bottom.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/price_weight.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/wasteCart.dart';

import '../../../../core/logic/en_to_ar_number_convertor.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/main_drawer.dart';
import '../../../auth_feature/presentation/bloc/auth_bloc.dart';
import '../../../waste_feature/presentation/address_screen.dart';
import '../../../waste_feature/presentation/bloc/wastes_bloc.dart';
import '../../../waste_feature/presentation/bloc/wastes_state.dart';
import '../../../waste_feature/presentation/wastes_screen.dart';
import '../../../waste_feature/presentation/widgets/custom_dialog_enter.dart';
import '../../../waste_feature/presentation/widgets/waste_cart_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WasteCartScreen extends StatefulWidget {
  static const routeName = '/waste_cart_screen';

  const WasteCartScreen({Key? key}) : super(key: key);

  @override
  _WasteCartScreenState createState() => _WasteCartScreenState();
}

class _WasteCartScreenState extends State<WasteCartScreen>
    with TickerProviderStateMixin {
  bool _isInit = true;
  bool _isLoading = false;

  late AnimationController _totalPriceController;
  late Animation<double> _totalPriceAnimation;

  @override
  void initState() {
    super.initState();
    _totalPriceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _totalPriceAnimation = _totalPriceController;

    // Defer initial load to after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _totalPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthBloc>();
    // Check completion status if needed (logic from original code)
    if (_isInit) {
      await authProvider.checkCompleted();
      _isInit = false;
    }

    // Refresh waste items
    await _refreshWasteItems();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshWasteItems() async {
    // In a real app, this might fetch from an API.
    // Here we are just ensuring the provider state is up to date if needed.
    // The original code reset local variables here.

    // We trigger a rebuild to recalculate totals
    final wastesProvider = context.read<WastesBloc>();
    // If there's an async fetch in provider: await wastesProvider.fetchCart();

    // Calculate total for animation
    final total = _calculateTotalPrice(wastesProvider.wasteCartItems);
    _animatePriceTo(total.toDouble());

    if (mounted) setState(() {});
  }

  void _animatePriceTo(double newValue) {
    _totalPriceAnimation = Tween<double>(
      begin: _totalPriceAnimation.value,
      end: newValue,
    ).animate(CurvedAnimation(
      curve: Curves.easeOutCubic,
      parent: _totalPriceController,
    ));
    _totalPriceController.forward(from: 0.0);
  }

  int _calculateTotalPrice(List<WasteCart> items) {
    int total = 0;
    for (var item in items) {
      if (item.prices.isNotEmpty) {
        final priceStr = _getPriceForWeight(item.prices, item.weight);
        final price = int.tryParse(priceStr) ?? 0;
        total += price * item.weight;
      }
    }
    return total;
  }

  int _calculateTotalWeight(List<WasteCart> items) {
    int total = 0;
    for (var item in items) {
      if (item.prices.isNotEmpty) {
        total += item.weight;
      }
    }
    return total;
  }

  String _getPriceForWeight(List<PriceWeight> prices, int weight) {
    for (var p in prices) {
      final tierWeight = int.tryParse(p.weight) ?? 0;
      if (weight > tierWeight) {
        return p.price;
      } else {
        return p.price;
      }
    }
    return '0';
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialogEnter(
        title: ctx.l10n.login,
        buttonText: ctx.l10n.goToLoginScreenButton,
        description: ctx.l10n.pleaseLoginToContinue,
        image: Image.asset('assets/images/main_page_request_ic.png'),
      ),
    );
  }

  void _handleContinue() {
    final wastesProvider = context.read<WastesBloc>();
    final isAuth = context.read<AuthBloc>().isAuth;

    if (wastesProvider.wasteCartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.pleaseAddWasteItems),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (!isAuth) {
      _showLoginDialog();
      return;
    }

    Navigator.of(context).pushNamed(AddressScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(
          context.l10n.wasteCartTitle,
          style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: const IconThemeData(color: AppTheme.appBarIconColor),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: context.l10n.addItemsTooltip,
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () async {
              await Navigator.of(context).pushNamed(WastesScreen.routeName);
              await _refreshWasteItems();
            },
          )
        ],
      ),
      body: BlocBuilder<WastesBloc, WastesState>(
        builder: (context, state) {
          final items = state.wasteCartItems;
          final totalWeight = _calculateTotalWeight(items);

          if (_isLoading) {
            return Center(
              child: SpinKitFadingCircle(
                color: AppTheme.primary,
                size: 50.0,
              ),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                if (items.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _WasteCartSummary(
                      itemCount: items.length,
                      totalWeight: totalWeight,
                      priceAnimation: _totalPriceAnimation,
                    ),
                  ),
                Expanded(
                  child: items.isEmpty
                      ? _WasteCartEmptyState(onAddPressed: () async {
                          await Navigator.of(context)
                              .pushNamed(WastesScreen.routeName);
                          await _refreshWasteItems();
                        })
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: items.length,
                          separatorBuilder: (ctx, i) =>
                              const SizedBox(height: 12),
                          itemBuilder: (ctx, i) => WasteCartItem(
                            wasteItem: items[i],
                            function: _refreshWasteItems,
                          ),
                        ),
                ),
                _WasteCartBottomBar(
                  totalPriceAnimation: _totalPriceAnimation,
                  onContinue: _handleContinue,
                  isEnabled: items.isNotEmpty,
                ),
              ],
            ),
          );
        },
      ),
      endDrawer: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
        child: MainDrawer(),
      ),
    );
  }
}

class _WasteCartSummary extends StatelessWidget {
  final int itemCount;
  final int totalWeight;
  final Animation<double> priceAnimation;

  const _WasteCartSummary({
    Key? key,
    required this.itemCount,
    required this.totalWeight,
    required this.priceAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = intl.NumberFormat.decimalPattern();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(
              icon: 'assets/images/main_page_request_ic.png',
              label: context.l10n.cartItemsLabel,
              value: EnArConvertor().replaceArNumber(itemCount.toString()),
            ),
            const VerticalDivider(
                thickness: 1, width: 32, color: Color(0xFFEEEEEE)),
            AnimatedBuilder(
              animation: priceAnimation,
              builder: (context, child) => _buildStatItem(
                icon: 'assets/images/waste_cart_price_ic.png',
                label: 'Total',
                value: EnArConvertor().replaceArNumber(
                  currencyFormat.format(priceAnimation.value.toInt()),
                ),
                isHighlight: true,
              ),
            ),
            const VerticalDivider(
                thickness: 1, width: 32, color: Color(0xFFEEEEEE)),
            _buildStatItem(
              icon: 'assets/images/waste_cart_weight_ic.png',
              label: context.l10n.weightKgFullLabel,
              value: EnArConvertor().replaceArNumber(totalWeight.toString()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String label,
    required String value,
    bool isHighlight = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(icon, height: 28, width: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? AppTheme.primary : AppTheme.h1,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _WasteCartEmptyState extends StatelessWidget {
  final VoidCallback onAddPressed;

  const _WasteCartEmptyState({Key? key, required this.onAddPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.8,
            child: Image.asset(
              'assets/images/collect_list_header.png',
              width: size.width * 0.5,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              color: AppTheme.h1,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add waste items to start recycling',
            style: TextStyle(color: AppTheme.grey, fontSize: 14),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            onPressed: onAddPressed,
            icon: const Icon(Icons.add),
            label:
                Text(context.l10n.addWasteItemsTitle,
                    style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class _WasteCartBottomBar extends StatelessWidget {
  final Animation<double> totalPriceAnimation;
  final VoidCallback onContinue;
  final bool isEnabled;

  const _WasteCartBottomBar({
    Key? key,
    required this.totalPriceAnimation,
    required this.onContinue,
    required this.isEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24,
          16 + MediaQuery.of(context).padding.bottom // Safe area bottom
          ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(color: AppTheme.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                AnimatedBuilder(
                  animation: totalPriceAnimation,
                  builder: (context, child) => Text(
                    EnArConvertor().replaceArNumber(
                      intl.NumberFormat.decimalPattern()
                          .format(totalPriceAnimation.value.toInt()),
                    ),
                    style: const TextStyle(
                      color: AppTheme.h1,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: onContinue,
            borderRadius: BorderRadius.circular(12),
            child: ButtonBottom(
              width: size.width * 0.45,
              height: 56, // Fixed standard height
              text: 'Continue',
              isActive: isEnabled,
            ),
          ),
        ],
      ),
    );
  }
}
