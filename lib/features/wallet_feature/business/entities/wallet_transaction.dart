/// Represents a single wallet transaction from the new wallet API.
class WalletTransaction {
  final int id;
  final String type;
  final String amount;
  final String balanceAfter;
  final String currency;
  final String direction;
  final String referenceType;
  final int? referenceId;
  final String description;
  final String status;
  final String createdAt;

  const WalletTransaction({
    this.id = 0,
    this.type = '',
    this.amount = '0',
    this.balanceAfter = '0',
    this.currency = 'USD',
    this.direction = 'credit',
    this.referenceType = '',
    this.referenceId,
    this.description = '',
    this.status = 'completed',
    this.createdAt = '',
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as int? ?? 0,
      type: json['type'] as String? ?? '',
      amount: json['amount']?.toString() ?? '0',
      balanceAfter: json['balance_after']?.toString() ?? '0',
      currency: json['currency'] as String? ?? 'USD',
      direction: json['direction'] as String? ?? 'credit',
      referenceType: json['reference_type'] as String? ?? '',
      referenceId: json['reference_id'] as int?,
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'completed',
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  bool get isCredit => direction == 'credit';

  /// Human-readable label for the transaction type.
  String get typeLabel {
    switch (type) {
      case 'collect_reward':
        return 'Collection Reward';
      case 'driver_commission':
        return 'Driver Commission';
      case 'store_purchase':
        return 'Store Purchase';
      case 'withdrawal':
        return 'Withdrawal';
      case 'admin_adjustment':
        return 'Admin Adjustment';
      case 'deposit':
        return 'Deposit';
      default:
        return type.replaceAll('_', ' ');
    }
  }
}
