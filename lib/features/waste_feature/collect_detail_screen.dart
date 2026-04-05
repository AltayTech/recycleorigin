import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/core/logic/en_to_ar_number_convertor.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/collect.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/request_waste_item.dart';
import 'package:recycleorigin/features/waste_feature/presentation/bloc/wastes_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import 'package:recycleorigin/l10n/l10n.dart';

class CollectDetailScreen extends StatefulWidget {
  static const routeName = '/collectDetailScreen';

  const CollectDetailScreen({Key? key}) : super(key: key);

  @override
  State<CollectDetailScreen> createState() => _CollectDetailScreenState();
}

class _CollectDetailScreenState extends State<CollectDetailScreen> {
  bool _loading = false;
  bool _isInit = true;
  String? _error;
  RequestWasteItem? _collect;

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
      _loading = true;
      _error = null;
    });
    try {
      final id = ModalRoute.of(context)?.settings.arguments as int?;
      if (id == null) throw Exception('Invalid request ID');
      await context.read<WastesBloc>().retrieveCollectItem(id);
      if (!mounted) return;
      _collect = context.read<WastesBloc>().requestWasteItem!;
    } catch (e) {
      if (mounted) _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          l10n.collectDetailTitle,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme:
            const IconThemeData(color: AppTheme.appBarIconColor),
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return _ErrorView(error: _error!, onRetry: _loadData);
    }
    if (_loading && _collect == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_collect == null) {
      return Center(child: Text(context.l10n.somethingWentWrong));
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _StatusBanner(collect: _collect!),
          const SizedBox(height: 16),
          _RequestInfoCard(collect: _collect!),
          const SizedBox(height: 16),
          if (_hasDriver()) ...[
            _DriverInfoCard(collect: _collect!),
            const SizedBox(height: 16),
          ],
          _TotalsCard(collect: _collect!),
          const SizedBox(height: 16),
          _WasteItemsSection(collect: _collect!),
        ],
      ),
    );
  }

  bool _hasDriver() {
    try {
      return _collect!.driver.driver_data.fname.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

String _resolveStatusText(
    BuildContext context, RequestWasteItem c) {
  final l10n = context.l10n;
  switch (c.requestStatusKey) {
    case 'pending_assignment':
      return l10n.statusPendingAssignment;
    case 'pending_driver_acceptance':
      return l10n.statusPendingDriverAcceptance;
    case 'driver_accepted':
      return l10n.statusDriverAccepted;
    case 'in_progress':
      return l10n.statusInProgress;
    case 'picked_up':
      return l10n.statusPickedUp;
    case 'collected':
      return l10n.statusCollected;
    case 'cancelled':
      return l10n.statusCancelled;
    default:
      if (c.requestStatusLabel.isNotEmpty) {
        return c.requestStatusLabel;
      }
      final n = c.status.name.trim();
      return (n.isNotEmpty && n != '0') ? n : '—';
  }
}

(Color, IconData) _statusVisuals(String key) {
  return switch (key) {
    'pending_assignment' => (Colors.grey, Icons.person_search_rounded),
    'pending_driver_acceptance' => (Colors.orange, Icons.hourglass_top),
    'driver_accepted' || 'in_progress' => (Colors.blue, Icons.local_shipping),
    'picked_up' => (Colors.indigo, Icons.inventory_2_rounded),
    'collected' => (Colors.green, Icons.check_circle_rounded),
    'cancelled' => (Colors.red.shade400, Icons.cancel_rounded),
    _ => (Colors.grey, Icons.info_outline),
  };
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.collect});
  final RequestWasteItem collect;

  @override
  Widget build(BuildContext context) {
    final text = _resolveStatusText(context, collect);
    final (color, icon) = _statusVisuals(collect.requestStatusKey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.currentStatusLabel,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestInfoCard extends StatelessWidget {
  const _RequestInfoCard({required this.collect});
  final RequestWasteItem collect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final date = collect.collect_date;
    return _Card(
      children: [
        _DetailRow(
          icon: Icons.location_on_outlined,
          label: l10n.fullAddressFieldLabel,
          value: collect.address_data.address,
        ),
        _DetailRow(
          icon: Icons.calendar_today_outlined,
          label: l10n.requestDateLabel,
          value: '${_loc(context, date.day)}'
              '  —  ${_loc(context, date.time)}',
        ),
        if (date.collect_done_time.isNotEmpty &&
            date.collect_done_time != '0')
          _DetailRow(
            icon: Icons.access_time,
            label: l10n.collectDoneTimeLabel,
            value: _loc(context, date.collect_done_time),
          ),
      ],
    );
  }

  String _loc(BuildContext context, String v) =>
      EnArConvertor().replaceArNumber(v);
}

class _DriverInfoCard extends StatelessWidget {
  const _DriverInfoCard({required this.collect});
  final RequestWasteItem collect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final d = collect.driver;
    final dd = d.driver_data;
    return _Card(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppTheme.primary.withOpacity(0.1),
              child: Text(
                dd.fname.isNotEmpty ? dd.fname[0].toUpperCase() : '?',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${dd.fname} ${dd.lname}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (d.car.name.isNotEmpty)
                    Text(
                      d.car.name,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
            if (dd.mobile.isNotEmpty || dd.phone.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.phone, color: Colors.green),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.green.withOpacity(0.08),
                ),
                onPressed: () async {
                  final nr =
                      dd.mobile.isNotEmpty ? dd.mobile : dd.phone;
                  final uri = Uri(scheme: 'tel', path: nr);
                  if (await canLaunchUrl(uri)) launchUrl(uri);
                },
              ),
          ],
        ),
        const Divider(height: 20),
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                label: l10n.plateNumberLabel,
                value: EnArConvertor()
                    .replaceArNumber(d.car_number),
              ),
            ),
            Expanded(
              child: _MiniStat(
                label: l10n.carColorLabel,
                value: d.car_color.name,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        const SizedBox(height: 2),
        Text(value,
            style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.collect});
  final RequestWasteItem collect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final w = collect.total_collects_weight;
    final p = collect.total_collects_price;
    final n = collect.total_collects_number;
    final hasExact = _isNonZero(w.exact) &&
        w.exact != w.estimated;
    return _Card(
      children: [
        _TotalRow(
          icon: Icons.scale_outlined,
          title: l10n.summaryWeightKgTitle,
          estimated: '${_fmt(w.estimated)} kg',
          exact: hasExact ? '${_fmt(w.exact)} kg' : null,
        ),
        const Divider(height: 20),
        _TotalRow(
          icon: Icons.monetization_on_outlined,
          title: l10n.summaryPriceUsdTitle,
          estimated: _fmt(p.estimated),
          exact: _isNonZero(p.exact) && p.exact != p.estimated
              ? _fmt(p.exact)
              : null,
        ),
        const Divider(height: 20),
        _TotalRow(
          icon: Icons.inventory_2_outlined,
          title: l10n.cartItemsLabel,
          estimated: n.estimated,
          exact: null,
        ),
      ],
    );
  }

  bool _isNonZero(String v) {
    final d = double.tryParse(v) ?? 0;
    return d > 0;
  }

  String _fmt(String v) {
    final d = double.tryParse(v);
    if (d == null) return v;
    if (d == d.truncateToDouble()) return d.toStringAsFixed(0);
    return d.toStringAsFixed(1);
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.icon,
    required this.title,
    required this.estimated,
    required this.exact,
  });
  final IconData icon;
  final String title;
  final String estimated;
  final String? exact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.grey.shade700, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 4),
              Row(
                children: [
                  _Badge(
                    label: l10n.submittedWeightLabel,
                    value: EnArConvertor().replaceArNumber(estimated),
                    color: Colors.orange,
                  ),
                  if (exact != null) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.arrow_forward,
                          size: 14, color: Colors.grey),
                    ),
                    _Badge(
                      label: l10n.finalWeightLabel,
                      value: EnArConvertor().replaceArNumber(exact!),
                      color: Colors.green,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.8),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _WasteItemsSection extends StatelessWidget {
  const _WasteItemsSection({required this.collect});
  final RequestWasteItem collect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (collect.collect_list.isEmpty) {
      return _Card(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.collectDetailNoWasteItemsMessage,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            l10n.wasteItemsSection,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        for (final item in collect.collect_list) ...[
          _WasteItemCard(item: item),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _WasteItemCard extends StatelessWidget {
  const _WasteItemCard({required this.item});
  final Collect item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final estW = double.tryParse(item.estimated_weight) ?? 0;
    final extW = double.tryParse(item.exact_weight) ?? 0;
    final estP = double.tryParse(item.estimated_price) ?? 0;
    final extP = double.tryParse(item.exact_price) ?? 0;
    final hasExactWeight = extW > 0 && extW != estW;
    final estTotal = estW * estP;
    final extTotal = hasExactWeight ? extW * (extP > 0 ? extP : estP) : 0.0;

    return _Card(
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.recycling_rounded,
                  color: AppTheme.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.pasmand.post_title.isNotEmpty
                    ? item.pasmand.post_title
                    : '—',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        const Divider(height: 20),
        _ItemComparisonRow(
          label: l10n.summaryWeightKgTitle,
          submitted: '${estW.toStringAsFixed(1)} kg',
          final_: hasExactWeight
              ? '${extW.toStringAsFixed(1)} kg'
              : null,
        ),
        const SizedBox(height: 8),
        _ItemComparisonRow(
          label: l10n.pricePerKgLabel,
          submitted: _fmtPrice(estP),
          final_: (extP > 0 && extP != estP)
              ? _fmtPrice(extP)
              : null,
        ),
        const SizedBox(height: 8),
        _ItemComparisonRow(
          label: l10n.totalPriceFieldLabel,
          submitted: _fmtPrice(estTotal),
          final_: extTotal > 0 ? _fmtPrice(extTotal) : null,
          bold: true,
        ),
      ],
    );
  }

  String _fmtPrice(double v) {
    if (v == v.truncateToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }
}

class _ItemComparisonRow extends StatelessWidget {
  const _ItemComparisonRow({
    required this.label,
    required this.submitted,
    required this.final_,
    this.bold = false,
  });
  final String label;
  final String submitted;
  final String? final_;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        _Badge(
          label: l10n.submittedWeightLabel,
          value: EnArConvertor().replaceArNumber(submitted),
          color: Colors.orange,
        ),
        if (final_ != null) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child:
                Icon(Icons.arrow_forward, size: 12, color: Colors.grey),
          ),
          _Badge(
            label: l10n.finalWeightLabel,
            value: EnArConvertor().replaceArNumber(final_!),
            color: Colors.green,
          ),
        ],
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.8),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
