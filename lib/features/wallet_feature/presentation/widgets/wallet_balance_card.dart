import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/core/logic/en_to_ar_number_convertor.dart';
import 'package:recycleorigin/core/theme/theme_context_extensions.dart';

class WalletBalanceCard extends StatelessWidget {
  final String balance;
  final String currency;

  const WalletBalanceCard({
    Key? key,
    required this.balance,
    this.currency = 'USD',
  }) : super(key: key);

  String get _currencySymbol {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '\u20AC';
      case 'GBP':
        return '\u00A3';
      case 'IRR':
        return 'IRR';
      default:
        return currency;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = intl.NumberFormat.currency(
      symbol: '',
      decimalDigits: 2,
    );
    final parsed = double.tryParse(balance) ?? 0;
    final formattedBalance = EnArConvertor().replaceArNumber(
      currencyFormat.format(parsed),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            AppTheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: TextStyle(
                  color:
                      context.appColors.onHeroForeground.withValues(alpha: 0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.account_balance_wallet_outlined,
                color:
                    context.appColors.onHeroForeground.withValues(alpha: 0.9),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$formattedBalance $_currencySymbol',
            style: TextStyle(
              color: context.appColors.onHeroForeground,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
