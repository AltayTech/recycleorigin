import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigin/features/store_feature/presentation/screens/orders_screen.dart';
import 'package:recycleorigin/features/waste_feature/collect_list_screen.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/main_item_button.dart';
import '../../../../core/widgets/top_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../meassage_feature/presentation/pages/messages_screen.dart';
import '../providers/authentication_provider.dart';
import '../providers/customer_info_provider.dart';
import '../screens/customer_user_info_screen.dart';
import '../screens/login_screen.dart';

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
  static const double _profileHeaderTopOffset = 0.07;
  static const double _gridTopOffset = 0.25;
  static const double _gridHeightFactor = 0.7;
  static const double _gridWidthFactor = 0.9;
  static const double _itemPaddingFactor = 0.03;
  static const double _horizontalPadding = 20.0;
  static const double _gridPadding = 5.0;
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
    return Consumer<AuthenticationProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isAuth) {
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
    final mediaQuery = MediaQuery.of(context);
    final deviceHeight = mediaQuery.size.height;
    final deviceWidth = mediaQuery.size.width;

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
            child: Stack(
              children: [
                TopBar(),
                _buildProfileHeader(context, deviceHeight, deviceWidth),
                _buildProfileGrid(context, deviceHeight, deviceWidth),
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
  Widget _buildProfileHeader(
    BuildContext context,
    double deviceHeight,
    double deviceWidth,
  ) {
    return Consumer<CustomerInfoProvider>(
      builder: (context, customerProvider, _) {
        final customer = customerProvider.customer;
        final personalData = customer.personalData;
        final fullName =
            '${personalData.first_name} ${personalData.last_name}'.trim();
        final displayName = fullName.isEmpty
            ? (personalData.phone.isNotEmpty ? personalData.phone : 'User')
            : fullName;

        return Positioned(
          top: deviceHeight * _profileHeaderTopOffset,
          left: _horizontalPadding,
          right: _horizontalPadding,
          child: Container(
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
            child: Row(
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
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.h1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (personalData.email.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          personalData.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (customer.money.isNotEmpty &&
                          double.tryParse(customer.money) != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              size: 16,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${customer.money} ${AppLocalizations.of(context)?.price_unit ?? '\$'}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
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
          ),
        );
      },
    );
  }

  /// Builds the grid of profile action buttons
  Widget _buildProfileGrid(
    BuildContext context,
    double deviceHeight,
    double deviceWidth,
  ) {
    return Positioned(
      top: deviceHeight * _gridTopOffset,
      left: 0,
      right: 0,
      child: Container(
        height: deviceHeight * _gridHeightFactor,
        width: deviceWidth * _gridWidthFactor,
        margin: EdgeInsets.symmetric(
          horizontal: deviceWidth * ((1 - _gridWidthFactor) / 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(_gridPadding),
          child: GridView.count(
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
                itemPaddingF: _itemPaddingFactor,
                imageSizeFactor: 0.25,
              ),
              _buildProfileMenuItem(
                context: context,
                title: 'Personal Info',
                iconPath: 'assets/images/user_Icon.png',
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(CustomerUserInfoScreen.routeName);
                },
                itemPaddingF: _itemPaddingFactor,
                imageSizeFactor: 0.30,
              ),
              _buildProfileMenuItem(
                context: context,
                title: 'Messages',
                iconPath: 'assets/images/message_icon.png',
                onTap: () {
                  Navigator.of(context).pushNamed(MessageScreen.routeName);
                },
                itemPaddingF: _itemPaddingFactor,
                imageSizeFactor: 0.25,
              ),
              _buildProfileMenuItem(
                context: context,
                title: 'Requests',
                iconPath: 'assets/images/main_page_request_ic.png',
                onTap: () {
                  Navigator.of(context).pushNamed(CollectListScreen.routeName);
                },
                itemPaddingF: _itemPaddingFactor,
                imageSizeFactor: 0.35,
              ),
            ],
          ),
        ),
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
