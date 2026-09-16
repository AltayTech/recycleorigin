import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/core/theme/theme_context_extensions.dart';
import 'package:recycleorigin/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigin/features/wallet_feature/presentation/bloc/wallet_summary_cubit.dart';
import 'package:recycleorigin/features/wallet_feature/presentation/bloc/wallet_summary_state.dart';
import 'package:recycleorigin/l10n/l10n.dart';

/// Wallet balance glance card on the home dashboard.
class HomeWalletPreviewCard extends StatelessWidget {
  const HomeWalletPreviewCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isAuth = context.watch<AuthBloc>().isAuth;

    return Semantics(
      button: true,
      label: context.l10n.homeWalletTapHint,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
        child: Material(
          color: context.appColors.cardBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            side: BorderSide(
              color: AppTheme.serviceWallet.withValues(alpha: 0.12),
            ),
          ),
          child: InkWell(
            onTap: isAuth ? onTap : null,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppTheme.serviceWallet.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: AppTheme.serviceWallet,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(child: _WalletBody(isAuthenticated: isAuth)),
                  if (isAuth)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: context.colors.onSurface.withValues(alpha: 0.4),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WalletBody extends StatelessWidget {
  const _WalletBody({required this.isAuthenticated});

  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: context.appColors.subtitleColor,
      fontWeight: FontWeight.w600,
    );

    if (!isAuthenticated) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.homeDashboardWalletTitle, style: titleStyle),
          const SizedBox(height: 4),
          Text(
            context.l10n.pleaseLoginToViewWallet,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    }

    return BlocBuilder<WalletSummaryCubit, WalletSummaryState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.homeDashboardWalletTitle, style: titleStyle),
            const SizedBox(height: 4),
            switch (state.status) {
              WalletSummaryStatus.loading ||
              WalletSummaryStatus.initial => const SizedBox(
                height: 20,
                width: 120,
                child: LinearProgressIndicator(minHeight: 4),
              ),
              WalletSummaryStatus.error => Text(
                state.errorMessage ?? context.l10n.somethingWentWrong,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: context.colors.error),
              ),
              WalletSummaryStatus.loaded => Text(
                '${state.wallet?.balance ?? '0'} ${state.wallet?.currency ?? ''}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.serviceWallet,
                ),
              ),
              WalletSummaryStatus.notAuthenticated => Text(
                context.l10n.pleaseLoginToViewWallet,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            },
          ],
        );
      },
    );
  }
}
