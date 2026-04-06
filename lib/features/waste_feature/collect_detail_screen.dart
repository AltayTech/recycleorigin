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
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: _buildAppBar(l10n),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar(dynamic l10n) {
    return AppBar(
      title: Text(
        l10n.collectDetailTitle,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppTheme.appBarColor,
      iconTheme: const IconThemeData(color: AppTheme.appBarIconColor),
      elevation: 0,
      actions: <Widget>[
        if (_collect != null && !_loading)
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: _loadData,
          ),
      ],
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return _ErrorView(error: _error!, onRetry: _loadData);
    }
    if (_loading && _collect == null) {
      return _LoadingView();
    }
    if (_collect == null) {
      return Center(child: Text(context.l10n.somethingWentWrong));
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        children: <Widget>[
          _StatusBanner(collect: _collect!),
          const SizedBox(height: 16),
          _SectionHeader(
            icon: Icons.info_outline_rounded,
            label: 'Request Info',
          ),
          const SizedBox(height: 8),
          _RequestInfoCard(collect: _collect!),
          if (_hasDriver()) ...<Widget>[
            const SizedBox(height: 20),
            _SectionHeader(
              icon: Icons.person_pin_rounded,
              label: 'Assigned Driver',
            ),
            const SizedBox(height: 8),
            _DriverInfoCard(collect: _collect!),
          ],
          const SizedBox(height: 20),
          _SectionHeader(
            icon: Icons.bar_chart_rounded,
            label: context.l10n.wasteItemsSection,
          ),
          const SizedBox(height: 8),
          _TotalsCard(collect: _collect!),
          const SizedBox(height: 20),
          if (_collect!.collect_list.isNotEmpty) ...<Widget>[
            _WasteItemsSection(collect: _collect!),
          ] else
            _EmptyWasteItemsCard(),
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

// ─── Status helpers ───────────────────────────────────────────────────────────

String _resolveStatusText(BuildContext context, RequestWasteItem c) {
  final l10n = context.l10n;
  return switch (c.requestStatusKey) {
    'pending_assignment' => l10n.statusPendingAssignment,
    'pending_driver_acceptance' => l10n.statusPendingDriverAcceptance,
    'driver_accepted' => l10n.statusDriverAccepted,
    'in_progress' => l10n.statusInProgress,
    'picked_up' => l10n.statusPickedUp,
    'collected' => l10n.statusCollected,
    'cancelled' => l10n.statusCancelled,
    _ => c.requestStatusLabel.isNotEmpty
        ? c.requestStatusLabel
        : (c.status.name.trim().isNotEmpty &&
                  c.status.name.trim() != '0'
              ? c.status.name.trim()
              : '—'),
  };
}

(Color, Color, IconData) _statusVisuals(String key) {
  return switch (key) {
    'pending_assignment' => (
      const Color(0xFFF59E0B),
      const Color(0xFFFEF3C7),
      Icons.person_search_rounded,
    ),
    'pending_driver_acceptance' => (
      const Color(0xFFF97316),
      const Color(0xFFFFF7ED),
      Icons.hourglass_top_rounded,
    ),
    'driver_accepted' || 'in_progress' => (
      const Color(0xFF3B82F6),
      const Color(0xFFEFF6FF),
      Icons.local_shipping_rounded,
    ),
    'picked_up' => (
      const Color(0xFF8B5CF6),
      const Color(0xFFF5F3FF),
      Icons.inventory_2_rounded,
    ),
    'collected' => (
      const Color(0xFF10B981),
      const Color(0xFFECFDF5),
      Icons.check_circle_rounded,
    ),
    'cancelled' => (
      const Color(0xFFEF4444),
      const Color(0xFFFEF2F2),
      Icons.cancel_rounded,
    ),
    _ => (
      const Color(0xFF6B7280),
      const Color(0xFFF9FAFB),
      Icons.info_outline_rounded,
    ),
  };
}

// ─── Status Banner ────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.collect});

  final RequestWasteItem collect;

  @override
  Widget build(BuildContext context) {
    final text = _resolveStatusText(context, collect);
    final (color, bg, icon) = _statusVisuals(collect.requestStatusKey);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.l10n.currentStatusLabel,
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.circle,
              size: 8,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 16, color: AppTheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Colors.grey.shade700,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ─── Card shell ───────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
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

// ─── Detail row ───────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? Colors.grey.shade500;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                    height: 1.35,
                    fontWeight: FontWeight.w500,
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

// ─── Request Info Card ────────────────────────────────────────────────────────

class _RequestInfoCard extends StatelessWidget {
  const _RequestInfoCard({required this.collect});

  final RequestWasteItem collect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final date = collect.collect_date;
    return _Card(
      children: <Widget>[
        _DetailRow(
          icon: Icons.location_on_rounded,
          label: l10n.fullAddressFieldLabel,
          value: collect.address_data.address,
          iconColor: const Color(0xFFEF4444),
        ),
        _DetailRow(
          icon: Icons.calendar_month_rounded,
          label: l10n.requestDateLabel,
          value: '${_loc(date.day)}  —  ${_loc(date.time)}',
          iconColor: const Color(0xFF3B82F6),
        ),
        if (date.collect_done_time.isNotEmpty &&
            date.collect_done_time != '0')
          _DetailRow(
            icon: Icons.task_alt_rounded,
            label: l10n.collectDoneTimeLabel,
            value: _loc(date.collect_done_time),
            iconColor: const Color(0xFF10B981),
          ),
      ],
    );
  }

  String _loc(String v) => EnArConvertor().replaceArNumber(v);
}

// ─── Driver Info Card ─────────────────────────────────────────────────────────

class _DriverInfoCard extends StatelessWidget {
  const _DriverInfoCard({required this.collect});

  final RequestWasteItem collect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final d = collect.driver;
    final dd = d.driver_data;

    return _Card(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    AppTheme.primary,
                    AppTheme.primary.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  dd.fname.isNotEmpty ? dd.fname[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${dd.fname} ${dd.lname}'.trim(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  if (d.car.name.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      d.car.name,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (dd.mobile.isNotEmpty || dd.phone.isNotEmpty)
              _CallButton(
                number: dd.mobile.isNotEmpty ? dd.mobile : dd.phone,
              ),
          ],
        ),
        const SizedBox(height: 14),
        Divider(color: Colors.grey.shade100),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: _MiniStat(
                icon: Icons.badge_rounded,
                label: l10n.plateNumberLabel,
                value: EnArConvertor().replaceArNumber(d.car_number),
              ),
            ),
            Container(
              width: 1,
              height: 36,
              color: Colors.grey.shade100,
            ),
            Expanded(
              child: _MiniStat(
                icon: Icons.palette_rounded,
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

class _CallButton extends StatelessWidget {
  const _CallButton({required this.number});

  final String number;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.green.shade200),
      ),
      child: IconButton(
        icon: Icon(Icons.phone_rounded, color: Colors.green.shade600),
        onPressed: () async {
          final uri = Uri(scheme: 'tel', path: number);
          if (await canLaunchUrl(uri)) await launchUrl(uri);
        },
        tooltip: 'Call driver',
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 13, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value.isNotEmpty ? value : '—',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Totals Card ──────────────────────────────────────────────────────────────

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.collect});

  final RequestWasteItem collect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final w = collect.total_collects_weight;
    final p = collect.total_collects_price;
    final n = collect.total_collects_number;
    final hasExact = _isNonZero(w.exact) && w.exact != w.estimated;

    return _Card(
      children: <Widget>[
        _TotalRow(
          icon: Icons.scale_rounded,
          iconColor: const Color(0xFF8B5CF6),
          title: l10n.summaryWeightKgTitle,
          estimated: '${_fmt(w.estimated)} kg',
          exact: hasExact ? '${_fmt(w.exact)} kg' : null,
          l10n: l10n,
        ),
        Divider(height: 24, color: Colors.grey.shade100),
        _TotalRow(
          icon: Icons.monetization_on_rounded,
          iconColor: const Color(0xFF10B981),
          title: l10n.summaryPriceUsdTitle,
          estimated: _fmt(p.estimated),
          exact: _isNonZero(p.exact) && p.exact != p.estimated
              ? _fmt(p.exact)
              : null,
          l10n: l10n,
        ),
        Divider(height: 24, color: Colors.grey.shade100),
        _TotalRow(
          icon: Icons.inventory_2_rounded,
          iconColor: const Color(0xFF3B82F6),
          title: l10n.cartItemsLabel,
          estimated: n.estimated,
          exact: null,
          l10n: l10n,
        ),
      ],
    );
  }

  bool _isNonZero(String v) => (double.tryParse(v) ?? 0) > 0;

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
    required this.iconColor,
    required this.title,
    required this.estimated,
    required this.exact,
    required this.l10n,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String estimated;
  final String? exact;
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: <Widget>[
                  _Badge(
                    label: l10n.submittedWeightLabel,
                    value: EnArConvertor().replaceArNumber(estimated),
                    color: const Color(0xFFF59E0B),
                  ),
                  if (exact != null) ...<Widget>[
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color: Color(0xFF9CA3AF),
                    ),
                    _Badge(
                      label: l10n.finalWeightLabel,
                      value: EnArConvertor().replaceArNumber(exact!),
                      color: const Color(0xFF10B981),
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
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

// ─── Waste Items Section ──────────────────────────────────────────────────────

class _WasteItemsSection extends StatelessWidget {
  const _WasteItemsSection({required this.collect});

  final RequestWasteItem collect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (final (int i, Collect item) in collect.collect_list.indexed) ...<Widget>[
          if (i > 0) const SizedBox(height: 10),
          _WasteItemCard(item: item),
        ],
      ],
    );
  }
}

class _EmptyWasteItemsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Card(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Column(
              children: <Widget>[
                Icon(
                  Icons.inventory_2_outlined,
                  size: 40,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 10),
                Text(
                  context.l10n.collectDetailNoWasteItemsMessage,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
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
    final extTotal =
        hasExactWeight ? extW * (extP > 0 ? extP : estP) : 0.0;

    return _Card(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.recycling_rounded,
                color: AppTheme.primary,
                size: 22,
              ),
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
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Divider(color: Colors.grey.shade100),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: _ItemMetricCell(
                label: l10n.summaryWeightKgTitle,
                estimatedValue: '${estW.toStringAsFixed(1)} kg',
                finalValue: hasExactWeight
                    ? '${extW.toStringAsFixed(1)} kg'
                    : null,
                l10n: l10n,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ItemMetricCell(
                label: l10n.pricePerKgLabel,
                estimatedValue: _fmtPrice(estP),
                finalValue:
                    (extP > 0 && extP != estP) ? _fmtPrice(extP) : null,
                l10n: l10n,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                l10n.totalPriceFieldLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
              Row(
                children: <Widget>[
                  _Badge(
                    label: l10n.submittedWeightLabel,
                    value: EnArConvertor()
                        .replaceArNumber(_fmtPrice(estTotal)),
                    color: const Color(0xFFF59E0B),
                  ),
                  if (extTotal > 0) ...<Widget>[
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 6),
                    _Badge(
                      label: l10n.finalWeightLabel,
                      value: EnArConvertor()
                          .replaceArNumber(_fmtPrice(extTotal)),
                      color: const Color(0xFF10B981),
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

  String _fmtPrice(double v) {
    if (v == v.truncateToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }
}

class _ItemMetricCell extends StatelessWidget {
  const _ItemMetricCell({
    required this.label,
    required this.estimatedValue,
    required this.finalValue,
    required this.l10n,
  });

  final String label;
  final String estimatedValue;
  final String? finalValue;
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          _Badge(
            label: l10n.submittedWeightLabel,
            value: EnArConvertor().replaceArNumber(estimatedValue),
            color: const Color(0xFFF59E0B),
          ),
          if (finalValue != null) ...<Widget>[
            const SizedBox(height: 4),
            _Badge(
              label: l10n.finalWeightLabel,
              value: EnArConvertor().replaceArNumber(finalValue!),
              color: const Color(0xFF10B981),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Loading and Error Views ──────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      children: const <Widget>[
        _SkeletonBox(height: 90),
        SizedBox(height: 16),
        _SkeletonBox(height: 130),
        SizedBox(height: 16),
        _SkeletonBox(height: 120),
        SizedBox(height: 16),
        _SkeletonBox(height: 100),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 40,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.retryLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
