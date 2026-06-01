/// API models for gamified impact stats.
class ImpactData {
  const ImpactData({
    required this.scope,
    required this.range,
    required this.impact,
    required this.level,
    required this.streak,
    required this.badges,
    required this.goal,
    required this.series,
    required this.rank,
  });

  factory ImpactData.fromJson(Map<String, dynamic> json) {
    return ImpactData(
      scope: json['scope'] as String? ?? 'customer',
      range: json['range'] as String? ?? '30d',
      impact: ImpactMetrics.fromJson(
        json['impact'] as Map<String, dynamic>? ?? {},
      ),
      level: LevelInfo.fromJson(
        json['level'] as Map<String, dynamic>? ?? {},
      ),
      streak: StreakInfo.fromJson(
        json['streak'] as Map<String, dynamic>? ?? {},
      ),
      badges: (json['badges'] as List<dynamic>? ?? [])
          .map((e) => BadgeInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      goal: GoalInfo.fromJson(json['goal'] as Map<String, dynamic>? ?? {}),
      series: ImpactSeries.fromJson(
        json['series'] as Map<String, dynamic>? ?? {},
      ),
      rank: RankSummary.fromJson(json['rank'] as Map<String, dynamic>? ?? {}),
    );
  }

  final String scope;
  final String range;
  final ImpactMetrics impact;
  final LevelInfo level;
  final StreakInfo streak;
  final List<BadgeInfo> badges;
  final GoalInfo goal;
  final ImpactSeries series;
  final RankSummary rank;
}

class ImpactMetrics {
  const ImpactMetrics({
    required this.recycledWeightKg,
    required this.completedPickups,
    required this.totalValue,
    required this.earnings,
    required this.walletBalance,
    required this.currency,
    this.averageRating,
    required this.co2SavedKg,
    required this.treesEquivalent,
    required this.waterLiters,
    required this.energyKwh,
    required this.periodWeightKg,
    required this.periodPickups,
    this.weightTrend,
    this.pickupsTrend,
  });

  factory ImpactMetrics.fromJson(Map<String, dynamic> json) {
    return ImpactMetrics(
      recycledWeightKg:
          (json['recycled_weight_kg'] as num?)?.toDouble() ?? 0,
      completedPickups:
          (json['completed_pickups'] as num?)?.toInt() ?? 0,
      totalValue: json['total_value'] as String? ?? '0',
      earnings: json['earnings'] as String? ?? '0',
      walletBalance: json['wallet_balance'] as String? ?? '0',
      currency: json['currency'] as String? ?? 'USD',
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      co2SavedKg: (json['co2_saved_kg'] as num?)?.toDouble() ?? 0,
      treesEquivalent:
          (json['trees_equivalent'] as num?)?.toDouble() ?? 0,
      waterLiters: (json['water_liters'] as num?)?.toDouble() ?? 0,
      energyKwh: (json['energy_kwh'] as num?)?.toDouble() ?? 0,
      periodWeightKg: (json['period_weight_kg'] as num?)?.toDouble() ?? 0,
      periodPickups: (json['period_pickups'] as num?)?.toInt() ?? 0,
      weightTrend: json['weight_trend'] as String?,
      pickupsTrend: json['pickups_trend'] as String?,
    );
  }

  final double recycledWeightKg;
  final int completedPickups;
  final String totalValue;
  final String earnings;
  final String walletBalance;
  final String currency;
  final double? averageRating;
  final double co2SavedKg;
  final double treesEquivalent;
  final double waterLiters;
  final double energyKwh;
  final double periodWeightKg;
  final int periodPickups;
  final String? weightTrend;
  final String? pickupsTrend;
}

class LevelInfo {
  const LevelInfo({
    required this.tier,
    required this.tierName,
    required this.xp,
    required this.xpToNext,
    required this.progress,
    this.nextTierName,
  });

  factory LevelInfo.fromJson(Map<String, dynamic> json) {
    return LevelInfo(
      tier: (json['tier'] as num?)?.toInt() ?? 1,
      tierName: json['tier_name'] as String? ?? 'Bronze',
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      xpToNext: (json['xp_to_next'] as num?)?.toInt() ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      nextTierName: json['next_tier_name'] as String?,
    );
  }

  final int tier;
  final String tierName;
  final int xp;
  final int xpToNext;
  final double progress;
  final String? nextTierName;
}

class StreakInfo {
  const StreakInfo({
    required this.current,
    required this.longest,
    required this.unit,
    required this.active,
  });

  factory StreakInfo.fromJson(Map<String, dynamic> json) {
    return StreakInfo(
      current: (json['current'] as num?)?.toInt() ?? 0,
      longest: (json['longest'] as num?)?.toInt() ?? 0,
      unit: json['unit'] as String? ?? 'weeks',
      active: json['active'] as bool? ?? false,
    );
  }

  final int current;
  final int longest;
  final String unit;
  final bool active;
}

class BadgeInfo {
  const BadgeInfo({
    required this.key,
    required this.name,
    required this.description,
    required this.icon,
    required this.earned,
    this.earnedAt,
    required this.progress,
    required this.target,
  });

  factory BadgeInfo.fromJson(Map<String, dynamic> json) {
    return BadgeInfo(
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'star',
      earned: json['earned'] as bool? ?? false,
      earnedAt: json['earned_at'] as String?,
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      target: (json['target'] as num?)?.toDouble() ?? 1,
    );
  }

  final String key;
  final String name;
  final String description;
  final String icon;
  final bool earned;
  final String? earnedAt;
  final double progress;
  final double target;
}

class GoalInfo {
  const GoalInfo({
    required this.period,
    required this.metric,
    required this.target,
    required this.current,
    required this.progress,
    required this.endsAt,
  });

  factory GoalInfo.fromJson(Map<String, dynamic> json) {
    return GoalInfo(
      period: json['period'] as String? ?? 'month',
      metric: json['metric'] as String? ?? 'weight_kg',
      target: (json['target'] as num?)?.toDouble() ?? 0,
      current: (json['current'] as num?)?.toDouble() ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      endsAt: json['ends_at'] as String? ?? '',
    );
  }

  final String period;
  final String metric;
  final double target;
  final double current;
  final double progress;
  final String endsAt;
}

class ImpactSeries {
  const ImpactSeries({
    required this.weightPoints,
    required this.pickupPoints,
  });

  factory ImpactSeries.fromJson(Map<String, dynamic> json) {
    return ImpactSeries(
      weightPoints: (json['weight_points'] as List<dynamic>? ?? [])
          .map((e) => WeightPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      pickupPoints: (json['pickup_points'] as List<dynamic>? ?? [])
          .map((e) => MetricPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final List<WeightPoint> weightPoints;
  final List<MetricPoint> pickupPoints;
}

class WeightPoint {
  const WeightPoint({required this.date, required this.weight});

  factory WeightPoint.fromJson(Map<String, dynamic> json) {
    return WeightPoint(
      date: json['date'] as String? ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
    );
  }

  final String date;
  final double weight;
}

class MetricPoint {
  const MetricPoint({required this.date, required this.count});

  factory MetricPoint.fromJson(Map<String, dynamic> json) {
    return MetricPoint(
      date: json['date'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  final String date;
  final int count;
}

class RankSummary {
  const RankSummary({
    required this.position,
    required this.totalParticipants,
    required this.percentile,
  });

  factory RankSummary.fromJson(Map<String, dynamic> json) {
    return RankSummary(
      position: (json['position'] as num?)?.toInt() ?? 0,
      totalParticipants:
          (json['total_participants'] as num?)?.toInt() ?? 0,
      percentile: (json['percentile'] as num?)?.toDouble() ?? 0,
    );
  }

  final int position;
  final int totalParticipants;
  final double percentile;
}

class LeaderboardData {
  const LeaderboardData({
    required this.scope,
    required this.metric,
    required this.range,
    required this.entries,
    this.self,
  });

  factory LeaderboardData.fromJson(Map<String, dynamic> json) {
    return LeaderboardData(
      scope: json['scope'] as String? ?? '',
      metric: json['metric'] as String? ?? '',
      range: json['range'] as String? ?? '30d',
      entries: (json['entries'] as List<dynamic>? ?? [])
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      self: json['self'] != null
          ? LeaderboardEntry.fromJson(
              json['self'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  final String scope;
  final String metric;
  final String range;
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? self;
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.displayName,
    required this.score,
    required this.isSelf,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      displayName: json['display_name'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0,
      isSelf: json['is_self'] as bool? ?? false,
    );
  }

  final int rank;
  final int userId;
  final String displayName;
  final double score;
  final bool isSelf;
}
