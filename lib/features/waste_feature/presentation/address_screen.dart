import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:recycleorigin/l10n/l10n.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_context_extensions.dart';
import '../../../core/widgets/buton_bottom.dart';
import '../../../core/widgets/drawer_or_back_leading.dart';
import '../../auth_feature/presentation/bloc/auth_bloc.dart';
import 'pages/map_screen.dart';
import 'waste_request_date_screen.dart';
import 'widgets/address_item.dart';
import 'widgets/custom_dialog_enter.dart';

class AddressScreen extends StatefulWidget {
  static const routeName = '/address_screen';

  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeIn = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAddresses());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthBloc>().getAddresses();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${context.l10n.failedLoadAddressesPrefix}$e',
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _animController.forward();
      }
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialogEnter(
        title: context.l10n.signInRequiredTitle,
        buttonText: context.l10n.login,
        description: context.l10n.pleaseLoginToContinue,
        image: Image.asset('assets/images/main_page_request_ic.png'),
      ),
    );
  }

  void _handleContinue() {
    final authProvider = context.read<AuthBloc>();
    final isLogin = authProvider.isAuth;
    final selectedAddress = authProvider.selectedAddress;

    if (selectedAddress.name.isEmpty) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(context.l10n.pleaseSelectAddress)),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      return;
    }

    if (!isLogin) {
      _showLoginDialog();
    } else {
      Navigator.of(context).pushNamed(WasteRequestDateScreen.routeName);
    }
  }

  void _navigateToMap() {
    Navigator.of(context)
        .pushNamed(MapScreen.routeName)
        .then((_) => _loadAddresses());
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthBloc>();
    final addressList = authProvider.addressItems;
    final hasAddresses = addressList.isNotEmpty;
    final isSelectionValid = authProvider.selectedAddress.name.isNotEmpty;
    final l10n = context.l10n;

    return Scaffold(
            appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        title: Text(
          l10n.addressListTitle,
          style: TextStyle(
            color: AppTheme.appBarIconColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: const IconThemeData(color: AppTheme.appBarIconColor),
        elevation: 0,
      ),
      drawer: mainDrawerIfRootRoute(context),
      body: SafeArea(
        child: Column(
          children: [
            _StepProgressBar(currentStep: 1),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: SpinKitFadingCircle(
                        color: AppTheme.primary,
                        size: 50,
                      ),
                    )
                  : FadeTransition(
                      opacity: _fadeIn,
                      child: RefreshIndicator(
                        onRefresh: _loadAddresses,
                        color: AppTheme.primary,
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: _AddressHeader(
                                addressCount: addressList.length,
                                onAddTap: _navigateToMap,
                              ),
                            ),
                            if (hasAddresses)
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (ctx, i) {
                                      final address = addressList[i];
                                      final isSelected =
                                          authProvider.selectedAddress.name ==
                                              address.name;
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: AddressItem(
                                          addressItem: address,
                                          isSelected: isSelected,
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            authProvider.selectAddress(address);
                                          },
                                          onRemoved: _loadAddresses,
                                        ),
                                      );
                                    },
                                    childCount: addressList.length,
                                  ),
                                ),
                              )
                            else
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: _EmptyAddressState(
                                  onAddTap: _navigateToMap,
                                ),
                              ),
                            // Space so the last row clears the extended FAB
                            // (FAB sits above [bottomNavigationBar]).
                            SliverPadding(
                              padding: EdgeInsets.only(
                                bottom: hasAddresses ? 88 : 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomActionBar(
        isActive: isSelectionValid,
        onTap: _handleContinue,
      ),
      floatingActionButton: hasAddresses
          ? FloatingActionButton.extended(
              onPressed: _navigateToMap,
              backgroundColor: AppTheme.primary,
              elevation: 6,
              icon: Icon(
                Icons.add_location_alt_rounded,
                color: Colors.white,
              ),
              label: Text(
                l10n.addNewAddressLabel,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

/// Header section: title, subtitle, and address count badge.
class _AddressHeader extends StatelessWidget {
  const _AddressHeader({
    required this.addressCount,
    required this.onAddTap,
  });

  final int addressCount;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.selectAddressTitle,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: context.colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.selectAddressSubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (addressCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.addressCount(addressCount),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          if (addressCount > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.swipe_left_rounded,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.swipeToDelete,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty state with illustration and add button.
class _EmptyAddressState extends StatelessWidget {
  const _EmptyAddressState({required this.onAddTap});

  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_location_alt_outlined,
                size: 60,
                color: AppTheme.primary.withOpacity(0.35),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.addressListEmptyTitle,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: context.colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addressListEmptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onAddTap,
              icon: Icon(Icons.add_rounded),
              label: Text(l10n.addNewAddressLabel),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                textStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sticky bottom bar with continue button.
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.isActive,
    required this.onTap,
  });

  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: isActive ? onTap : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: ButtonBottom(
            width: double.infinity,
            height: 54,
            text: l10n.continueLabel,
            isActive: isActive,
            icon: Icons.arrow_forward_rounded,
          ),
        ),
      ),
    );
  }
}

/// Multi-step progress indicator for the waste request flow.
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                height: 2.5,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  gradient: stepBefore < currentStep
                      ? LinearGradient(
                          colors: [
                            AppTheme.primary,
                            AppTheme.primary.withOpacity(0.6),
                          ],
                        )
                      : null,
                  color: stepBefore < currentStep ? null : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
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
                width: isActive ? 36 : 32,
                height: isActive ? 36 : 32,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.primary
                      : isActive
                          ? AppTheme.primary.withOpacity(0.12)
                          : Colors.grey.shade100,
                  shape: BoxShape.circle,
                  border: isActive
                      ? Border.all(color: AppTheme.primary, width: 2.5)
                      : null,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : _steps[stepIndex],
                  size: isActive ? 18 : 16,
                  color: isCompleted
                      ? Colors.white
                      : isActive
                          ? AppTheme.primary
                          : Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                labels[stepIndex],
                style: TextStyle(
                  fontSize: isActive ? 11 : 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive || isCompleted
                      ? AppTheme.primary
                      : Colors.grey.shade400,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
