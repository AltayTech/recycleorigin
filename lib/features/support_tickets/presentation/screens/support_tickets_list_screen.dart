import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/core/theme/theme_context_extensions.dart';
import 'package:recycleorigin/core/widgets/drawer_or_back_leading.dart';
import 'package:recycleorigin/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigin/features/auth_feature/presentation/screens/login_screen.dart';
import 'package:recycleorigin/features/support_tickets/data/support_ticket_models.dart';
import 'package:recycleorigin/features/support_tickets/presentation/cubit/support_tickets_list_cubit.dart';
import 'package:recycleorigin/features/support_tickets/presentation/screens/support_ticket_create_screen.dart';
import 'package:recycleorigin/features/support_tickets/presentation/screens/support_ticket_detail_screen.dart';
import 'package:recycleorigin/l10n/l10n.dart';

/// Lists support tickets for the logged-in customer.
class SupportTicketsListScreen extends StatefulWidget {
  const SupportTicketsListScreen({super.key});

  static const routeName = '/supportTickets';

  @override
  State<SupportTicketsListScreen> createState() =>
      _SupportTicketsListScreenState();
}

class _SupportTicketsListScreenState extends State<SupportTicketsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoad());
  }

  void _maybeLoad() {
    final auth = context.read<AuthBloc>();
    if (auth.isAuth) {
      context.read<SupportTicketsListCubit>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = context.watch<AuthBloc>();

    return Scaffold(
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        title: Text(
          l10n.supportScreenTitle,
          style: const TextStyle(color: AppTheme.appBarIconColor),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: IconThemeData(color: AppTheme.appBarIconColor),
        actions: <Widget>[
          if (auth.isAuth)
            IconButton(
              tooltip: 'Refresh',
              onPressed: () => context.read<SupportTicketsListCubit>().load(),
              icon: Icon(Icons.refresh, color: AppTheme.appBarIconColor),
            ),
        ],
      ),
      drawer: mainDrawerIfRootRoute(context),
      floatingActionButton: auth.isAuth
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.of(context).pushNamed(
                  SupportTicketCreateScreen.routeName,
                );
                if (context.mounted) {
                  context.read<SupportTicketsListCubit>().load();
                }
              },
              backgroundColor: AppTheme.primary,
              child: Icon(Icons.add, color: context.appColors.cardBackground),
            )
          : null,
      body: !auth.isAuth
          ? _LoginPrompt(
              onLogin: () => Navigator.of(context).pushNamed(
                LoginScreen.routeName,
              ),
            )
          : BlocBuilder<SupportTicketsListCubit, SupportTicketsListState>(
              builder: (context, state) {
                return switch (state) {
                  SupportTicketsListInitial() => Center(
                      child: CircularProgressIndicator(
                        color: context.appColors.subtitleColor,
                      ),
                    ),
                  SupportTicketsListLoading() => Center(
                      child: CircularProgressIndicator(
                        color: context.appColors.subtitleColor,
                      ),
                    ),
                  SupportTicketsListFailed(message: final message) =>
                    _ErrorBody(
                      message: message,
                      onRetry: () =>
                          context.read<SupportTicketsListCubit>().load(),
                    ),
                  SupportTicketsListReady(page: final page) => RefreshIndicator(
                      onRefresh: () =>
                          context.read<SupportTicketsListCubit>().load(),
                      child: page.items.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                ),
                                Center(child: Text(l10n.noMessagesYet)),
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(12),
                              itemCount: page.items.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, i) {
                                final t = page.items[i];
                                return _TicketTile(
                                  ticket: t,
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                      SupportTicketDetailScreen.routeName,
                                      arguments: t.id,
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                };
              },
            ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.pleaseLoginToContinue,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onLogin,
              child: Text(l10n.goToLoginScreenButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _TicketTile extends StatelessWidget {
  const _TicketTile({required this.ticket, required this.onTap});

  final SupportTicket ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: context.appColors.cardBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ticket.subject,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(status: ticket.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                ticket.ticketNumber,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: context.appColors.subtitleColor,
                ),
              ),
              if (ticket.lastMessagePreview != null &&
                  ticket.lastMessagePreview!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  ticket.lastMessagePreview!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'open' => context.appColors.info,
      'in_progress' => context.appColors.warning,
      'waiting_for_user' => AppTheme.iconAccentPurple,
      'resolved' => context.appColors.success,
      'closed' => context.appColors.subtitleColor,
      _ => context.appColors.subtitleColor,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
