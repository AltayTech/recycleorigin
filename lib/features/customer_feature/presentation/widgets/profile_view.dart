import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:recycleorigin/core/models/customer.dart';
import 'package:recycleorigin/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigin/features/auth_feature/presentation/bloc/auth_state.dart';
import 'package:recycleorigin/features/auth_feature/presentation/screens/login_screen.dart';
import 'package:recycleorigin/features/customer_feature/business/entities/personal_data.dart';
import 'package:recycleorigin/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigin/features/customer_feature/presentation/bloc/customer_info_state.dart';
import 'package:recycleorigin/features/customer_feature/presentation/screens/customer_user_info_screen.dart';
import 'package:recycleorigin/features/store_feature/presentation/screens/orders_screen.dart';
import 'package:recycleorigin/features/support_tickets/presentation/screens/support_tickets_list_screen.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/address.dart';
import 'package:recycleorigin/features/impact_feature/presentation/screens/impact_screen.dart';
import 'package:recycleorigin/features/waste_feature/collect_list_screen.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../l10n/l10n.dart';

/// Profile tab / screen body: customer summary, shortcuts, and sign-out.
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    try {
      await context.read<CustomerInfoBloc>().getCustomer();
    } catch (error) {
      debugPrint('Error loading customer data: $error');
    } finally {
      if (mounted) {
        setState(() => _initialized = true);
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _loadCustomer();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (!authState.isAuth) {
          return const _GuestView();
        }
        if (!_initialized) {
          return const _LoadingView();
        }
        return BlocBuilder<CustomerInfoBloc, CustomerInfoState>(
          builder: (context, customerState) {
            final customer = customerState.customer;
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppTheme.primary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ProfileHero(personalData: customer.personalData),
                        const SizedBox(height: AppTheme.spacingSm),
                        _ProfileInfoCard(customer: customer),
                        _ProfileLocationCard(
                          personalData: customer.personalData,
                        ),
                        _WalletCard(money: customer.money),
                        const _MenuGrid(),
                        const _SignOutButton(),
                        const SizedBox(height: AppTheme.spacingLg),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Guest / loading ───────────────────────────────────────────────

class _GuestView extends StatelessWidget {
  const _GuestView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).extension<AppColorsExtension>();

    return Column(
      children: [
        _GradientBanner(
          height: 160,
          colors: colors,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  size: 88,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: AppTheme.spacingLg),
                Text(
                  l10n.youarenotlogin,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.colors.onSurface,
                      ),
                ),
                const SizedBox(height: AppTheme.spacingXl),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(LoginScreen.routeName);
                    },
                    child: Text(l10n.login),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitFadingCircle(
        color: AppTheme.primary,
        size: 48,
      ),
    );
  }
}

// ── Hero & avatar ─────────────────────────────────────────────────

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.personalData});

  final PersonalData personalData;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>();

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        _GradientBanner(
          height: 130,
          colors: colors,
        ),
        Positioned(
          bottom: -44,
          child: _AvatarCircle(initials: _profileInitials(personalData)),
        ),
      ],
    );
  }
}

class _GradientBanner extends StatelessWidget {
  const _GradientBanner({
    required this.height,
    this.colors,
  });

  final double height;
  final AppColorsExtension? colors;

  @override
  Widget build(BuildContext context) {
    final start = colors?.heroGradientStart ?? AppTheme.primary;
    final end = colors?.heroGradientEnd ?? AppTheme.primaryDark;

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [start, end],
        ),
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.initials});

  final String initials;

  static const double _size = 88;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primary.withValues(alpha: 0.15),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: AppTheme.cardShadow(AppTheme.primary),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

// ── Info cards ────────────────────────────────────────────────────

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final personalData = customer.personalData;
    final displayName = _profileDisplayName(personalData);
    final email = _profileEmail(personalData);
    final phone = _profilePhone(personalData);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingMd,
        52,
        AppTheme.spacingMd,
        AppTheme.spacingSm,
      ),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      displayName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: context.colors.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (customer.status.name.isNotEmpty)
                    _StatusChip(label: customer.status.name),
                ],
              ),
              if (email.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingSm),
                _ContactRow(
                  icon: Icons.email_outlined,
                  value: email,
                ),
              ],
              if (phone.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingXs),
                _ContactRow(
                  icon: Icons.phone_outlined,
                  value: phone,
                ),
              ],
              if (customer.customer_type.name.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingMd),
                Wrap(
                  spacing: AppTheme.spacingSm,
                  runSpacing: AppTheme.spacingSm,
                  children: [
                    _InfoChip(
                      icon: Icons.category_outlined,
                      label: customer.customer_type.name,
                      color: AppTheme.primaryDark,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileLocationCard extends StatelessWidget {
  const _ProfileLocationCard({required this.personalData});

  final PersonalData personalData;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasLocation =
        personalData.ostan.isNotEmpty || personalData.city.isNotEmpty;
    final hasAddresses = personalData.addresses.isNotEmpty;

    if (!hasLocation && !hasAddresses) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasLocation) ...[
                Row(
                  children: [
                    Icon(
                      Icons.location_city_outlined,
                      size: 20,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Text(
                      l10n.locationDetailsSection,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.colors.onSurface,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSm),
                if (personalData.ostan.isNotEmpty)
                  _LabelValueRow(
                    label: l10n.provinceFieldLabel,
                    value: personalData.ostan,
                  ),
                if (personalData.city.isNotEmpty)
                  _LabelValueRow(
                    label: l10n.cityFieldLabel,
                    value: personalData.city,
                  ),
              ],
              if (hasAddresses) ...[
                if (hasLocation) const SizedBox(height: AppTheme.spacingMd),
                Row(
                  children: [
                    Icon(
                      Icons.home_outlined,
                      size: 20,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Expanded(
                      child: Text(
                        l10n.addressCount(personalData.addresses.length),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.colors.onSurface,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSm),
                ...personalData.addresses.take(2).map(
                      (address) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppTheme.spacingSm,
                        ),
                        child: _AddressTile(address: address),
                      ),
                    ),
                if (personalData.addresses.length > 2)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          CustomerUserInfoScreen.routeName,
                        );
                      },
                      child: Text(l10n.personalInfoShortLabel),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({required this.money});

  final String money;

  @override
  Widget build(BuildContext context) {
    final balance = double.tryParse(money);
    if (balance == null || balance <= 0) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primary, AppTheme.primaryDark],
          ),
          boxShadow: AppTheme.heroShadow(AppTheme.primary),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.wallet,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  Text(
                    '${money} ${l10n.price_unit}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
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

// ── Menu grid ─────────────────────────────────────────────────────

class _MenuGrid extends StatelessWidget {
  const _MenuGrid();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingMd,
        AppTheme.spacingMd,
        AppTheme.spacingMd,
        AppTheme.spacingSm,
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: AppTheme.spacingMd,
        crossAxisSpacing: AppTheme.spacingMd,
        childAspectRatio: 1.05,
        children: [
          _MenuItem(
            title: l10n.impactTitle,
            icon: Icons.insights_rounded,
            onTap: () {
              Navigator.of(context).pushNamed(ImpactScreen.routeName);
            },
          ),
          _MenuItem(
            title: l10n.ordersLabel,
            icon: Icons.shopping_bag_outlined,
            onTap: () {
              Navigator.of(context).pushNamed(OrdersScreen.routeName);
            },
          ),
          _MenuItem(
            title: l10n.personalInfoShortLabel,
            icon: Icons.person_outline,
            onTap: () {
              Navigator.of(context).pushNamed(
                CustomerUserInfoScreen.routeName,
              );
            },
          ),
          _MenuItem(
            title: l10n.messagesInboxLabel,
            icon: Icons.mail_outline,
            onTap: () {
              Navigator.of(context).pushNamed(
                SupportTicketsListScreen.routeName,
              );
            },
          ),
          _MenuItem(
            title: l10n.profileRequestsMenuTitle,
            icon: Icons.recycling_outlined,
            onTap: () {
              Navigator.of(context).pushNamed(CollectListScreen.routeName);
            },
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.primary, size: 32),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: context.colors.onSurface,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sign out ──────────────────────────────────────────────────────

class _SignOutButton extends StatelessWidget {
  const _SignOutButton();

  Future<void> _confirmSignOut(BuildContext context) async {
    final l10n = context.l10n;
    final rootContext = context;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        var busy = false;
        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            Future<void> onConfirm() async {
              setLocalState(() => busy = true);
              try {
                rootContext.read<CustomerInfoBloc>().customer =
                    rootContext.read<CustomerInfoBloc>().customer_zero;
                await rootContext.read<AuthBloc>().removeToken();
                rootContext.read<AuthBloc>().isFirstLogout = true;
                if (ctx.mounted) {
                  Navigator.of(ctx).pop(true);
                }
              } catch (e) {
                if (rootContext.mounted) {
                  ScaffoldMessenger.of(rootContext).showSnackBar(
                    SnackBar(
                      content: Text('${l10n.signOutErrorPrefix}$e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                if (ctx.mounted) {
                  Navigator.of(ctx).pop(false);
                }
              } finally {
                if (ctx.mounted) {
                  setLocalState(() => busy = false);
                }
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              title: Text(l10n.signOutDialogTitle),
              content: Text(l10n.signOutDialogMessage),
              actions: [
                TextButton(
                  onPressed: busy
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.cancelLabel),
                ),
                TextButton(
                  onPressed: busy ? null : onConfirm,
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: busy
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(ctx).colorScheme.error,
                          ),
                        )
                      : Text(l10n.signOutConfirmButton),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.logoutSuccessSnack)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      child: OutlinedButton.icon(
        onPressed: () => _confirmSignOut(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red.shade700,
          side: BorderSide(color: Colors.red.shade300),
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
        ),
        icon: Icon(Icons.logout_rounded),
        label: Text(l10n.logout),
      ),
    );
  }
}

// ── Small shared widgets ──────────────────────────────────────────

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final subtitle =
        Theme.of(context).extension<AppColorsExtension>()?.subtitleColor ??
            context.appColors.subtitleColor;

    return Row(
      children: [
        Icon(icon, size: 16, color: subtitle),
        const SizedBox(width: AppTheme.spacingXs),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: subtitle,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
    final isActive = label.toLowerCase() == 'active';
    final color = isActive ? AppTheme.primary : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.spacingSm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppTheme.spacingXs),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelValueRow extends StatelessWidget {
  const _LabelValueRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final subtitle =
        Theme.of(context).extension<AppColorsExtension>()?.subtitleColor ??
            context.appColors.subtitleColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: subtitle,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurface,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({required this.address});

  final Address address;

  @override
  Widget build(BuildContext context) {
    final subtitle =
        Theme.of(context).extension<AppColorsExtension>()?.subtitleColor ??
            context.appColors.subtitleColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: context.appColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(AppTheme.spacingSm),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (address.name.isNotEmpty)
            Text(
              address.name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.onSurface,
                  ),
            ),
          if (address.address.isNotEmpty) ...[
            if (address.name.isNotEmpty)
              const SizedBox(height: AppTheme.spacingXs),
            Text(
              address.address,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: subtitle,
                  ),
            ),
          ],
          if (address.region.name.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingXs),
            Row(
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 14,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: AppTheme.spacingXs),
                Expanded(
                  child: Text(
                    address.region.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Display helpers ───────────────────────────────────────────────

String _profileInitials(PersonalData data) {
  final first = data.first_name.trim();
  final last = data.last_name.trim();
  if (first.isEmpty && last.isEmpty) {
    return '?';
  }
  final buffer = StringBuffer();
  if (first.isNotEmpty) {
    buffer.write(first[0].toUpperCase());
  }
  if (last.isNotEmpty) {
    buffer.write(last[0].toUpperCase());
  }
  return buffer.toString();
}

String _profileDisplayName(PersonalData data) {
  final fullName = '${data.first_name} ${data.last_name}'.trim();
  if (fullName.isNotEmpty) {
    return fullName;
  }
  if (data.phone.isNotEmpty) {
    return data.phone;
  }
  if (data.mobile.isNotEmpty) {
    return data.mobile;
  }
  return 'User';
}

String _profileEmail(PersonalData data) {
  if (data.email.isNotEmpty) {
    return data.email;
  }
  if (data.mobile.contains('@')) {
    return data.mobile;
  }
  return '';
}

String _profilePhone(PersonalData data) {
  if (data.phone.isNotEmpty) {
    return data.phone;
  }
  if (data.mobile.contains('@')) {
    return '';
  }
  return data.mobile;
}
