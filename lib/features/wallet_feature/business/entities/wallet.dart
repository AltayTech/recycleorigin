/// Represents the user's wallet from GET /wallet.
class Wallet {
  final int id;
  final int userId;
  final String balance;
  final String currency;
  final bool isFrozen;

  const Wallet({
    this.id = 0,
    this.userId = 0,
    this.balance = '0',
    this.currency = 'USD',
    this.isFrozen = false,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      balance: json['balance']?.toString() ?? '0',
      currency: json['currency'] as String? ?? 'USD',
      isFrozen: json['is_frozen'] as bool? ?? false,
    );
  }
}
