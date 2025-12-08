import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/customer.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/customer_info_provider.dart';
import 'customer_detail_info_edit_screen.dart';

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
      await Provider.of<CustomerInfoProvider>(context, listen: false)
          .getCustomer();
      
      if (mounted) {
        final updatedCustomer = Provider.of<CustomerInfoProvider>(
          context,
          listen: false,
        ).customer;
        
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
          _errorMessage = 'Failed to load customer information. Please try again.';
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
      return _buildEmptyState();
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
              label: const Text('Retry'),
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
  Widget _buildEmptyState() {
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
              'No customer information available',
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
          label: const Text('Edit'),
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
    return _buildInfoCard(
      title: 'Personal Information',
      icon: Icons.person,
      iconColor: const Color(0xffA67FEC),
      children: [
        _InfoItem(
          title: 'Name',
          value: _customer?.personalData.first_name ?? 'N/A',
          icon: Icons.badge,
        ),
        _InfoItem(
          title: 'Last Name',
          value: _customer?.personalData.last_name ?? 'N/A',
          icon: Icons.badge_outlined,
        ),
        _InfoItem(
          title: 'User Type',
          value: _customer?.customer_type.name ?? 'N/A',
          icon: Icons.category,
        ),
      ],
    );
  }

  /// Builds the contact information section
  Widget _buildContactInfoSection() {
    return _buildInfoCard(
      title: 'Contact Information',
      icon: Icons.contact_mail,
      iconColor: const Color(0xff4392F1),
      children: [
        _InfoItem(
          title: 'Email',
          value: _customer?.personalData.email ?? 'N/A',
          icon: Icons.email,
        ),
        _InfoItem(
          title: 'Province',
          value: _customer?.personalData.ostan ?? 'N/A',
          icon: Icons.location_city,
        ),
        _InfoItem(
          title: 'City',
          value: _customer?.personalData.city ?? 'N/A',
          icon: Icons.location_on,
        ),
        _InfoItem(
          title: 'Zip Code',
          value: _customer?.personalData.postcode ?? 'N/A',
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
              value.isEmpty ? 'N/A' : value,
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
