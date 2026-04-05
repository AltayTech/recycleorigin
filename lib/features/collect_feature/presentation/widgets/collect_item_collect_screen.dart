import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/request_waste_item.dart';
import 'package:recycleorigin/features/waste_feature/collect_detail_screen.dart';

import '../../../../core/logic/en_to_ar_number_convertor.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/l10n.dart';

class CollectItemCollectsScreen extends StatelessWidget {
  const CollectItemCollectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final collect =
        Provider.of<RequestWasteItem>(context, listen: false);
    final l10n = context.l10n;
    final (statusColor, statusIcon) =
        _statusVisuals(collect.requestStatusKey);
    final statusText = _statusText(l10n, collect);

    final estWeight =
        double.tryParse(collect.total_collects_weight.estimated) ?? 0;
    final estPrice =
        double.tryParse(collect.total_collects_price.estimated) ?? 0;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.of(context).pushNamed(
        CollectDetailScreen.routeName,
        arguments: collect.id,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    statusText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
            const Divider(height: 18),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.calendar_today_outlined,
                  text: EnArConvertor()
                      .replaceArNumber(collect.collect_date.day),
                ),
                const SizedBox(width: 12),
                _InfoChip(
                  icon: Icons.access_time,
                  text: EnArConvertor()
                      .replaceArNumber(collect.collect_date.time),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _StatBadge(
                    label: l10n.totalWeightFieldLabel,
                    value:
                        '${EnArConvertor().replaceArNumber(estWeight.toStringAsFixed(1))} ${l10n.weightUnitKilogram}',
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatBadge(
                    label: l10n.totalPriceFieldLabel,
                    value: EnArConvertor()
                        .replaceArNumber(_fmtPrice(estPrice)),
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            if (collect.address_data.address.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      collect.address_data.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _fmtPrice(double v) {
    if (v == v.truncateToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }

  String _statusText(dynamic l10n, RequestWasteItem c) {
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
        if (c.requestStatusLabel.isNotEmpty) return c.requestStatusLabel;
        final n = c.status.name.trim();
        return (n.isNotEmpty && n != '0') ? n : '—';
    }
  }

  (Color, IconData) _statusVisuals(String key) {
    return switch (key) {
      'pending_assignment' => (Colors.grey, Icons.person_search_rounded),
      'pending_driver_acceptance' =>
        (Colors.orange, Icons.hourglass_top),
      'driver_accepted' || 'in_progress' =>
        (Colors.blue, Icons.local_shipping),
      'picked_up' => (Colors.indigo, Icons.inventory_2_rounded),
      'collected' => (Colors.green, Icons.check_circle_rounded),
      'cancelled' => (Colors.red.shade400, Icons.cancel_rounded),
      _ => (Colors.grey, Icons.info_outline),
    };
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppTheme.primary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
