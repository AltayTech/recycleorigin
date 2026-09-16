import 'package:recycleorigin/features/wallet_feature/business/entities/wallet.dart';

enum WalletSummaryStatus { initial, loading, loaded, error, notAuthenticated }

class WalletSummaryState {
  const WalletSummaryState({
    this.status = WalletSummaryStatus.initial,
    this.wallet,
    this.errorMessage,
  });

  final WalletSummaryStatus status;
  final Wallet? wallet;
  final String? errorMessage;

  WalletSummaryState copyWith({
    WalletSummaryStatus? status,
    Wallet? wallet,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WalletSummaryState(
      status: status ?? this.status,
      wallet: wallet ?? this.wallet,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
