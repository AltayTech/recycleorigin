import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/region.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buton_bottom.dart';
import '../../../core/widgets/main_drawer.dart';
import '../../auth_feature/presentation/providers/authentication_provider.dart';
import '../business/entities/address.dart';
import '../business/entities/price_weight.dart';
import '../business/entities/wasteCart.dart';
import '../business/collect_hour_schedule.dart';
import '../business/entities/collect_hour.dart';
import 'providers/wastes.dart';
import 'waste_request_send_screen.dart';
import 'widgets/custom_dialog_enter.dart';
import 'widgets/date_selector.dart';
import 'widgets/request_summary_card.dart';
import 'widgets/time_selector.dart';

class WasteRequestDateScreen extends StatefulWidget {
  static const routeName = '/waste_request_date_screen';

  const WasteRequestDateScreen({Key? key}) : super(key: key);

  @override
  State<WasteRequestDateScreen> createState() => _WasteRequestDateScreenState();
}

class _WasteRequestDateScreenState extends State<WasteRequestDateScreen> {
  bool _isLoading = true;
  bool _isInit = true;

  // Data
  List<WasteCart> wasteCartItems = [];
  int totalPrice = 0;
  int totalWeight = 0;
  List<DateTime> dateList = [];

  // Selections
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
      final authProvider =
          Provider.of<AuthenticationProvider>(context, listen: false);
      selectedAddress = authProvider.selectedAddress;

      // Fetch region data
      await authProvider.retrieveRegion(selectedAddress.region.term_id);

      if (!mounted) return;

      final wasteProvider = Provider.of<Wastes>(context, listen: false);

      setState(() {
        selectedRegion = authProvider.regionData;
        wasteCartItems = wasteProvider.wasteCartItems;

        _calculateTotals();
        _generateDates(7); // Generate next 7 days

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data. Please try again.')),
        );
      }
    }
  }

  void _calculateTotals() {
    totalPrice = 0;
    totalWeight = 0;

    for (var item in wasteCartItems) {
      if (item.prices.isNotEmpty) {
        String priceStr = _getPriceForWeight(item.prices, item.weight);
        int itemPrice = int.tryParse(priceStr) ?? 0;

        totalPrice += itemPrice * item.weight;
        totalWeight += item.weight;
      }
    }
  }

  String _getPriceForWeight(List<PriceWeight> prices, int weight) {
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
    // Set default selection to first available day if list is empty
    if (dateList.isNotEmpty && !_isSameDay(_selectedDay, dateList.first)) {
      // Optional: auto-select first day
      // _selectedDay = dateList.first;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Builds the legacy "HH-HH" segment for the request payload from ISO or HH:mm.
  String? _hourKeyForSubmit(String raw) {
    final DateTime? parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      return parsed.hour.toString().padLeft(2, '0');
    }
    if (raw.length >= 2) {
      return raw.substring(0, 2);
    }
    return null;
  }

  void _handleDateSelection(DateTime date) {
    setState(() {
      _selectedDay = date;
      final List<CollectHour> forDay = _hoursForSelectedDay();
      if (_selectedStartHour != null &&
          !forDay.any((CollectHour h) => h.start == _selectedStartHour)) {
        _selectedStartHour = null;
        _selectedEndHour = null;
      }
    });
  }

  List<CollectHour> _hoursForSelectedDay() {
    return (selectedRegion?.collect_hour ?? <CollectHour>[])
        .where((CollectHour h) => h.collect_hour_status)
        .where((CollectHour h) =>
            CollectHourSchedule.appliesOnDay(h, _selectedDay))
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
        title: 'Login',
        buttonText: 'Login',
        description: 'Please login to continue',
        image: Image.asset('assets/images/main_page_request_ic.png'),
      ),
    );
  }

  void _submit() {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);

    if (_selectedStartHour == null || _selectedEndHour == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a collection hour'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!authProvider.isAuth) {
      _showLoginDialog();
      return;
    }

    // Save to provider
    final wasteProvider = Provider.of<Wastes>(context, listen: false);
    final String? startKey = _hourKeyForSubmit(_selectedStartHour!);
    final String? endKey = _hourKeyForSubmit(_selectedEndHour!);
    if (startKey == null || endKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid time selection')),
      );
      return;
    }
    final String formattedHours = '$startKey-$endKey';

    wasteProvider.selectedHours = formattedHours;
    wasteProvider.selectedDay = _selectedDay;

    Navigator.of(context).pushNamed(WasteRequestSendScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(
          'Collect Date',
          style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: const IconThemeData(color: AppTheme.appBarIconColor),
      ),
      endDrawer: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
        child: MainDrawer(),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Request Details',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.h1,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
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
                            isLoading:
                                false, // Already handled by parent loading
                          ),
                          const SizedBox(height: 80), // Space for button
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, -4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: _submit,
                      child: ButtonBottom(
                        width: double.infinity,
                        height: 50,
                        text: 'Continue',
                        isActive: _selectedStartHour !=
                            null, // Only active if hour selected (date is auto-selected)
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
