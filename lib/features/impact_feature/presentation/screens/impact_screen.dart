import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/core/network/api_client.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/core/theme/theme_context_extensions.dart';
import 'package:recycleorigin/features/impact_feature/data/impact_models.dart';
import 'package:recycleorigin/features/impact_feature/data/impact_repository.dart';
import 'package:recycleorigin/features/impact_feature/presentation/bloc/impact_cubit.dart';
import 'package:recycleorigin/features/impact_feature/presentation/bloc/impact_state.dart';
import 'package:recycleorigin/l10n/l10n.dart';

/// Gamified recycling impact dashboard for customers.
class ImpactScreen extends StatelessWidget {
  const ImpactScreen({super.key});

  static const routeName = '/impactScreen';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ImpactCubit(ImpactRepository(ApiClient()))..load(),
      child: const _ImpactView(),
    );
  }
}

class _ImpactView extends StatelessWidget {
  const _ImpactView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.impactTitle),
        actions: [
          BlocBuilder<ImpactCubit, ImpactState>(
            buildWhen: (a, b) => a.range != b.range,
            builder: (context, state) {
              return PopupMenuButton<String>(
                icon: Icon(Icons.date_range_outlined),
                initialValue: state.range,
                onSelected: context.read<ImpactCubit>().setRange,
                itemBuilder: (_) => [
                  PopupMenuItem(value: '7d', child: Text(l10n.impactRange7d)),
                  PopupMenuItem(value: '30d', child: Text(l10n.impactRange30d)),
                  PopupMenuItem(value: '90d', child: Text(l10n.impactRange90d)),
                ],
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded),
            onPressed: () => context.read<ImpactCubit>().load(),
          ),
        ],
      ),
      body: BlocBuilder<ImpactCubit, ImpactState>(
        builder: (context, state) {
          if (state.status == ImpactStatus.loading && state.impact == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ImpactStatus.error && state.impact == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.errorMessage ?? l10n.impactLoadError),
                    const SizedBox(height: AppTheme.spacingMd),
                    FilledButton(
                      onPressed: () => context.read<ImpactCubit>().load(),
                      child: Text(l10n.retryLabel),
                    ),
                  ],
                ),
              ),
            );
          }
          final data = state.impact;
          if (data == null) {
            return const SizedBox.shrink();
          }
          return RefreshIndicator(
            onRefresh: () => context.read<ImpactCubit>().load(),
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              children: [
                _ImpactHeroCard(metrics: data.impact),
                const SizedBox(height: AppTheme.spacingMd),
                _LevelCard(level: data.level),
                const SizedBox(height: AppTheme.spacingMd),
                _EquivalentsRow(metrics: data.impact),
                const SizedBox(height: AppTheme.spacingMd),
                Row(
                  children: [
                    Expanded(child: _StreakCard(streak: data.streak)),
                    const SizedBox(width: AppTheme.spacingSm),
                    Expanded(child: _GoalCard(goal: data.goal)),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMd),
                _TrendChartCard(series: data.series),
                const SizedBox(height: AppTheme.spacingMd),
                _BadgesSection(badges: data.badges),
                const SizedBox(height: AppTheme.spacingMd),
                _LeaderboardSection(
                  rank: data.rank,
                  leaderboard: state.leaderboard,
                ),
                const SizedBox(height: AppTheme.spacingXl),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ImpactHeroCard extends StatelessWidget {
  const _ImpactHeroCard({required this.metrics});

  final ImpactMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        gradient: LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppTheme.heroShadow(AppTheme.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.impactHeroTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              _HeroStat(
                label: l10n.impactWeightLabel,
                value: '${metrics.recycledWeightKg.toStringAsFixed(1)} kg',
                trend: metrics.weightTrend,
              ),
              const SizedBox(width: AppTheme.spacingMd),
              _HeroStat(
                label: l10n.impactCo2Label,
                value: '${metrics.co2SavedKg.toStringAsFixed(1)} kg',
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            children: [
              _HeroStat(
                label: l10n.impactPickupsLabel,
                value: '${metrics.completedPickups}',
                trend: metrics.pickupsTrend,
              ),
              const SizedBox(width: AppTheme.spacingMd),
              _HeroStat(
                label: l10n.impactEarningsLabel,
                value: '${metrics.earnings} ${metrics.currency}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
    this.trend,
  });

  final String label;
  final String value;
  final String? trend;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color:
                      context.appColors.onHeroForeground.withValues(alpha: 0.7),
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: context.appColors.onHeroForeground,
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (trend != null && trend!.isNotEmpty)
            Text(
              trend!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: context.appColors.onHeroForeground
                        .withValues(alpha: 0.6),
                  ),
            ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.level});

  final LevelInfo level;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: level.progress.clamp(0, 1),
                    strokeWidth: 6,
                    backgroundColor: context.appColors.divider,
                    color: AppTheme.primary,
                  ),
                  Text(
                    '${level.tier}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.tierName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    l10n.impactXpLabel(level.xp, level.xpToNext),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (level.nextTierName != null &&
                      level.nextTierName!.isNotEmpty)
                    Text(
                      l10n.impactNextTier(level.nextTierName!),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EquivalentsRow extends StatelessWidget {
  const _EquivalentsRow({required this.metrics});

  final ImpactMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _EquivChip(
            icon: Icons.park_outlined,
            label: l10n.impactTreesLabel,
            value: metrics.treesEquivalent.toStringAsFixed(1),
          ),
        ),
        const SizedBox(width: AppTheme.spacingSm),
        Expanded(
          child: _EquivChip(
            icon: Icons.water_drop_outlined,
            label: l10n.impactWaterLabel,
            value: metrics.waterLiters.toStringAsFixed(0),
          ),
        ),
        const SizedBox(width: AppTheme.spacingSm),
        Expanded(
          child: _EquivChip(
            icon: Icons.bolt_outlined,
            label: l10n.impactEnergyLabel,
            value: metrics.energyKwh.toStringAsFixed(0),
          ),
        ),
      ],
    );
  }
}

class _EquivChip extends StatelessWidget {
  const _EquivChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingSm),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryDark, size: 22),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});

  final StreakInfo streak;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              color: streak.active
                  ? context.appColors.warning
                  : context.appColors.subtitleColor,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              l10n.impactStreakTitle,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text(
              l10n.impactStreakValue(streak.current, streak.longest),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal});

  final GoalInfo goal;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.flag_rounded, color: AppTheme.primary),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              l10n.impactGoalTitle,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text(
              '${goal.current.toStringAsFixed(1)} / ${goal.target.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: goal.progress.clamp(0, 1),
                minHeight: 6,
                color: AppTheme.primary,
                backgroundColor: context.appColors.divider,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendChartCard extends StatelessWidget {
  const _TrendChartCard({required this.series});

  final ImpactSeries series;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spots = series.weightPoints
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.weight))
        .toList();
    if (spots.isEmpty) {
      spots.add(const FlSpot(0, 0));
    }
    final maxY = spots.map((s) => s.y).fold<double>(0, (a, b) => a > b ? a : b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.impactTrendTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData:
                      const FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 36),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(),
                    rightTitles: AxisTitles(),
                  ),
                  minY: 0,
                  maxY: maxY < 1 ? 1 : maxY * 1.2,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppTheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.primary.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgesSection extends StatelessWidget {
  const _BadgesSection({required this.badges});

  final List<BadgeInfo> badges;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.impactBadgesTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Wrap(
          spacing: AppTheme.spacingSm,
          runSpacing: AppTheme.spacingSm,
          children: badges.map((b) => _BadgeTile(badge: b)).toList(),
        ),
      ],
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});

  final BadgeInfo badge;

  @override
  Widget build(BuildContext context) {
    final opacity = badge.earned ? 1.0 : 0.45;
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(AppTheme.spacingSm),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: badge.earned ? AppTheme.primary : context.appColors.divider,
            width: badge.earned ? 2 : 1,
          ),
          boxShadow: AppTheme.cardShadow(context.colors.shadow),
        ),
        child: Column(
          children: [
            Icon(
              _iconFor(badge.icon),
              color: badge.earned
                  ? AppTheme.primaryDark
                  : context.appColors.subtitleColor,
            ),
            const SizedBox(height: 4),
            Text(
              badge.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (!badge.earned)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: LinearProgressIndicator(
                  value: badge.progress.clamp(0, 1),
                  minHeight: 3,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String key) {
    switch (key) {
      case 'eco':
        return Icons.eco_outlined;
      case 'flag':
        return Icons.flag_outlined;
      case 'military_tech':
        return Icons.military_tech_outlined;
      case 'inventory':
        return Icons.inventory_2_outlined;
      case 'local_fire_department':
        return Icons.local_fire_department_outlined;
      case 'emoji_events':
        return Icons.emoji_events_outlined;
      default:
        return Icons.star_outline_rounded;
    }
  }
}

class _LeaderboardSection extends StatelessWidget {
  const _LeaderboardSection({
    required this.rank,
    this.leaderboard,
  });

  final RankSummary rank;
  final LeaderboardData? leaderboard;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final entries = leaderboard?.entries ?? [];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.impactLeaderboardTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (rank.position > 0)
              Padding(
                padding: const EdgeInsets.only(top: AppTheme.spacingSm),
                child: Text(
                  l10n.impactRankSummary(
                    rank.position,
                    rank.totalParticipants,
                    rank.percentile,
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: AppTheme.spacingSm),
            if (entries.isEmpty)
              Text(l10n.impactLeaderboardEmpty)
            else
              ...entries.map(
                (e) => ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor:
                        e.isSelf ? AppTheme.primary : context.appColors.divider,
                    child: Text('${e.rank}'),
                  ),
                  title: Text(e.displayName),
                  trailing: Text(e.score.toStringAsFixed(1)),
                  tileColor: e.isSelf
                      ? AppTheme.primary.withValues(alpha: 0.08)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
