import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/core/logic/en_to_ar_number_convertor.dart';
import 'package:recycleorigin/core/widgets/star_rating_widget.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/collect.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/request_waste_item.dart';
import 'package:recycleorigin/features/waste_feature/presentation/bloc/wastes_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_context_extensions.dart';
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
      backgroundColor: context.appColors.scaffoldBackground,
      appBar: _buildAppBar(l10n),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar(dynamic l10n) {
    return AppBar(
      title: Text(
        l10n.collectDetailTitle,
        style: const TextStyle(
          color: AppTheme.appBarIconColor,
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
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppTheme.appBarIconColor,
            ),
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
          if (_canUserRateDriver(_collect!)) ...<Widget>[
            const SizedBox(height: 20),
            _SectionHeader(
              icon: Icons.star_rounded,
              label: context.l10n.rateDriverTitle,
            ),
            const SizedBox(height: 8),
            _RateDriverPanel(
              collect: _collect!,
              onRated: () {
                if (!mounted) return;
                setState(() {
                  _collect = context.read<WastesBloc>().requestWasteItem;
                });
              },
            ),
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

bool _canUserRateDriver(RequestWasteItem c) {
  final String k = c.requestStatusKey;
  if (k != 'picked_up' && k != 'collected') {
    return false;
  }
  try {
    return c.driver.driver_data.fname.isNotEmpty;
  } catch (_) {
    return false;
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

(Color, Color, IconData) _statusVisuals(BuildContext context, String key) {
  final ext = context.appColors;
  Color bg(Color c) => c.withValues(alpha: 0.12);
  return switch (key) {
    'pending_assignment' => (
      ext.warning,
      bg(ext.warning),
      Icons.person_search_rounded,
    ),
    'pending_driver_acceptance' => (
      ext.warning,
      bg(ext.warning),
      Icons.hourglass_top_rounded,
    ),
    'driver_accepted' || 'in_progress' => (
      ext.info,
      bg(ext.info),
      Icons.local_shipping_rounded,
    ),
    'picked_up' => (
      AppTheme.iconAccentPurple,
      bg(AppTheme.iconAccentPurple),
      Icons.inventory_2_rounded,
    ),
    'collected' => (
      ext.success,
      bg(ext.success),
      Icons.check_circle_rounded,
    ),
    'cancelled' => (
      ext.danger,
      bg(ext.danger),
      Icons.cancel_rounded,
    ),
    _ => (
      ext.subtitleColor,
      bg(ext.subtitleColor),
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
    final (color, bg, icon) =
        _statusVisuals(context, collect.requestStatusKey);

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
            color: context.appColors.subtitleColor,
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
        color: context.appColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.05),
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
    final color = iconColor ?? context.appColors.subtitleColor;
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
                    color: context.appColors.subtitleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colors.onSurface,
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
          iconColor: AppTheme.iconAccentRed,
        ),
        _DetailRow(
          icon: Icons.calendar_month_rounded,
          label: l10n.requestDateLabel,
          value: '${_loc(date.day)}  —  ${_loc(date.time)}',
          iconColor: AppTheme.iconAccentBlue,
        ),
        if (date.collect_done_time.isNotEmpty &&
            date.collect_done_time != '0')
          _DetailRow(
            icon: Icons.task_alt_rounded,
            label: l10n.collectDoneTimeLabel,
            value: _loc(date.collect_done_time),
            iconColor: AppTheme.iconAccentGreen,
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
                  style: TextStyle(
                    color: context.appColors.onHeroForeground,
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: context.colors.onSurface,
                  ),
                ),
                  if (d.averageRating != null) ...<Widget>[
                    const SizedBox(height: 6),
                    Row(
                      children: <Widget>[
                        StarRatingDisplay(value: d.averageRating!),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${l10n.averageRatingLabel}: '
                            '${d.averageRating!.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.appColors.subtitleColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (d.car.name.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      d.car.name,
                      style: TextStyle(
                        color: context.appColors.subtitleColor,
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
        Divider(color: context.appColors.divider),
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
              color: context.appColors.divider,
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
        color: context.appColors.success.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: context.appColors.success.withValues(alpha: 0.35),
        ),
      ),
      child: IconButton(
        icon: Icon(Icons.phone_rounded, color: context.appColors.success),
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
              Icon(icon, size: 13, color: context.colors.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: context.appColors.subtitleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value.isNotEmpty ? value : '—',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: context.colors.onSurface,
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
          iconColor: AppTheme.iconAccentPurple,
          title: l10n.summaryWeightKgTitle,
          estimated: '${_fmt(w.estimated)} kg',
          exact: hasExact ? '${_fmt(w.exact)} kg' : null,
          l10n: l10n,
        ),
        Divider(height: 24, color: context.appColors.divider),
        _TotalRow(
          icon: Icons.monetization_on_rounded,
          iconColor: AppTheme.iconAccentGreen,
          title: l10n.summaryPriceUsdTitle,
          estimated: _fmt(p.estimated),
          exact: _isNonZero(p.exact) && p.exact != p.estimated
              ? _fmt(p.exact)
              : null,
          l10n: l10n,
        ),
        Divider(height: 24, color: context.appColors.divider),
        _TotalRow(
          icon: Icons.inventory_2_rounded,
          iconColor: AppTheme.iconAccentBlue,
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
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: context.colors.onSurface,
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
                    color: context.appColors.warning,
                  ),
                  if (exact != null) ...<Widget>[
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color: context.appColors.subtitleColor,
                    ),
                    _Badge(
                      label: l10n.finalWeightLabel,
                      value: EnArConvertor().replaceArNumber(exact!),
                      color: context.appColors.success,
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
                  color: context.colors.outline,
                ),
                const SizedBox(height: 10),
                Text(
                  context.l10n.collectDetailNoWasteItemsMessage,
                  style: TextStyle(
                    color: context.appColors.subtitleColor,
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
                item.waste.post_title.isNotEmpty
                    ? item.waste.post_title
                    : '—',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: context.colors.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Divider(color: context.appColors.divider),
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
            color: context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: context.appColors.divider),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                l10n.totalPriceFieldLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: context.colors.onSurface,
                ),
              ),
              Row(
                children: <Widget>[
                  _Badge(
                    label: l10n.submittedWeightLabel,
                    value: EnArConvertor()
                        .replaceArNumber(_fmtPrice(estTotal)),
                    color: context.appColors.warning,
                  ),
                  if (extTotal > 0) ...<Widget>[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 12,
                      color: context.appColors.subtitleColor,
                    ),
                    const SizedBox(width: 6),
                    _Badge(
                      label: l10n.finalWeightLabel,
                      value: EnArConvertor()
                          .replaceArNumber(_fmtPrice(extTotal)),
                      color: context.appColors.success,
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
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.appColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: context.appColors.subtitleColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          _Badge(
            label: l10n.submittedWeightLabel,
            value: EnArConvertor().replaceArNumber(estimatedValue),
            color: context.appColors.warning,
          ),
          if (finalValue != null) ...<Widget>[
            const SizedBox(height: 4),
            _Badge(
              label: l10n.finalWeightLabel,
              value: EnArConvertor().replaceArNumber(finalValue!),
              color: context.appColors.success,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Rate driver (customer) ───────────────────────────────────────────────────

class _RateDriverPanel extends StatefulWidget {
  const _RateDriverPanel({
    required this.collect,
    required this.onRated,
  });

  final RequestWasteItem collect;
  final VoidCallback onRated;

  @override
  State<_RateDriverPanel> createState() => _RateDriverPanelState();
}

class _RateDriverPanelState extends State<_RateDriverPanel> {
  int _stars = 0;
  late final TextEditingController _comment;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _comment = TextEditingController();
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  bool get _alreadyRated {
    final c = widget.collect.customerRating;
    return widget.collect.hasRated ||
        (c != null && c.score > 0);
  }

  Future<void> _submit() async {
    if (_stars < 1) return;
    setState(() => _submitting = true);
    try {
      await context.read<WastesBloc>().submitDriverRating(
            widget.collect.id,
            _stars,
            _comment.text.trim(),
          );
      if (!mounted) return;
      widget.onRated();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          backgroundColor: context.appColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_alreadyRated) {
      final r = widget.collect.customerRating;
      return _Card(
        children: <Widget>[
          Text(
            l10n.yourRatingSubmitted,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: context.colors.onSurface,
            ),
          ),
          if (r != null && r.score > 0) ...<Widget>[
            const SizedBox(height: 10),
            StarRatingDisplay(value: r.score.toDouble()),
            if (r.comment.isNotEmpty) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                r.comment,
                style: TextStyle(
                  fontSize: 14,
                  color: context.appColors.subtitleColor,
                ),
              ),
            ],
          ],
        ],
      );
    }
    return _Card(
      children: <Widget>[
        Text(
          l10n.rateDriverHint,
          style: TextStyle(
            fontSize: 13,
            color: context.appColors.subtitleColor,
          ),
        ),
        const SizedBox(height: 12),
        StarRatingInput(
          value: _stars,
          onChanged: (int v) => setState(() => _stars = v),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _comment,
          maxLines: 3,
          maxLength: 500,
          decoration: InputDecoration(
            labelText: l10n.ratingCommentLabel,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitting || _stars < 1 ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: context.appColors.onHeroForeground,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _submitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.submitRatingLabel),
          ),
        ),
      ],
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
        color: context.colors.surfaceContainerHighest,
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
                color: context.appColors.danger.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 40,
                color: context.appColors.danger,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: context.colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.appColors.subtitleColor,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.retryLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: context.appColors.onHeroForeground,
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
