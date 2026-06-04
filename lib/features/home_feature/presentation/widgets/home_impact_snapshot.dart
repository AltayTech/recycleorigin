import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/core/theme/theme_context_extensions.dart';
import 'package:recycleorigin/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigin/features/impact_feature/presentation/bloc/impact_cubit.dart';
import 'package:recycleorigin/features/impact_feature/presentation/bloc/impact_state.dart';
import 'package:recycleorigin/l10n/l10n.dart';

/// Compact impact stats row for the home dashboard.
class HomeImpactSnapshot extends StatelessWidget {
  const HomeImpactSnapshot({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isAuth = context.watch<AuthBloc>().isAuth;

    return Semantics(
      button: true,
      label: context.l10n.homeImpactTapHint,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
        child: Material(
          color: context.appColors.cardBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            side: BorderSide(
              color: AppTheme.serviceImpact.withValues(alpha: 0.12),
            ),
          ),
          child: InkWell(
            onTap: isAuth ? onTap : null,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.insights_rounded,
                        color: AppTheme.serviceImpact,
                        size: 22,
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Expanded(
                        child: Text(
                          context.l10n.homeDashboardImpactTitle,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      if (isAuth)
                        Icon(
                          Icons.chevron_right_rounded,
                          color: context.colors.onSurface.withValues(
                            alpha: 0.4,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  _ImpactBody(isAuthenticated: isAuth),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImpactBody extends StatelessWidget {
  const _ImpactBody({required this.isAuthenticated});

  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    if (!isAuthenticated) {
      return Text(
        context.l10n.homeLoginForDashboard,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.appColors.subtitleColor,
            ),
      );
    }

    return BlocBuilder<ImpactCubit, ImpactState>(
      builder: (context, state) {
        if (state.status == ImpactStatus.loading && state.impact == null) {
          return const _ImpactSkeleton();
        }
        if (state.status == ImpactStatus.error && state.impact == null) {
          return _ImpactError(
            message: state.errorMessage ?? context.l10n.impactLoadError,
            onRetry: () => context.read<ImpactCubit>().load(),
          );
        }
        final metrics = state.impact?.impact;
        if (metrics == null) {
          return const _ImpactSkeleton();
        }

        return Row(
          children: [
            Expanded(
              child: _StatTile(
                label: context.l10n.impactWeightLabel,
                value: '${metrics.recycledWeightKg.toStringAsFixed(1)} kg',
                icon: Icons.scale_rounded,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: _StatTile(
                label: context.l10n.impactCo2Label,
                value: '${metrics.co2SavedKg.toStringAsFixed(1)} kg',
                icon: Icons.cloud_outlined,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: _StatTile(
                label: context.l10n.impactPickupsLabel,
                value: '${metrics.completedPickups}',
                icon: Icons.local_shipping_outlined,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSm + 2),
      decoration: BoxDecoration(
        color: AppTheme.serviceImpact.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.serviceImpact),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.appColors.subtitleColor,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ImpactSkeleton extends StatelessWidget {
  const _ImpactSkeleton();

  @override
  Widget build(BuildContext context) {
    final base = context.appColors.divider;
    return Row(
      children: List.generate(
        3,
        (_) => Expanded(
          child: Container(
            height: 72,
            margin: const EdgeInsets.only(right: AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImpactError extends StatelessWidget {
  const _ImpactError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.colors.error,
              ),
        ),
        TextButton(onPressed: onRetry, child: Text(context.l10n.retryLabel)),
      ],
    );
  }
}
