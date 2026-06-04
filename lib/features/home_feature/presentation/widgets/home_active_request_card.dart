import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/core/theme/theme_context_extensions.dart';
import 'package:recycleorigin/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/request_waste_item.dart';
import 'package:recycleorigin/l10n/l10n.dart';

/// Shows the most recent collection request on the home dashboard.
class HomeActiveRequestCard extends StatelessWidget {
  const HomeActiveRequestCard({
    super.key,
    required this.request,
    required this.isLoading,
    required this.hasError,
    required this.onTap,
    required this.onRetry,
  });

  final RequestWasteItem? request;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onTap;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isAuth = context.watch<AuthBloc>().isAuth;

    return Semantics(
      button: isAuth && request != null,
      label: context.l10n.homeRequestTapHint,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
        child: Material(
          color: context.appColors.cardBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            side: BorderSide(
              color: context.colors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: InkWell(
            onTap: isAuth && request != null ? onTap : null,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: _Body(
                isAuthenticated: isAuth,
                request: request,
                isLoading: isLoading,
                hasError: hasError,
                onRetry: onRetry,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.isAuthenticated,
    required this.request,
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
  });

  final bool isAuthenticated;
  final RequestWasteItem? request;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (!isAuthenticated) {
      return Text(
        context.l10n.pleaseLoginToViewRequests,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.appColors.subtitleColor,
            ),
      );
    }

    if (isLoading && request == null) {
      return const SizedBox(
        height: 48,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (hasError && request == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.somethingWentWrong,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.colors.error,
                ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(context.l10n.retryLabel),
          ),
        ],
      );
    }

    if (request == null) {
      return Row(
        children: [
          Icon(
            Icons.inbox_outlined,
            color: context.appColors.subtitleColor,
            size: 28,
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Text(
              context.l10n.homeActiveRequestEmpty,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.appColors.subtitleColor,
                  ),
            ),
          ),
        ],
      );
    }

    final item = request!;
    final statusLabel = item.requestStatusLabel.isNotEmpty
        ? item.requestStatusLabel
        : item.status.name;

    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.inventory_2_outlined,
              color: AppTheme.primary,
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${context.l10n.request} #${item.id}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                item.collect_date.day,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.appColors.subtitleColor,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        _StatusChip(label: statusLabel),
        const SizedBox(width: 4),
        Icon(
          Icons.chevron_right_rounded,
          color: context.colors.onSurface.withValues(alpha: 0.4),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.w600,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
