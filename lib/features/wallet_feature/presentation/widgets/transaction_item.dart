import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:recycleorigin/core/models/transaction.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/core/logic/en_to_ar_number_convertor.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionItem({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = intl.NumberFormat.decimalPattern();
    final isWithdraw = transaction.operation.toLowerCase() == 'withdraw';
    final amountColor = isWithdraw ? Colors.red : AppTheme.primary;
    final icon = isWithdraw ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
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
          backgroundColor: amountColor.withOpacity(0.1),
          child: Icon(icon, color: amountColor, size: 20),
        ),
        title: Text(
          transaction.transaction_type.name,
          style: TextStyle(
            color: AppTheme.h1,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          transaction.operation,
          style: TextStyle(
            color: AppTheme.grey,
            fontSize: 14,
          ),
        ),
        trailing: Text(
          '${EnArConvertor().replaceArNumber(currencyFormat.format(double.parse(transaction.money).round()).toString())} \$',
          style: TextStyle(
            color: amountColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
