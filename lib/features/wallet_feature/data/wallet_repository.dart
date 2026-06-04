import 'package:recycleorigin/core/constants/urls.dart';
import 'package:recycleorigin/core/network/api_client.dart';
import 'package:recycleorigin/core/utils/result.dart';
import 'package:recycleorigin/features/wallet_feature/business/entities/wallet.dart';

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
}
