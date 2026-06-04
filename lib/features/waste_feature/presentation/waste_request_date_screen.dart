import 'package:flutter/material.dart';
import '../../../core/models/region.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_context_extensions.dart';
import '../../../core/widgets/buton_bottom.dart';
import '../../../core/widgets/drawer_or_back_leading.dart';
import '../../auth_feature/presentation/bloc/auth_bloc.dart';
import '../business/entities/address.dart';
import '../business/entities/price_weight.dart';
import '../business/entities/wasteCart.dart';
import '../business/collect_hour_schedule.dart';
import '../business/entities/collect_hour.dart';
import 'bloc/wastes_bloc.dart';
import 'waste_request_send_screen.dart';
import 'widgets/custom_dialog_enter.dart';
import 'widgets/date_selector.dart';
import 'widgets/request_summary_card.dart';
import 'widgets/time_selector.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/l10n/l10n.dart';

class WasteRequestDateScreen extends StatefulWidget {
  static const routeName = '/waste_request_date_screen';

  const WasteRequestDateScreen({super.key});

  @override
  State<WasteRequestDateScreen> createState() => _WasteRequestDateScreenState();
}

class _WasteRequestDateScreenState extends State<WasteRequestDateScreen> {
  bool _isLoading = true;
  bool _isInit = true;

  List<WasteCart> wasteCartItems = [];
  int totalPrice = 0;
  int totalWeight = 0;
  List<DateTime> dateList = [];

  late Address selectedAddress;
  Region? selectedRegion;
  DateTime _selectedDay = DateTime.now();
  String? _selectedStartHour;
  String? _selectedEndHour;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _loadData();
      _isInit = false;
    }
  }

  Future<void> _loadData() async {
    try {
      final authProvider = context.read<AuthBloc>();
      selectedAddress = authProvider.selectedAddress;

      await authProvider.retrieveRegion(selectedAddress.region.term_id);

      if (!mounted) return;

      final wasteProvider = context.read<WastesBloc>();

      setState(() {
        selectedRegion = authProvider.regionData;
        wasteCartItems = wasteProvider.wasteCartItems;

        _calculateTotals();
        _generateDates(7);

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.failedToLoadDataRetry),
            backgroundColor: context.appColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _calculateTotals() {
    totalPrice = 0;
    totalWeight = 0;

    for (var item in wasteCartItems) {
      if (item.prices.isNotEmpty) {
        final priceStr = _getPriceForWeight(item.prices, item.weight);
        final itemPrice = int.tryParse(priceStr) ?? 0;
        totalPrice += itemPrice * item.weight;
        totalWeight += item.weight;
      }
    }
  }

  String _getPriceForWeight(
    List<PriceWeight> prices,
    int weight,
  ) {
    String price = '0';
    for (var p in prices) {
      if (weight > int.parse(p.weight)) {
        price = p.price;
      } else {
        price = p.price;
        break;
      }
    }
    return price;
  }

  void _generateDates(int days) {
    dateList.clear();
    final now = DateTime.now();
    for (int i = 0; i < days; i++) {
      dateList.add(now.add(Duration(days: i + 1)));
    }
  }

  String? _hourKeyForSubmit(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      return parsed.hour.toString().padLeft(2, '0');
    }
    if (raw.length >= 2) return raw.substring(0, 2);
    return null;
  }

  void _handleDateSelection(DateTime date) {
    setState(() {
      _selectedDay = date;
      final forDay = _hoursForSelectedDay();
      if (_selectedStartHour != null &&
          !forDay.any((h) => h.start == _selectedStartHour)) {
        _selectedStartHour = null;
        _selectedEndHour = null;
      }
    });
  }

  List<CollectHour> _hoursForSelectedDay() {
    return (selectedRegion?.collect_hour ?? <CollectHour>[])
        .where((h) => h.collect_hour_status)
        .where(
          (h) => CollectHourSchedule.appliesOnDay(h, _selectedDay),
        )
        .toList();
  }

  void _handleHourSelection(CollectHour hour) {
    setState(() {
      _selectedStartHour = hour.start;
      _selectedEndHour = hour.end;
    });
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

  void _submit() {
    final authProvider = context.read<AuthBloc>();
    final l10n = context.l10n;

    if (_selectedStartHour == null || _selectedEndHour == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectCollectionHour),
          backgroundColor: context.appColors.warning,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!authProvider.isAuth) {
      _showLoginDialog();
      return;
    }

    final wasteProvider = context.read<WastesBloc>();
    final startKey = _hourKeyForSubmit(_selectedStartHour!);
    final endKey = _hourKeyForSubmit(_selectedEndHour!);
    if (startKey == null || endKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.invalidTimeSelection),
          backgroundColor: context.appColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    wasteProvider.selectedHours = '$startKey-$endKey';
    wasteProvider.selectedDay = _selectedDay;

    Navigator.of(context).pushNamed(WasteRequestSendScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasTimeSelected = _selectedStartHour != null;

    return Scaffold(
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        title: Text(
          l10n.collectDateFieldLabel,
          style: const TextStyle(
            color: AppTheme.appBarIconColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: const IconThemeData(
          color: AppTheme.appBarIconColor,
        ),
      ),
      drawer: mainDrawerIfRootRoute(context),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _StepProgressBar(currentStep: 2),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          RequestSummaryCard(
                            itemCount: wasteCartItems.length,
                            totalPrice: totalPrice,
                            totalWeight: totalWeight,
                          ),
                          const SizedBox(height: 24),
                          DateSelector(
                            dateList: dateList,
                            selectedDate: _selectedDay,
                            onDateSelected: _handleDateSelection,
                          ),
                          const SizedBox(height: 24),
                          TimeSelector(
                            hours: _hoursForSelectedDay(),
                            selectedStartHour: _selectedStartHour,
                            onHourSelected: _handleHourSelection,
                            isLoading: false,
                          ),
                          if (hasTimeSelected) ...[
                            const SizedBox(height: 20),
                            _SelectedTimeConfirmation(
                              startHour: _selectedStartHour!,
                              endHour: _selectedEndHour!,
                            ),
                          ],
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomBar(hasTimeSelected),
                ],
              ),
      ),
    );
  }

  Widget _buildBottomBar(bool isActive) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: InkWell(
        onTap: isActive ? _submit : null,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: ButtonBottom(
          width: double.infinity,
          height: 52,
          text: l10n.continueLabel,
          isActive: isActive,
          icon: Icons.arrow_forward_rounded,
        ),
      ),
    );
  }
}

class _SelectedTimeConfirmation extends StatelessWidget {
  const _SelectedTimeConfirmation({
    required this.startHour,
    required this.endHour,
  });

  final String startHour;
  final String endHour;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: AppTheme.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.selectedTimeSlotLabel,
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
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
                margin: const EdgeInsets.symmetric(
                  horizontal: 4,
                ),
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
                          ? AppTheme.primary.withOpacity(0.12)
                          : context.appColors.divider,
                  shape: BoxShape.circle,
                  border: isActive
                      ? Border.all(
                          color: AppTheme.primary,
                          width: 2,
                        )
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
