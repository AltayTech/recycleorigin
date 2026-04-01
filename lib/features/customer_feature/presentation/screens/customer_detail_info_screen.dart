import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/customer.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/customer_info_bloc.dart';
import 'customer_detail_info_edit_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/l10n/l10n.dart';

/// Screen that displays detailed customer information in a modern, production-grade UI
class CustomerDetailInfoScreen extends StatefulWidget {
  final Customer customer;

  const CustomerDetailInfoScreen({
    Key? key,
    required this.customer,
  }) : super(key: key);

  @override
  State<CustomerDetailInfoScreen> createState() =>
      _CustomerDetailInfoScreenState();
}

class _CustomerDetailInfoScreenState extends State<CustomerDetailInfoScreen> {
  Customer? _customer;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _customer = widget.customer;
    _loadCustomerData();
  }

  /// Loads customer data from the provider
  Future<void> _loadCustomerData() async {
    if (_isLoading || !mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await context.read<CustomerInfoBloc>().getCustomer();

      if (mounted) {
        final updatedCustomer = context.read<CustomerInfoBloc>().customer;

        setState(() {
          _customer = updatedCustomer;
          _isLoading = false;
          _isInitialized = true;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to load customer information. Please try again.';
          _isInitialized = true;
        });
      }
      debugPrint('Error loading customer data: $error');
    }
  }

  /// Handles navigation to edit screen
  void _navigateToEditScreen() {
    Navigator.of(context).pushReplacementNamed(
      CustomerDetailInfoEditScreen.routeName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: RefreshIndicator(
        onRefresh: _loadCustomerData,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildContent(context),
        ),
      ),
    );
  }

  /// Builds the main content based on current state
  Widget _buildContent(BuildContext context) {
    if (_isLoading && !_isInitialized) {
      return _buildLoadingState();
    }

    if (_errorMessage != null && _customer == null) {
      return _buildErrorState();
    }

    if (_customer == null) {
      return _buildEmptyState(context);
    }

    return _buildCustomerInfo(context);
  }

  /// Builds loading state widget
  Widget _buildLoadingState() {
    return SizedBox(
      height: 200,
      child: Center(
        child: SpinKitFadingCircle(
          color: AppTheme.primary,
          size: 50.0,
        ),
      ),
    );
  }

  /// Builds error state widget
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.colorOne,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An error occurred',
              style: TextStyle(
                color: AppTheme.h1,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadCustomerData,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.retryLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds empty state widget
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 64,
              color: AppTheme.grey,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.customerInfoUnavailableMessage,
              style: TextStyle(
                color: AppTheme.grey,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the main customer information display
  Widget _buildCustomerInfo(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildPersonalInfoSection(),
          const SizedBox(height: 16),
          _buildContactInfoSection(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Builds the header section with title and edit button
  Widget _buildHeader(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                'assets/images/user_Icon.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person,
                    color: AppTheme.primary,
                    size: 24,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Personal Info',
              style: TextStyle(
                color: AppTheme.h1,
                fontSize: textScaleFactor * 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _navigateToEditScreen,
          icon: const Icon(Icons.edit, size: 18),
          label: Text(context.l10n.editLabel),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: AppTheme.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the personal information section
  Widget _buildPersonalInfoSection() {
    final l10n = context.l10n;
    final na = l10n.valueNotAvailableLabel;
    return _buildInfoCard(
      title: l10n.personalInformationTitle,
      icon: Icons.person,
      iconColor: const Color(0xffA67FEC),
      children: [
        _InfoItem(
          title: l10n.nameLabel,
          value: _customer?.personalData.first_name ?? na,
          icon: Icons.badge,
        ),
        _InfoItem(
          title: l10n.lastNameLabel,
          value: _customer?.personalData.last_name ?? na,
          icon: Icons.badge_outlined,
        ),
        _InfoItem(
          title: l10n.userTypeLabel,
          value: _customer?.customer_type.name ?? na,
          icon: Icons.category,
        ),
      ],
    );
  }

  /// Builds the contact information section
  Widget _buildContactInfoSection() {
    final l10n = context.l10n;
    final na = l10n.valueNotAvailableLabel;
    return _buildInfoCard(
      title: l10n.contactInformationTitle,
      icon: Icons.contact_mail,
      iconColor: const Color(0xff4392F1),
      children: [
        _InfoItem(
          title: l10n.emailAddressLabel,
          value: _customer?.personalData.email ?? na,
          icon: Icons.email,
        ),
        _InfoItem(
          title: l10n.provinceFieldLabel,
          value: _customer?.personalData.ostan ?? na,
          icon: Icons.location_city,
        ),
        _InfoItem(
          title: l10n.cityFieldLabel,
          value: _customer?.personalData.city ?? na,
          icon: Icons.location_on,
        ),
        _InfoItem(
          title: l10n.zipCodeLabel,
          value: _customer?.personalData.postcode ?? na,
          icon: Icons.markunread_mailbox,
        ),
      ],
    );
  }

  /// Builds a card container for information sections
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.h1,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying individual information items with improved UI
class _InfoItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;

  const _InfoItem({
    required this.title,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: AppTheme.grey,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                '$title:',
                style: TextStyle(
                  color: AppTheme.grey,
                  fontSize: textScaleFactor * 13.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.secondary,
                width: 1,
              ),
            ),
            child: Text(
              value.isEmpty ? context.l10n.valueNotAvailableLabel : value,
              style: TextStyle(
                color: AppTheme.black,
                fontSize: textScaleFactor * 14.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
