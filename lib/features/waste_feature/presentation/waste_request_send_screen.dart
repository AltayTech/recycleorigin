import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart' as intl;
import 'package:recycleorigin/core/widgets/buton_bottom.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/collect.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/collect_time.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/pasmand.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/price_weight.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/request_address.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/request_waste.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/wasteCart.dart';

import '../../../core/logic/en_to_ar_number_convertor.dart';
import '../../../core/models/region.dart';
import '../../../core/screens/navigation_bottom_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_dialog_send_request.dart';
import '../../../core/widgets/main_drawer.dart';
import '../../auth_feature/presentation/bloc/auth_bloc.dart';
import '../business/entities/address.dart';
import 'bloc/wastes_bloc.dart';
import 'widgets/custom_dialog_enter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/l10n/l10n.dart';

class WasteRequestSendScreen extends StatefulWidget {
  static const routeName = '/waste_request_send_screen';

  const WasteRequestSendScreen({super.key});

  @override
  State<WasteRequestSendScreen> createState() =>
      _WasteRequestSendScreenState();
}

class _WasteRequestSendScreenState
    extends State<WasteRequestSendScreen> {
  List<WasteCart> _wasteCartItems = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _isInit = true;

  int _totalPrice = 0;
  int _totalWeight = 0;

  late Address _selectedAddress;
  late Region _selectedRegion;
  late String _selectedHours = '0';
  late DateTime _selectedDay = DateTime.now();
  late RequestWaste _requestWaste;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _loadData();
      _isInit = false;
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthBloc>();
      final wastesProvider = context.read<WastesBloc>();

      _selectedRegion = authProvider.regionData;
      _selectedHours = wastesProvider.selectedHours;
      _selectedDay = wastesProvider.selectedDay;
      _selectedAddress = authProvider.selectedAddress;

      await authProvider.retrieveRegion(
        _selectedAddress.region.term_id,
      );
      await authProvider.checkCompleted();

      _wasteCartItems = wastesProvider.wasteCartItems;
      _calculateTotals();
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _calculateTotals() {
    _totalPrice = 0;
    _totalWeight = 0;

    for (var item in _wasteCartItems) {
      if (item.prices.isNotEmpty) {
        int price = int.parse(
          _getPrice(item.prices, item.weight),
        );
        _totalPrice += price * item.weight;
        _totalWeight += item.weight;
      }
    }
  }

  String _getPrice(List<PriceWeight> prices, int weight) {
    for (var priceWeight in prices) {
      if (weight > int.parse(priceWeight.weight)) {
        return priceWeight.price;
      }
    }
    return prices.isNotEmpty ? prices.first.price : '0';
  }

  Future<void> _createRequest() async {
    List<Collect> collectList = _wasteCartItems.map((item) {
      return Collect(
        estimated_weight: item.weight.toString(),
        estimated_price: _getPrice(item.prices, item.weight),
        pasmand: Pasmand(id: item.id, post_title: item.name),
        exact_weight: '',
        exact_price: '',
      );
    }).toList();

    final formattedDate = intl.DateFormat(
      'EEEE d MMMM',
      'en_US',
    ).format(_selectedDay);

    _requestWaste = RequestWaste(
      collect_date: CollectTime(
        time: _selectedHours,
        day: formattedDate,
      ),
      address_data: RequestAddress(
        name: _selectedAddress.name,
        address: _selectedAddress.address,
        region: _selectedAddress.region.term_id.toString(),
        latitude: _selectedAddress.latitude,
        longitude: _selectedAddress.longitude,
      ),
      collect_list: collectList,
    );
  }

  Future<void> _handleConfirm() async {
    final authProvider = context.read<AuthBloc>();
    final isLogin = authProvider.isAuth;
    final l10n = context.l10n;

    if (_wasteCartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cartIsEmpty),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!isLogin) {
      _showDialog(
        CustomDialogEnter(
          title: l10n.login,
          buttonText: l10n.goToLoginScreenButton,
          description: l10n.loginToContinueShort,
          image: Image.asset(
            'assets/images/main_page_request_ic.png',
          ),
        ),
      );
      return;
    }

    final confirmed = await _showConfirmationSheet();
    if (confirmed != true) return;

    setState(() => _isSending = true);
    try {
      await _createRequest();
      await context.read<WastesBloc>().sendRequest(
            _requestWaste,
            isLogin,
          );

      if (!mounted) return;

      await CustomDialogSendRequest.show(
        context,
        description: l10n.wasteRequestSentSuccess,
        buttonText: l10n.okLabel,
      );

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        NavigationBottomScreen.routeName,
        (route) => false,
      );
    } catch (e) {
      debugPrint('Error sending request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${l10n.failedSendRequestPrefix}$e',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<bool?> _showConfirmationSheet() {
    final l10n = context.l10n;

    return showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                color: AppTheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.confirmRequestTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.h1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.confirmRequestSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      l10n.cancelLabel,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.confirmLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog(Widget dialog) {
    showDialog(
      context: context,
      builder: (ctx) => dialog,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(
          l10n.registerWasteRequestAppBarTitle,
          style: const TextStyle(
            color: AppTheme.appBarIconColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: const IconThemeData(
          color: AppTheme.appBarIconColor,
        ),
        elevation: 0,
      ),
      endDrawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
        ),
        child: MainDrawer(),
      ),
      body: _isLoading
          ? Center(
              child: SpinKitFadingCircle(
                color: AppTheme.primary,
                size: 50.0,
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  _StepProgressBar(currentStep: 3),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          _SectionTitle(
                            icon: Icons.summarize_rounded,
                            label: l10n.requestSummaryTitle,
                          ),
                          const SizedBox(height: 12),
                          _OrderSummaryCard(
                            count: _wasteCartItems.length,
                            totalPrice: _totalPrice,
                            totalWeight: _totalWeight,
                          ),
                          const SizedBox(height: 20),
                          _SectionTitle(
                            icon: Icons.event_note_rounded,
                            label:
                                l10n.requestDetailsSectionTitle,
                          ),
                          const SizedBox(height: 12),
                          _DetailsReviewCard(
                            date: _selectedDay,
                            hours: _selectedHours,
                            regionName: _selectedRegion.name,
                            addressName:
                                _selectedAddress.name,
                            addressFull:
                                _selectedAddress.address,
                          ),
                          const SizedBox(height: 20),
                          _SectionTitle(
                            icon: Icons.recycling_rounded,
                            label: l10n.wasteItemsSection,
                          ),
                          const SizedBox(height: 12),
                          ..._wasteCartItems.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: 10,
                              ),
                              child: _WasteItemReviewTile(
                                item: item,
                                getPrice: _getPrice,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomBar(),
                ],
              ),
            ),
    );
  }

  Widget _buildBottomBar() {
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
      child: _isSending
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CircularProgressIndicator(),
              ),
            )
          : InkWell(
              onTap: _handleConfirm,
              borderRadius:
                  BorderRadius.circular(AppTheme.radiusSm),
              child: ButtonBottom(
                width: double.infinity,
                height: 52,
                text: l10n.confirmLabel,
                isActive: _wasteCartItems.isNotEmpty,
                icon: Icons.send_rounded,
              ),
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: AppTheme.h1,
          ),
        ),
      ],
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.count,
    required this.totalPrice,
    required this.totalWeight,
  });

  final int count;
  final int totalPrice;
  final int totalWeight;

  @override
  Widget build(BuildContext context) {
    final fmt = intl.NumberFormat.decimalPattern();
    final converter = EnArConvertor();
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _SummaryRow(
            icon: Icons.inventory_2_rounded,
            iconColor: AppTheme.primary,
            label: l10n.numberFieldLabel,
            value: converter.replaceArNumber(count.toString()),
          ),
          Divider(height: 20, color: Colors.grey.shade100),
          _SummaryRow(
            icon: Icons.monetization_on_rounded,
            iconColor: const Color(0xFFE5A100),
            label: l10n.totalPriceFieldLabel,
            value: converter.replaceArNumber(
              fmt.format(totalPrice),
            ),
            suffix: l10n.parentheticalUsd,
          ),
          Divider(height: 20, color: Colors.grey.shade100),
          _SummaryRow(
            icon: Icons.scale_rounded,
            iconColor: const Color(0xFF8B5CF6),
            label: l10n.totalWeightFieldLabel,
            value: converter.replaceArNumber(
              totalWeight.toString(),
            ),
            suffix: l10n.parentheticalKg,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.suffix,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (suffix != null)
                Text(
                  suffix!,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.h1,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _DetailsReviewCard extends StatelessWidget {
  const _DetailsReviewCard({
    required this.date,
    required this.hours,
    required this.regionName,
    required this.addressName,
    required this.addressFull,
  });

  final DateTime date;
  final String hours;
  final String regionName;
  final String addressName;
  final String addressFull;

  @override
  Widget build(BuildContext context) {
    final converter = EnArConvertor();
    final locale = Localizations.localeOf(context).toString();
    final dateHeading =
        intl.DateFormat('EEEE', locale).format(date);
    final dateRest =
        intl.DateFormat('d MMMM', locale).format(date);
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.calendar_month_rounded,
            iconColor: const Color(0xFF3B82F6),
            label: l10n.collectDateFieldLabel,
            value:
                '$dateHeading  ${converter.replaceArNumber(dateRest)}',
          ),
          Divider(height: 20, color: Colors.grey.shade100),
          _DetailRow(
            icon: Icons.schedule_rounded,
            iconColor: const Color(0xFF8B5CF6),
            label: l10n.collectHourFieldLabel,
            value: hours,
          ),
          Divider(height: 20, color: Colors.grey.shade100),
          _DetailRow(
            icon: Icons.location_on_rounded,
            iconColor: const Color(0xFFEF4444),
            label: l10n.regionColonPrefix,
            value: regionName,
          ),
          if (addressName.isNotEmpty) ...[
            Divider(height: 20, color: Colors.grey.shade100),
            _DetailRow(
              icon: Icons.home_rounded,
              iconColor: const Color(0xFF10B981),
              label: l10n.addressLabel,
              value: addressName,
              subtitle: addressFull,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.h1,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _WasteItemReviewTile extends StatelessWidget {
  const _WasteItemReviewTile({
    required this.item,
    required this.getPrice,
  });

  final WasteCart item;
  final String Function(List<PriceWeight>, int) getPrice;

  @override
  Widget build(BuildContext context) {
    final converter = EnArConvertor();
    final fmt = intl.NumberFormat.decimalPattern();
    final unitPrice =
        int.tryParse(getPrice(item.prices, item.weight)) ?? 0;
    final total = unitPrice * item.weight;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: FadeInImage(
              placeholder: const AssetImage(
                'assets/images/main_page_request_ic.png',
              ),
              image: NetworkImage(
                item.featured_image.sizes.medium,
              ),
              fit: BoxFit.cover,
              imageErrorBuilder: (_, __, ___) => Icon(
                Icons.recycling_rounded,
                size: 22,
                color: AppTheme.primary.withOpacity(0.4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: AppTheme.h1,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${converter.replaceArNumber(item.weight.toString())} kg',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${converter.replaceArNumber(fmt.format(total))} \$',
            style: const TextStyle(
              color: AppTheme.h1,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

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
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 14,
      ),
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
        children:
            List.generate(_steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final stepBefore = index ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(
                  horizontal: 4,
                ),
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
                      ? Border.all(
                          color: AppTheme.primary,
                          width: 2,
                        )
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
                  fontWeight: isActive
                      ? FontWeight.w700
                      : FontWeight.w500,
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
