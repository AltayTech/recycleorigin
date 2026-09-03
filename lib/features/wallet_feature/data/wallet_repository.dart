import 'package:recycleorigin/core/constants/urls.dart';
import 'package:recycleorigin/core/network/api_client.dart';
import 'package:recycleorigin/core/utils/result.dart';
import 'package:recycleorigin/features/wallet_feature/business/entities/wallet.dart';
import 'package:recycleorigin/features/wallet_feature/business/entities/wallet_transaction.dart';

/// Paginated wallet transaction list from GET /wallet/transactions.
class WalletTransactionsPage {
  const WalletTransactionsPage({
    required this.transactions,
    required this.maxPages,
  });

  final List<WalletTransaction> transactions;
  final int maxPages;
}

/// Loads wallet summary from GET /wallet.
class WalletRepository {
  WalletRepository(this._client);

  final ApiClient _client;

  static const String _base = 'recycleorigin/v1';

  Future<Result<Wallet>> fetchWallet() {
    return _client.get<Wallet>(
      '$_base${Urls.walletEndPoint}',
      parser: (dynamic data) {
        final map = data as Map<String, dynamic>;
        final walletJson = map['wallet'] as Map<String, dynamic>?;
        if (walletJson == null) {
          return const Wallet();
        }
        return Wallet.fromJson(walletJson);
      },
    );
  }

  Future<Result<WalletTransactionsPage>> fetchTransactions({
    int page = 1,
    int perPage = 20,
  }) {
    return _client.get<WalletTransactionsPage>(
      '$_base${Urls.walletTransactionsEndPoint}',
      queryParameters: {'page': page, 'per_page': perPage},
      parser: (dynamic data) {
        final map = data as Map<String, dynamic>;
        final txList = map['data'] as List<dynamic>? ?? [];
        final details = map['details'] as Map<String, dynamic>?;
        return WalletTransactionsPage(
          transactions: txList
              .map(
                (e) => WalletTransaction.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
          maxPages: details?['max_pages'] as int? ?? 1,
        );
      },
    );
  }
}
