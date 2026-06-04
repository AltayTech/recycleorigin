import 'package:recycleorigin/core/constants/urls.dart';
import 'package:recycleorigin/core/network/api_client.dart';
import 'package:recycleorigin/core/utils/result.dart';
import 'package:recycleorigin/features/impact_feature/data/impact_models.dart';

/// Loads impact and leaderboard data from the backend.
class ImpactRepository {
  ImpactRepository(this._client);

  final ApiClient _client;

  static const String _base = 'recycleorigin/v1';

  Future<Result<ImpactData>> fetchImpact({String range = '30d'}) {
    return _client.get<ImpactData>(
      '$_base${Urls.statsImpactEndPoint}',
      queryParameters: <String, dynamic>{'range': range},
      parser: (dynamic data) =>
          ImpactData.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Result<LeaderboardData>> fetchLeaderboard({
    String range = '30d',
    String metric = 'weight',
    int limit = 20,
  }) {
    return _client.get<LeaderboardData>(
      '$_base${Urls.statsLeaderboardEndPoint}',
      queryParameters: <String, dynamic>{
        'range': range,
        'metric': metric,
        'limit': limit,
      },
      parser: (dynamic data) =>
          LeaderboardData.fromJson(data as Map<String, dynamic>),
    );
  }
}
