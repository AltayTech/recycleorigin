import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/core/theme/theme_context_extensions.dart';
import 'package:recycleorigin/core/logic/en_to_ar_number_convertor.dart';
import 'package:recycleorigin/features/wallet_feature/business/entities/wallet_transaction.dart';

/// Displays a single wallet transaction with type-specific icon and color.
class WalletTransactionItem extends StatelessWidget {
  final WalletTransaction transaction;

  const WalletTransactionItem({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  IconData get _icon {
    switch (transaction.type) {
      case 'collect_reward':
        return Icons.recycling;
      case 'driver_commission':
        return Icons.local_shipping;
      case 'store_purchase':
        return Icons.shopping_cart;
      case 'withdrawal':
        return Icons.account_balance;
      case 'admin_adjustment':
        return Icons.admin_panel_settings;
      case 'deposit':
        return Icons.add_circle_outline;
      default:
        return transaction.isCredit
            ? Icons.arrow_downward
            : Icons.arrow_upward;
    }
  }

  Color get _color {
    if (transaction.isCredit) return Colors.green.shade600;
    return Colors.red.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = intl.NumberFormat.currency(
      symbol: '',
      decimalDigits: 2,
    );
    final parsed = double.tryParse(transaction.amount) ?? 0;
    final formatted = EnArConvertor().replaceArNumber(
      currencyFormat.format(parsed),
    );
    final prefix = transaction.isCredit ? '+' : '-';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _color.withOpacity(0.1),
          child: Icon(_icon, color: _color, size: 20),
        ),
        title: Text(
          transaction.typeLabel,
          style: TextStyle(
            color: context.colors.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.description.isNotEmpty)
              Text(
                transaction.description,
                style: TextStyle(color: context.appColors.subtitleColor, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (transaction.createdAt.isNotEmpty)
              Text(
                _formatDate(transaction.createdAt),
                style: TextStyle(
                  color: context.appColors.subtitleColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: Text(
          '$prefix$formatted',
          style: TextStyle(
            color: _color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return intl.DateFormat('MMM d, yyyy HH:mm').format(date);
    } catch (_) {
      return isoDate;
    }
  }
}
