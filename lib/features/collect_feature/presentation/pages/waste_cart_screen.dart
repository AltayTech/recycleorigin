import 'package:flutter/material.dart';
import 'package:recycleorigin/l10n/l10n.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart' as intl;
import 'package:recycleorigin/core/widgets/buton_bottom.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/price_weight.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/wasteCart.dart';

import '../../../../core/logic/en_to_ar_number_convertor.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/drawer_or_back_leading.dart';
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

  const WasteCartScreen({super.key});

  @override
  State<WasteCartScreen> createState() => _WasteCartScreenState();
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
      duration: const Duration(milliseconds: 800),
    );
    _totalPriceAnimation = _totalPriceController;

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
    if (_isInit) {
      await authProvider.checkCompleted();
      _isInit = false;
    }

    await _refreshWasteItems();

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _refreshWasteItems() async {
    final wastesProvider = context.read<WastesBloc>();

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
      if (item.prices.isNotEmpty) total += item.weight;
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
          backgroundColor: context.colors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        title: Text(
          context.l10n.wasteCartTitle,
          style: TextStyle(
            color: AppTheme.appBarIconColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: const IconThemeData(color: AppTheme.appBarIconColor),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: context.l10n.addItemsTooltip,
            icon: Icon(Icons.add_circle_outline),
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
                _StepProgressBar(currentStep: 0),
                if (items.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
                            horizontal: 16,
                            vertical: 12,
                          ),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) => WasteCartItem(
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
      drawer: mainDrawerIfRootRoute(context),
    );
  }
}

/// Horizontal stepper showing the 4 steps of the waste request flow.
class _StepProgressBar extends StatelessWidget {
  const _StepProgressBar({required this.currentStep});

  final int currentStep;

  static const _steps = [
    Icons.shopping_cart_outlined,
    Icons.location_on_outlined,
    Icons.calendar_today_outlined,
    Icons.check_circle_outline,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = [
      l10n.stepCartLabel,
      l10n.stepAddressLabel,
      l10n.stepDateLabel,
      l10n.stepConfirmLabel,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final stepBefore = index ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: stepBefore < currentStep
                      ? AppTheme.primary
                      : context.colors.outline,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final isActive = stepIndex == currentStep;
          final isCompleted = stepIndex < currentStep;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.primary
                      : isActive
                          ? AppTheme.primary.withValues(alpha: 0.12)
                          : context.appColors.divider,
                  shape: BoxShape.circle,
                  border: isActive
                      ? Border.all(color: AppTheme.primary, width: 2)
                      : null,
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : _steps[stepIndex],
                  size: 16,
                  color: isCompleted
                      ? context.appColors.onHeroForeground
                      : isActive
                          ? AppTheme.primary
                          : context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                labels[stepIndex],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive || isCompleted
                      ? AppTheme.primary
                      : context.colors.onSurfaceVariant,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _WasteCartSummary extends StatelessWidget {
  final int itemCount;
  final int totalWeight;
  final Animation<double> priceAnimation;

  const _WasteCartSummary({
    required this.itemCount,
    required this.totalWeight,
    required this.priceAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = intl.NumberFormat.decimalPattern();
    final converter = EnArConvertor();
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.06),
            AppTheme.primary.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.12),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _SummaryItem(
              icon: Icons.inventory_2_rounded,
              iconColor: AppTheme.primary,
              label: l10n.cartItemsLabel,
              value: converter.replaceArNumber(itemCount.toString()),
            ),
            VerticalDivider(
              thickness: 1,
              width: 24,
              color: AppTheme.primary.withValues(alpha: 0.12),
            ),
            AnimatedBuilder(
              animation: priceAnimation,
              builder: (_, __) => _SummaryItem(
                icon: Icons.monetization_on_rounded,
                iconColor: AppTheme.iconAccentGold,
                label: l10n.cartTotalLabel,
                value: converter.replaceArNumber(
                  currencyFormat.format(priceAnimation.value.toInt()),
                ),
                isHighlight: true,
              ),
            ),
            VerticalDivider(
              thickness: 1,
              width: 24,
              color: AppTheme.primary.withValues(alpha: 0.12),
            ),
            _SummaryItem(
              icon: Icons.scale_rounded,
              iconColor: AppTheme.iconAccentPurple,
              label: l10n.weightKgFullLabel,
              value: converter.replaceArNumber(
                totalWeight.toString(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? AppTheme.primary : context.colors.onSurface,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: context.appColors.subtitleColor.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _WasteCartEmptyState extends StatelessWidget {
  final VoidCallback onAddPressed;

  const _WasteCartEmptyState({required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.recycling_rounded,
                size: 64,
                color: AppTheme.primary.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.cartIsEmpty,
              style: TextStyle(
                color: context.colors.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                l10n.wasteCartEmptySubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.appColors.subtitleColor.withValues(alpha: 0.7),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: context.appColors.onHeroForeground,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              onPressed: onAddPressed,
              icon: Icon(Icons.add_rounded, size: 20),
              label: Text(
                l10n.addWasteItemsTitle,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WasteCartBottomBar extends StatelessWidget {
  final Animation<double> totalPriceAnimation;
  final VoidCallback onContinue;
  final bool isEnabled;

  const _WasteCartBottomBar({
    required this.totalPriceAnimation,
    required this.onContinue,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        14,
        24,
        14 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.cartTotalAmountLabel,
                  style: TextStyle(
                    color: context.appColors.subtitleColor.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedBuilder(
                  animation: totalPriceAnimation,
                  builder: (_, __) => Text(
                    '${EnArConvertor().replaceArNumber(
                      intl.NumberFormat.decimalPattern()
                          .format(totalPriceAnimation.value.toInt()),
                    )} \$',
                    style: TextStyle(
                      color: context.colors.onSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: isEnabled ? onContinue : null,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              child: ButtonBottom(
                width: double.infinity,
                height: 52,
                text: l10n.continueLabel,
                isActive: isEnabled,
                icon: Icons.arrow_forward_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
