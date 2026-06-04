import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/logic/en_to_ar_number_convertor.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import 'package:recycleorigin/l10n/l10n.dart';

/// Compact summary card showing item count, total price, and
/// total weight for the current waste request.
class RequestSummaryCard extends StatelessWidget {
  final int itemCount;
  final int totalPrice;
  final int totalWeight;

  const RequestSummaryCard({
    super.key,
    required this.itemCount,
    required this.totalPrice,
    required this.totalWeight,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = intl.NumberFormat.decimalPattern();
    final converter = EnArConvertor();
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.06),
            AppTheme.primary.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.1),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _MetricTile(
                icon: Icons.inventory_2_rounded,
                iconColor: AppTheme.primary,
                label: l10n.numberFieldLabel,
                value: converter.replaceArNumber(
                  itemCount.toString(),
                ),
              ),
            ),
            VerticalDivider(
              thickness: 1,
              width: 24,
              color: AppTheme.primary.withOpacity(0.1),
            ),
            Expanded(
              child: _MetricTile(
                icon: Icons.monetization_on_rounded,
                iconColor: AppTheme.iconAccentGold,
                label: l10n.totalPriceFieldLabel,
                value: converter.replaceArNumber(
                  fmt.format(totalPrice),
                ),
                suffix: '\$',
              ),
            ),
            VerticalDivider(
              thickness: 1,
              width: 24,
              color: AppTheme.primary.withOpacity(0.1),
            ),
            Expanded(
              child: _MetricTile(
                icon: Icons.scale_rounded,
                iconColor: AppTheme.iconAccentPurple,
                label: l10n.totalWeightFieldLabel,
                value: converter.replaceArNumber(
                  totalWeight.toString(),
                ),
                suffix: 'kg',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  color: context.colors.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (suffix != null) ...[
              const SizedBox(width: 2),
              Text(
                suffix!,
                style: TextStyle(
                  color: context.colors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: context.appColors.subtitleColor,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
