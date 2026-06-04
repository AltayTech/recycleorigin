import 'package:recycleorigin/features/impact_feature/data/impact_models.dart';

enum ImpactStatus { initial, loading, loaded, error }

class ImpactState {
  const ImpactState({
    this.status = ImpactStatus.initial,
    this.range = '30d',
    this.impact,
    this.leaderboard,
    this.errorMessage,
  });

  final ImpactStatus status;
  final String range;
  final ImpactData? impact;
  final LeaderboardData? leaderboard;
  final String? errorMessage;

  ImpactState copyWith({
    ImpactStatus? status,
    String? range,
    ImpactData? impact,
    LeaderboardData? leaderboard,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ImpactState(
      status: status ?? this.status,
      range: range ?? this.range,
      impact: impact ?? this.impact,
      leaderboard: leaderboard ?? this.leaderboard,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
