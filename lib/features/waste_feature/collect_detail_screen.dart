import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:recycleorigin/core/logic/en_to_ar_number_convertor.dart';
import 'package:recycleorigin/features/collect_feature/presentation/widgets/collect_details_collects_item.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/request_waste_item.dart';
import 'package:recycleorigin/features/waste_feature/presentation/providers/wastes.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';

class CollectDetailScreen extends StatefulWidget {
  static const routeName = '/collectDetailScreen';

  const CollectDetailScreen({Key? key}) : super(key: key);

  @override
  _CollectDetailScreenState createState() => _CollectDetailScreenState();
}

class _CollectDetailScreenState extends State<CollectDetailScreen> {
  bool _isLoading = false;
  bool _isInit = true;
  bool _hasError = false;
  late RequestWasteItem _loadedCollect;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _loadData();
    }
    _isInit = false;
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final productId = ModalRoute.of(context)?.settings.arguments as int?;
      if (productId != null) {
        await Provider.of<Wastes>(context, listen: false)
            .retrieveCollectItem(productId);
        if (mounted) {
          _loadedCollect =
              Provider.of<Wastes>(context, listen: false).requestWasteItem;
        }
      } else {
        throw Exception("Invalid Product ID");
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          if (_isLoading)
            SliverFillRemaining(
              child: Center(
                child: SpinKitFadingCircle(
                  color: AppTheme.primary,
                  size: 50.0,
                ),
              ),
            )
          else if (_hasError)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    const Text("Something went wrong",
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text("Retry"),
                    )
                  ],
                ),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatusHeaderCard(loadedCollect: _loadedCollect),
                    const SizedBox(height: 16),
                    if (_hasDriverInfo()) ...[
                      const _SectionHeader(title: 'Driver Information'),
                      const SizedBox(height: 8),
                      _DriverInfoCard(loadedCollect: _loadedCollect),
                      const SizedBox(height: 24),
                    ],
                    const _SectionHeader(title: 'Order Summary'),
                    const SizedBox(height: 8),
                    _SummaryGridCard(loadedCollect: _loadedCollect),
                    const SizedBox(height: 24),
                    const _SectionHeader(title: 'Details'),
                    const SizedBox(height: 8),
                    _DetailsCard(loadedCollect: _loadedCollect),
                    const SizedBox(height: 24),
                    const _SectionHeader(title: 'Waste Items'),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _WasteListSliver(loadedCollect: _loadedCollect),
            const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
          ]
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.appBarColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      title: const Text(
        'Collect Details',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  bool _hasDriverInfo() {
    try {
      return _loadedCollect.driver.driver_data.fname.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 16.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _StatusHeaderCard extends StatelessWidget {
  final RequestWasteItem loadedCollect;

  const _StatusHeaderCard({required this.loadedCollect});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_turned_in,
                color: AppTheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Status',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loadedCollect.status.name,
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverInfoCard extends StatelessWidget {
  final RequestWasteItem loadedCollect;

  const _DriverInfoCard({required this.loadedCollect});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final driver = loadedCollect.driver;
    final driverData = driver.driver_data;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200, width: 2),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(driverData.driver_image.sizes.medium),
                      onError: (_, __) => const Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${driverData.fname} ${driverData.lname}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        driver.car.name,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                if (driverData.mobile.isNotEmpty || driverData.phone.isNotEmpty)
                  IconButton(
                    onPressed: () => _makePhoneCall(driverData.mobile.isNotEmpty
                        ? driverData.mobile
                        : driverData.phone),
                    icon: const Icon(Icons.phone),
                    color: Colors.green,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.green.withOpacity(0.1),
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDriverStat('Plate Number',
                    EnArConvertor().replaceArNumber(driver.car_number)),
                _buildDriverStat('Car Color', driver.car_color.name),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _SummaryGridCard extends StatelessWidget {
  final RequestWasteItem loadedCollect;

  const _SummaryGridCard({required this.loadedCollect});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = intl.NumberFormat.decimalPattern();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildComparisonRow(
              context,
              'Total Price (\$)',
              loadedCollect.total_collects_price.estimated,
              loadedCollect.total_collects_price.exact,
              currencyFormat,
              icon: Icons.monetization_on_outlined,
              isCurrency: true,
            ),
            const Divider(height: 24),
            _buildComparisonRow(
              context,
              'Total Weight (Kg)',
              loadedCollect.total_collects_weight.estimated,
              loadedCollect.total_collects_weight.exact,
              currencyFormat,
              icon: Icons.scale_outlined,
            ),
            const Divider(height: 24),
            _buildComparisonRow(
              context,
              'Items Count',
              loadedCollect.total_collects_number.estimated,
              loadedCollect.total_collects_number.exact,
              currencyFormat,
              icon: Icons.numbers,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(
    BuildContext context,
    String title,
    String estimated,
    String exact,
    intl.NumberFormat formatter, {
    required IconData icon,
    bool isCurrency = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.grey[700], size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildValueBadge(
                      'Req', _format(formatter, estimated), Colors.orange),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  _buildValueBadge(
                      'Del', _format(formatter, exact), Colors.green),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValueBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
                fontSize: 10,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  String _format(intl.NumberFormat formatter, String value) {
    try {
      final doubleVal = double.parse(value);
      return EnArConvertor().replaceArNumber(formatter.format(doubleVal));
    } catch (e) {
      return value;
    }
  }
}

class _DetailsCard extends StatelessWidget {
  final RequestWasteItem loadedCollect;

  const _DetailsCard({required this.loadedCollect});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailRow(
              'Region',
              EnArConvertor()
                  .replaceArNumber(loadedCollect.address_data.region.name),
              Icons.location_on_outlined,
            ),
            const Divider(height: 20),
            _buildDetailRow(
              'Request Date',
              '${EnArConvertor().replaceArNumber(loadedCollect.collect_date.day)} - ${EnArConvertor().replaceArNumber(loadedCollect.collect_date.time)}',
              Icons.calendar_today_outlined,
            ),
            const Divider(height: 20),
            _buildDetailRow(
              'Collect Time',
              loadedCollect.collect_date.collect_done_time.isNotEmpty
                  ? EnArConvertor().replaceArNumber(
                      loadedCollect.collect_date.collect_done_time)
                  : 'Pending',
              Icons.access_time,
              valueColor: loadedCollect.collect_date.collect_done_time.isEmpty
                  ? Colors.orange
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _WasteListSliver extends StatelessWidget {
  final RequestWasteItem loadedCollect;

  const _WasteListSliver({required this.loadedCollect});

  @override
  Widget build(BuildContext context) {
    if (loadedCollect.collect_list.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              'No Waste Items Found',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: CollectDetailsCollectItem(
            collectItem: loadedCollect.collect_list[i],
          ),
        ),
        childCount: loadedCollect.collect_list.length,
      ),
    );
  }
}
