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

  const WasteRequestSendScreen({Key? key}) : super(key: key);

  @override
  _WasteRequestSendScreenState createState() => _WasteRequestSendScreenState();
}

class _WasteRequestSendScreenState extends State<WasteRequestSendScreen> {
  List<WasteCart> _wasteCartItems = [];
  bool _isLoading = true;
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

      await authProvider.retrieveRegion(_selectedAddress.region.term_id);
      await authProvider.checkCompleted();

      _wasteCartItems = wastesProvider.wasteCartItems;
      _calculateTotals();
    } catch (e) {
      debugPrint('Error loading data: $e');
      // Handle error appropriately
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _calculateTotals() {
    _totalPrice = 0;
    _totalWeight = 0;

    for (var item in _wasteCartItems) {
      if (item.prices.isNotEmpty) {
        int price = int.parse(_getPrice(item.prices, item.weight));
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
    // Default to the first price if no condition met or list is not empty
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

    final String formattedDate = intl.DateFormat(
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

    if (_wasteCartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.cartIsEmpty,
              style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!isLogin) {
      _showDialog(
        CustomDialogEnter(
          title: context.l10n.login,
          buttonText: context.l10n.goToLoginScreenButton,
          description: context.l10n.loginToContinueShort,
          image: Image.asset('assets/images/main_page_request_ic.png'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _createRequest();
      await context
          .read<WastesBloc>()
          .sendRequest(_requestWaste, isLogin);

      if (!mounted) return;

      await CustomDialogSendRequest.show(
        context,
        description: context.l10n.wasteRequestSentSuccess,
        buttonText: context.l10n.okLabel,
      );

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        NavigationBottomScreen.routeName,
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      debugPrint("Error sending request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${context.l10n.failedSendRequestPrefix}$e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDialog(Widget dialog) {
    showDialog(
      context: context,
      builder: (ctx) => dialog,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.registerWasteRequestAppBarTitle,
          style: const TextStyle(
            color: AppTheme.appBarIconColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: const IconThemeData(color: AppTheme.appBarIconColor),
      ),
      endDrawer: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
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
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            context.l10n.requestDetailsSectionTitle,
                            style: const TextStyle(
                              color: AppTheme.h1,
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _SummaryCard(
                            count: _wasteCartItems.length,
                            totalPrice: _totalPrice,
                            totalWeight: _totalWeight,
                          ),
                          const SizedBox(height: 16),
                          _DetailsCard(
                            date: _selectedDay,
                            hours: _selectedHours,
                            regionName: _selectedRegion.name,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: InkWell(
                      onTap: _handleConfirm,
                      borderRadius: BorderRadius.circular(5),
                      child: ButtonBottom(
                        width: double.infinity,
                        height: 56, // Standard button height
                        text: context.l10n.confirmLabel,
                        isActive: _wasteCartItems.isNotEmpty,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int count;
  final int totalPrice;
  final int totalWeight;

  const _SummaryCard({
    Key? key,
    required this.count,
    required this.totalPrice,
    required this.totalWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = intl.NumberFormat.decimalPattern();
    final converter = EnArConvertor();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppTheme.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildRow(
              context,
              iconPath: 'assets/images/main_page_request_ic.png',
              label: context.l10n.numberFieldLabel,
              value: converter.replaceArNumber(count.toString()),
            ),
            const Divider(),
            _buildRow(
              context,
              iconPath: 'assets/images/waste_cart_price_ic.png',
              label: context.l10n.totalPriceFieldLabel,
              subLabel: context.l10n.parentheticalUsd,
              value:
                  converter.replaceArNumber(currencyFormat.format(totalPrice)),
              iconColor: Colors.yellow[700],
            ),
            const Divider(),
            _buildRow(
              context,
              iconPath: 'assets/images/waste_cart_weight_ic.png',
              label: context.l10n.totalWeightFieldLabel,
              subLabel: context.l10n.parentheticalKg,
              value: converter.replaceArNumber(totalWeight.toString()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required String iconPath,
    required String label,
    String? subLabel,
    required String value,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Image.asset(
            iconPath,
            height: 24,
            width: 24,
            color: iconColor,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(color: AppTheme.grey, fontSize: 14),
          ),
          if (subLabel != null) ...[
            const SizedBox(width: 4),
            Text(
              subLabel,
              style: TextStyle(color: AppTheme.grey, fontSize: 12),
            ),
          ],
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.h1,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final DateTime date;
  final String hours;
  final String regionName;

  const _DetailsCard({
    Key? key,
    required this.date,
    required this.hours,
    required this.regionName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final converter = EnArConvertor();
    final locale = Localizations.localeOf(context).toString();
    final dateHeading = intl.DateFormat('EEEE', locale).format(date);
    final dateRest = intl.DateFormat('d MMMM', locale).format(date);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppTheme.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailRow(
              context,
              icon: Icons.date_range,
              label: context.l10n.collectDateFieldLabel,
              valueWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dateHeading,
                    style: TextStyle(
                      color: AppTheme.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    converter.replaceArNumber(dateRest),
                    style: TextStyle(
                      color: AppTheme.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            _buildDetailRow(
              context,
              icon: Icons.access_time,
              label: context.l10n.collectHourFieldLabel,
              value: hours,
            ),
            const Divider(),
            _buildDetailRow(
              context,
              icon: Icons.location_on,
              label: context.l10n.regionColonPrefix,
              value: regionName,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? value,
    Widget? valueWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppTheme.grey),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(color: AppTheme.grey, fontSize: 15),
          ),
          const Spacer(),
          valueWidget ??
              Text(
                value ?? '',
                style: TextStyle(
                  color: AppTheme.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
        ],
      ),
    );
  }
}
