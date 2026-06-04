import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/core/utils/result.dart';
import 'package:recycleorigin/features/wallet_feature/data/wallet_repository.dart';
import 'package:recycleorigin/features/wallet_feature/presentation/bloc/wallet_summary_state.dart';

/// Loads wallet balance for dashboard preview and shared consumers.
class WalletSummaryCubit extends Cubit<WalletSummaryState> {
  WalletSummaryCubit(this._repository) : super(const WalletSummaryState());

  final WalletRepository _repository;

  Future<void> load({required bool isAuthenticated}) async {
    if (!isAuthenticated) {
      emit(
        const WalletSummaryState(
          status: WalletSummaryStatus.notAuthenticated,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: WalletSummaryStatus.loading,
        clearError: true,
      ),
    );

    final result = await _repository.fetchWallet();
    switch (result) {
      case Success(:final value):
        emit(
          state.copyWith(
            status: WalletSummaryStatus.loaded,
            wallet: value,
            clearError: true,
          ),
        );
      case Failure(:final message):
        emit(
          state.copyWith(
            status: WalletSummaryStatus.error,
            errorMessage: message,
          ),
        );
    }
  }
}
