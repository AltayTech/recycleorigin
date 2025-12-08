import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/logic/en_to_ar_number_convertor.dart';
import '../../../../core/theme/app_theme.dart';

class RequestSummaryCard extends StatelessWidget {
  final int itemCount;
  final int totalPrice;
  final int totalWeight;

  const RequestSummaryCard({
    Key? key,
    required this.itemCount,
    required this.totalPrice,
    required this.totalWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = intl.NumberFormat.decimalPattern();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(
            context,
            iconPath: 'assets/images/main_page_request_ic.png',
            label: 'Number',
            value: itemCount.toString(),
            color: AppTheme.primary,
          ),
          const Divider(height: 24, thickness: 0.5),
          _buildRow(
            context,
            iconPath: 'assets/images/waste_cart_price_ic.png',
            label: 'Total Price',
            value: totalPrice.toString().isNotEmpty
                ? currencyFormat.format(totalPrice)
                : '0',
            suffix: '(\$)',
            iconColor: Colors.yellow[700],
          ),
          const Divider(height: 24, thickness: 0.5),
          _buildRow(
            context,
            iconPath: 'assets/images/waste_cart_weight_ic.png',
            label: 'Total Weight',
            value: totalWeight.toString(),
            suffix: '(Kg)',
            iconColor: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required String iconPath,
    required String label,
    required String value,
    String? suffix,
    Color? iconColor,
    Color? color,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: (iconColor ?? color ?? AppTheme.primary).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            iconPath,
            color: iconColor,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (suffix != null)
                Text(
                  suffix,
                  style: TextStyle(
                    color: AppTheme.grey.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ),
        Text(
          EnArConvertor().replaceArNumber(value),
          style: TextStyle(
            color: AppTheme.h1,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
