import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/core/utils/result.dart';
import 'package:recycleorigin/features/impact_feature/data/impact_models.dart';
import 'package:recycleorigin/features/impact_feature/data/impact_repository.dart';
import 'package:recycleorigin/features/impact_feature/presentation/bloc/impact_state.dart';

/// Loads and refreshes impact / gamification data.
class ImpactCubit extends Cubit<ImpactState> {
  ImpactCubit(this._repository) : super(const ImpactState());

  final ImpactRepository _repository;

  Future<void> load({String? range}) async {
    final selectedRange = range ?? state.range;
    emit(state.copyWith(
      status: ImpactStatus.loading,
      range: selectedRange,
      clearError: true,
    ));

    final impactResult = await _repository.fetchImpact(range: selectedRange);
    final boardResult = await _repository.fetchLeaderboard(
      range: selectedRange,
    );

    switch (impactResult) {
      case Success(:final value):
        LeaderboardData? board;
        if (boardResult case Success(value: final b)) {
          board = b;
        }
        emit(state.copyWith(
          status: ImpactStatus.loaded,
          impact: value,
          leaderboard: board,
          clearError: true,
        ));
      case Failure(:final message):
        emit(state.copyWith(
          status: ImpactStatus.error,
          errorMessage: message,
        ));
    }
  }

  Future<void> setRange(String range) => load(range: range);
}
