import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/core/navigation/navigation_shell_scope.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/core/theme/theme_context_extensions.dart';
import 'package:recycleorigin/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigin/features/auth_feature/presentation/bloc/auth_state.dart';
import 'package:recycleorigin/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigin/l10n/l10n.dart';

/// Flat dashboard header: avatar, time-aware greeting, menu affordance.
class HomeGreetingHeader extends StatelessWidget {
  const HomeGreetingHeader({super.key});

  String _timeGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final l10n = context.l10n;
    if (hour < 12) return l10n.homeGreetingMorning;
    if (hour < 17) return l10n.homeGreetingAfternoon;
    return l10n.homeGreetingEvening;
  }

  String _displayName(BuildContext context, AuthState authState) {
    if (!authState.isAuth) {
      return context.l10n.guestUserLabel;
    }
    final customer = context.read<CustomerInfoBloc>().customer;
    final first = customer.personalData.first_name.trim();
    final last = customer.personalData.last_name.trim();
    final full = '$first $last'.trim();
    if (full.isNotEmpty) return full;
    final email = customer.personalData.email.trim();
    if (email.isNotEmpty) return email;
    return context.l10n.recycleorigin;
  }

  String _initials(String name) {
    final tokens = name.trim().split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
    final initials = tokens.take(2).map((t) => t[0]).join().toUpperCase();
    return initials.isEmpty ? '?' : initials;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final name = _displayName(context, authState);
        final showInitials =
            authState.isAuth && name != context.l10n.guestUserLabel;

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacingMd,
            AppTheme.spacingSm,
            AppTheme.spacingMd,
            AppTheme.spacingMd,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: colors.primaryContainer,
                foregroundColor: colors.onPrimaryContainer,
                child: showInitials
                    ? Text(
                        _initials(name),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : Icon(
                        Icons.eco_rounded,
                        color: colors.primary,
                        size: 28,
                      ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _timeGreeting(context),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: context.appColors.subtitleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.menu_rounded),
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                onPressed: () {
                  final key = NavigationShellScope.scaffoldKeyOf(context);
                  (key?.currentState ?? Scaffold.maybeOf(context))
                      ?.openDrawer();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
