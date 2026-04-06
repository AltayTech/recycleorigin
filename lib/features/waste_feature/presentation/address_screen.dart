import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buton_bottom.dart';
import '../../../core/widgets/main_drawer.dart';
import '../../auth_feature/presentation/bloc/auth_bloc.dart';
import 'pages/map_screen.dart';
import 'waste_request_date_screen.dart';
import 'widgets/address_item.dart';
import 'widgets/custom_dialog_enter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/l10n/l10n.dart';

class AddressScreen extends StatefulWidget {
  static const routeName = '/address_screen';

  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAddresses();
    });
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthBloc>().getAddresses();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${context.l10n.failedLoadAddressesPrefix}$e',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.pleaseSelectAddress),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (!isLogin) {
      _showLoginDialog();
    } else {
      Navigator.of(context)
          .pushNamed(WasteRequestDateScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthBloc>();
    final addressList = authProvider.addressItems;
    final hasAddresses = addressList.isNotEmpty;
    final isSelectionValid =
        authProvider.selectedAddress.name.isNotEmpty;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(
          l10n.addressListTitle,
          style: const TextStyle(
            color: AppTheme.appBarIconColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: const IconThemeData(color: AppTheme.appBarIconColor),
        elevation: 0,
      ),
      endDrawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
        ),
        child: MainDrawer(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _StepProgressBar(currentStep: 1),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: SpinKitFadingCircle(
                        color: AppTheme.primary,
                        size: 50.0,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadAddresses,
                      child: CustomScrollView(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: _buildHeader(context),
                          ),
                          if (hasAddresses)
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              sliver: SliverList(
                                delegate:
                                    SliverChildBuilderDelegate(
                                  (ctx, i) {
                                    final address = addressList[i];
                                    final isSelected = authProvider
                                            .selectedAddress.name ==
                                        address.name;
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: AddressItem(
                                        addressItem: address,
                                        isSelected: isSelected,
                                        onTap: () {
                                          authProvider
                                              .selectAddress(
                                            address,
                                          );
                                        },
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
                              child: _buildEmptyState(context),
                            ),
                          const SliverPadding(
                            padding: EdgeInsets.only(bottom: 100),
                          ),
                        ],
                      ),
                    ),
            ),
            _buildBottomBar(context, isSelectionValid),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(MapScreen.routeName);
        },
        backgroundColor: AppTheme.primary,
        elevation: 4,
        child: const Icon(
          Icons.add_location_alt_rounded,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.selectAddressTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.h1,
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
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_location_alt_outlined,
              size: 56,
              color: AppTheme.primary.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.addressListEmptyTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.h1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addressListEmptySubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(MapScreen.routeName);
            },
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.addNewAddressLabel),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isActive) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: isActive ? _handleContinue : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: ButtonBottom(
            width: double.infinity,
            height: 52,
            text: l10n.continueLabel,
            isActive: isActive,
            icon: Icons.arrow_forward_rounded,
          ),
        ),
      ),
    );
  }
}

/// Reusable step indicator for the waste request flow.
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
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: stepBefore < currentStep
                      ? AppTheme.primary
                      : Colors.grey.shade300,
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
                          ? AppTheme.primary.withOpacity(0.12)
                          : Colors.grey.shade100,
                  shape: BoxShape.circle,
                  border: isActive
                      ? Border.all(color: AppTheme.primary, width: 2)
                      : null,
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_rounded
                      : _steps[stepIndex],
                  size: 16,
                  color: isCompleted
                      ? Colors.white
                      : isActive
                          ? AppTheme.primary
                          : Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                labels[stepIndex],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w500,
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
