import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigin/features/store_feature/presentation/screens/orders_screen.dart';
import 'package:recycleorigin/features/waste_feature/collect_list_screen.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/main_item_button.dart';
import '../../../../core/widgets/top_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../meassage_feature/presentation/pages/messages_screen.dart';
import '../../../auth_feature/presentation/bloc/auth_bloc.dart';
import '../../../auth_feature/presentation/bloc/auth_state.dart';
import '../providers/customer_info_provider.dart';
import '../screens/customer_user_info_screen.dart';
import '../../../auth_feature/presentation/screens/login_screen.dart';

/// Profile view widget that displays user profile information and navigation options
class ProfileView extends StatefulWidget {
  ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _isLoading = false;
  bool _isInitialized = false;

  /// Constants for layout calculations
  static const double _horizontalPadding = 20.0;
  static const double _gridSpacing = 12.0;
  static const int _crossAxisCount = 2;
  static const double _childAspectRatio = 1.0;

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  /// Loads customer data from the provider
  Future<void> _loadCustomerData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<CustomerInfoProvider>(context, listen: false)
          .getCustomer();
    } catch (error) {
      // Error handling - could be extended to show error message to user
      debugPrint('Error loading customer data: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInitialized = true;
        });
      }
    }
  }

  /// Handles pull-to-refresh action
  Future<void> _handleRefresh() async {
    await _loadCustomerData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (!state.isAuth) {
          return _buildNotLoggedInView(context);
        }

        return _buildProfileContent(context);
      },
    );
  }

  /// Builds the view shown when user is not logged in
  Widget _buildNotLoggedInView(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 80,
              color: AppTheme.grey,
            ),
            const SizedBox(height: 24),
            Text(
              localizations?.youarenotlogin ?? 'You are not login!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppTheme.h1,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(LoginScreen.routeName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                localizations?.login ?? 'Login',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the main profile content when user is logged in
  Widget _buildProfileContent(BuildContext context) {
    if (_isLoading && !_isInitialized) {
      return _buildLoadingView();
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                TopBar(),
                _buildProfileHeader(context),
                _buildInfoSection(context),
                _buildProfileGrid(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the loading indicator view
  Widget _buildLoadingView() {
    return Center(
      child: SpinKitFadingCircle(
        color: AppTheme.primary,
        size: 50,
      ),
    );
  }

  /// Builds the profile header with user information
  Widget _buildProfileHeader(BuildContext context) {
    return Consumer<CustomerInfoProvider>(
      builder: (context, customerProvider, _) {
        final customer = customerProvider.customer;
        final personalData = customer.personalData;
        final fullName =
            '${personalData.first_name} ${personalData.last_name}'.trim();
        final displayName = fullName.isEmpty
            ? (personalData.phone.isNotEmpty
                ? personalData.phone
                : personalData.mobile.isNotEmpty
                    ? personalData.mobile
                    : 'User')
            : fullName;

        // Determine email - check email field first, then mobile (as it might contain email)
        final email = personalData.email.isNotEmpty
            ? personalData.email
            : (personalData.mobile.contains('@') ? personalData.mobile : '');

        // Determine phone - prefer phone field, fallback to mobile if it's not an email
        final phone = personalData.phone.isNotEmpty
            ? personalData.phone
            : (personalData.mobile.contains('@') ? '' : personalData.mobile);

        return Container(
          margin: const EdgeInsets.fromLTRB(
            _horizontalPadding,
            20,
            _horizontalPadding,
            16,
          ),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      border: Border.all(
                        color: AppTheme.primary,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                displayName,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.h1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (customer.status.name.isNotEmpty)
                              _buildStatusBadge(customer.status.name),
                          ],
                        ),
                        if (email.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 14,
                                color: AppTheme.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  email,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (phone.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 14,
                                color: AppTheme.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                phone,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(context, customer, personalData),
            ],
          ),
        );
      },
    );
  }

  /// Builds a status badge widget
  Widget _buildStatusBadge(String status) {
    final isActive = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.primary.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppTheme.primary : Colors.red,
          width: 1,
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive ? AppTheme.primary : Colors.red,
        ),
      ),
    );
  }

  /// Builds information row with wallet and other details
  Widget _buildInfoRow(
    BuildContext context,
    dynamic customer,
    dynamic personalData,
  ) {
    final localizations = AppLocalizations.of(context);
    final priceUnit = localizations?.price_unit ?? '\$';
    final hasMoney = customer.money.isNotEmpty &&
        double.tryParse(customer.money) != null &&
        double.parse(customer.money) > 0;

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        if (hasMoney)
          _buildInfoChip(
            icon: Icons.account_balance_wallet,
            label: '${customer.money} $priceUnit',
            color: AppTheme.primary,
          ),
        if (personalData.addresses.isNotEmpty)
          _buildInfoChip(
            icon: Icons.location_on,
            label:
                '${personalData.addresses.length} ${personalData.addresses.length == 1 ? 'Address' : 'Addresses'}',
            color: Colors.blue,
          ),
        if (customer.customer_type.name.isNotEmpty)
          _buildInfoChip(
            icon: Icons.category,
            label: customer.customer_type.name,
            color: Colors.purple,
          ),
      ],
    );
  }

  /// Builds an info chip widget
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
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

  /// Builds the information section with addresses and location
  Widget _buildInfoSection(BuildContext context) {
    return Consumer<CustomerInfoProvider>(
      builder: (context, customerProvider, _) {
        final customer = customerProvider.customer;
        final personalData = customer.personalData;
        final hasAddresses = personalData.addresses.isNotEmpty;
        final hasLocation =
            personalData.ostan.isNotEmpty || personalData.city.isNotEmpty;

        if (!hasAddresses && !hasLocation) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.08),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasLocation) ...[
                Row(
                  children: [
                    Icon(
                      Icons.location_city,
                      size: 18,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.h1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (personalData.ostan.isNotEmpty)
                  _buildInfoItem('Province', personalData.ostan),
                if (personalData.city.isNotEmpty)
                  _buildInfoItem('City', personalData.city),
                if (hasAddresses) const SizedBox(height: 16),
              ],
              if (hasAddresses) ...[
                Row(
                  children: [
                    Icon(
                      Icons.home,
                      size: 18,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Addresses (${personalData.addresses.length})',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.h1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...personalData.addresses.take(2).map((address) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildAddressCard(address),
                  );
                }),
                if (personalData.addresses.length > 2)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(CustomerUserInfoScreen.routeName);
                    },
                    child: Text(
                      'View all ${personalData.addresses.length} addresses',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Builds an info item row
  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.h1,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds an address card
  Widget _buildAddressCard(dynamic address) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (address.name.isNotEmpty)
            Text(
              address.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.h1,
              ),
            ),
          if (address.address.isNotEmpty) ...[
            if (address.name.isNotEmpty) const SizedBox(height: 4),
            Text(
              address.address,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.grey,
              ),
            ),
          ],
          if (address.region.name.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 12,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  address.region.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the grid of profile action buttons
  Widget _buildProfileGrid(BuildContext context) {
    final itemPaddingF = 0.03;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        _horizontalPadding,
        16,
        _horizontalPadding,
        0,
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: _crossAxisCount,
        childAspectRatio: _childAspectRatio,
        crossAxisSpacing: _gridSpacing,
        mainAxisSpacing: _gridSpacing,
        padding: const EdgeInsets.all(8),
        children: [
          _buildProfileMenuItem(
            context: context,
            title: 'Order',
            iconPath: 'assets/images/orders_list.png',
            onTap: () {
              Navigator.of(context).pushNamed(OrdersScreen.routeName);
            },
            itemPaddingF: itemPaddingF,
            imageSizeFactor: 0.25,
          ),
          _buildProfileMenuItem(
            context: context,
            title: 'Personal Info',
            iconPath: 'assets/images/user_Icon.png',
            onTap: () {
              Navigator.of(context).pushNamed(CustomerUserInfoScreen.routeName);
            },
            itemPaddingF: itemPaddingF,
            imageSizeFactor: 0.30,
          ),
          _buildProfileMenuItem(
            context: context,
            title: 'Messages',
            iconPath: 'assets/images/message_icon.png',
            onTap: () {
              Navigator.of(context).pushNamed(MessageScreen.routeName);
            },
            itemPaddingF: itemPaddingF,
            imageSizeFactor: 0.25,
          ),
          _buildProfileMenuItem(
            context: context,
            title: 'Requests',
            iconPath: 'assets/images/main_page_request_ic.png',
            onTap: () {
              Navigator.of(context).pushNamed(CollectListScreen.routeName);
            },
            itemPaddingF: itemPaddingF,
            imageSizeFactor: 0.35,
          ),
        ],
      ),
    );
  }

  /// Builds a single profile menu item button
  Widget _buildProfileMenuItem({
    required BuildContext context,
    required String title,
    required String iconPath,
    required VoidCallback onTap,
    required double itemPaddingF,
    required double imageSizeFactor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: MainItemButton(
          title: title,
          itemPaddingF: itemPaddingF,
          imageUrl: iconPath,
          isMonoColor: false,
          imageSizeFactor: imageSizeFactor,
        ),
      ),
    );
  }
}
