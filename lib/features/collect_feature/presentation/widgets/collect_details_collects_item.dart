import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:recycleorigin/features/waste_feature/business/entities/collect.dart';
import '../../../../core/logic/en_to_ar_number_convertor.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import 'package:recycleorigin/l10n/l10n.dart';

class CollectDetailsCollectItem extends StatelessWidget {
  final Collect collectItem;

  const CollectDetailsCollectItem({
    Key? key,
    required this.collectItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = intl.NumberFormat.decimalPattern();

    return Container(
      decoration: AppTheme.listItemBoxFor(context).copyWith(
        boxShadow: [
          BoxShadow(
            color: context.appColors.subtitleColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            collectItem.waste.post_title,
            style: TextStyle(
              color: context.colors.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Divider(height: 24),
          _buildInfoSection(
            context,
            title: context.l10n.summaryWeightKgTitle,
            requested: collectItem.estimated_weight,
            delivered: collectItem.exact_weight,
            isCurrency: false,
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            context,
            title: context.l10n.summaryPriceUsdTitle,
            requested:
                _formatCurrency(currencyFormat, collectItem.estimated_price),
            delivered: _formatCurrency(currencyFormat, collectItem.exact_price),
            isCurrency: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required String title,
    required String requested,
    required String delivered,
    required bool isCurrency,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: context.appColors.subtitleColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildValueBox(
                label: context.l10n.statusRequestLabel,
                value: requested,
                color: context.appColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildValueBox(
                label: context.l10n.statusDeliveredLabel,
                value: delivered,
                color: context.appColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildValueBox({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            EnArConvertor().replaceArNumber(value),
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

  String _formatCurrency(intl.NumberFormat formatter, String value) {
    try {
      final doubleVal = double.parse(value);
      return formatter.format(doubleVal);
    } catch (e) {
      return value;
    }
  }
}
