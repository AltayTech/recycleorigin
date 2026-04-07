import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/customer.dart';
import '../../business/entities/personal_data.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/customer_info_bloc.dart';
import '../../../../core/widgets/info_edit_item.dart';
import '../../../../core/widgets/main_drawer.dart';
import 'customer_user_info_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/l10n/l10n.dart';

/// Screen for editing customer information with form validation and modern UI
class CustomerDetailInfoEditScreen extends StatefulWidget {
  static const routeName = '/customerDetailInfoEditScreen';

  const CustomerDetailInfoEditScreen({Key? key}) : super(key: key);

  @override
  State<CustomerDetailInfoEditScreen> createState() =>
      _CustomerDetailInfoEditScreenState();
}

class _CustomerDetailInfoEditScreenState
    extends State<CustomerDetailInfoEditScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers
  final _nameController = TextEditingController();
  final _familyController = TextEditingController();
  final _emailController = TextEditingController();
  final _ostanController = TextEditingController();
  final _cityController = TextEditingController();
  final _postCodeController = TextEditingController();

  // Focus nodes for better UX
  final _nameFocusNode = FocusNode();
  final _familyFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _ostanFocusNode = FocusNode();
  final _cityFocusNode = FocusNode();
  final _postCodeFocusNode = FocusNode();

  // State variables
  late final Customer _currentCustomer;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentCustomer = context.read<CustomerInfoBloc>().customer;
    _initializeForm();
  }

  /// Initializes form fields with current customer data
  void _initializeForm() {
    _nameController.text = _currentCustomer.personalData.first_name;
    _familyController.text = _currentCustomer.personalData.last_name;
    _emailController.text = _currentCustomer.personalData.email;
    _ostanController.text = _currentCustomer.personalData.ostan;
    _cityController.text = _currentCustomer.personalData.city;
    _postCodeController.text = _currentCustomer.personalData.postcode;
  }

  /// Validates the form
  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }
    return true;
  }

  /// Handles form submission
  Future<void> _handleSave() async {
    if (!_validateForm() || _isSaving || !mounted) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      // Capture form values
      final firstName = _nameController.text.trim();
      final lastName = _familyController.text.trim();
      final email = _emailController.text.trim();
      final city = _cityController.text.trim();
      final ostan = _ostanController.text.trim();
      final postcode = _postCodeController.text.trim();

      // Debug: Verify values are captured
      debugPrint('Form values captured:');
      debugPrint('First Name: $firstName');
      debugPrint('Last Name: $lastName');
      debugPrint('Email: $email');
      debugPrint('City: $city');
      debugPrint('Province: $ostan');
      debugPrint('Postcode: $postcode');

      final personalData = PersonalData(
        first_name: firstName,
        last_name: lastName,
        email: email,
        city: city,
        ostan: ostan,
        postcode: postcode,
      );

      final customerToSend = Customer(
        customer_type: _currentCustomer.customer_type,
        personalData: personalData,
      );

      // Debug: Verify Customer object
      debugPrint('Customer object created:');
      debugPrint(
          'PersonalData first_name: ${customerToSend.personalData.first_name}');
      debugPrint(
          'PersonalData last_name: ${customerToSend.personalData.last_name}');
      debugPrint('Customer type: ${customerToSend.customer_type.name}');

      await context.read<CustomerInfoBloc>().sendCustomer(customerToSend);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.informationUpdatedSuccess),
            backgroundColor: AppTheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back after a short delay to show success message
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.of(context)
              .popAndPushNamed(CustomerUserInfoScreen.routeName);
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = context.l10n.failedSaveCustomerInfoMessage;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _errorMessage ?? context.l10n.failedSaveCustomerInfoMessage,
            ),
            backgroundColor: AppTheme.colorOne,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      debugPrint('Error saving customer data: $error');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _familyController.dispose();
    _emailController.dispose();
    _ostanController.dispose();
    _cityController.dispose();
    _postCodeController.dispose();

    _nameFocusNode.dispose();
    _familyFocusNode.dispose();
    _emailFocusNode.dispose();
    _ostanFocusNode.dispose();
    _cityFocusNode.dispose();
    _postCodeFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: const IconThemeData(color: AppTheme.appBarIconColor),
        title: Text(
          context.l10n.editPersonalInformationAppBarTitle,
          style: const TextStyle(color: AppTheme.appBarIconColor),
        ),
      ),
      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
        ),
        child: MainDrawer(),
      ),
      body: _buildBody(context),
      floatingActionButton: _buildSaveButton(context),
    );
  }

  /// Builds the main body content
  Widget _buildBody(BuildContext context) {
    return Container(
      color: AppTheme.bg,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null && !_isSaving) _buildErrorMessage(),
              const SizedBox(height: 8),
              _buildPersonalInfoSection(context),
              const SizedBox(height: 16),
              _buildContactInfoSection(context),
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
    );
  }

  /// Builds error message widget
  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.colorOne.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.colorOne, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppTheme.colorOne, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: AppTheme.colorOne,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the personal information section
  Widget _buildPersonalInfoSection(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;

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
            _buildSectionHeader(
              context.l10n.personalInformationTitle,
              Icons.person,
              const Color(0xffA67FEC),
            ),
            const SizedBox(height: 16),
            InfoEditItem(
              title: context.l10n.nameLabel,
              controller: _nameController,
              bgColor: AppTheme.white,
              iconColor: const Color(0xffA67FEC),
              keybordType: TextInputType.name,
              fieldHeight: deviceHeight * 0.06,
              thisFocusNode: _nameFocusNode,
              newFocusNode: _familyFocusNode,
            ),
            InfoEditItem(
              title: context.l10n.lastNameLabel,
              controller: _familyController,
              bgColor: AppTheme.white,
              iconColor: const Color(0xffA67FEC),
              keybordType: TextInputType.name,
              fieldHeight: deviceHeight * 0.06,
              thisFocusNode: _familyFocusNode,
              newFocusNode: _emailFocusNode,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the contact information section
  Widget _buildContactInfoSection(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;

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
            _buildSectionHeader(
              context.l10n.contactInformationTitle,
              Icons.contact_mail,
              const Color(0xff4392F1),
            ),
            const SizedBox(height: 16),
            InfoEditItem(
              title: context.l10n.emailAddressLabel,
              controller: _emailController,
              bgColor: AppTheme.white,
              iconColor: const Color(0xff4392F1),
              keybordType: TextInputType.emailAddress,
              fieldHeight: deviceHeight * 0.06,
              thisFocusNode: _emailFocusNode,
              newFocusNode: _ostanFocusNode,
            ),
            InfoEditItem(
              title: context.l10n.provinceFieldLabel,
              controller: _ostanController,
              bgColor: AppTheme.white,
              iconColor: const Color(0xff4392F1),
              keybordType: TextInputType.text,
              fieldHeight: deviceHeight * 0.06,
              thisFocusNode: _ostanFocusNode,
              newFocusNode: _cityFocusNode,
            ),
            InfoEditItem(
              title: context.l10n.cityFieldLabel,
              controller: _cityController,
              bgColor: AppTheme.white,
              iconColor: const Color(0xff4392F1),
              keybordType: TextInputType.text,
              fieldHeight: deviceHeight * 0.06,
              thisFocusNode: _cityFocusNode,
              newFocusNode: _postCodeFocusNode,
            ),
            InfoEditItem(
              title: context.l10n.zipCodeLabel,
              controller: _postCodeController,
              bgColor: AppTheme.white,
              iconColor: const Color(0xff4392F1),
              keybordType: TextInputType.number,
              fieldHeight: deviceHeight * 0.06,
              thisFocusNode: _postCodeFocusNode,
              newFocusNode: _postCodeFocusNode,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds section header
  Widget _buildSectionHeader(String title, IconData icon, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
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
    );
  }

  /// Builds the save button
  Widget _buildSaveButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _isSaving ? null : _handleSave,
      backgroundColor: AppTheme.primary,
      foregroundColor: AppTheme.white,
      icon: _isSaving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.check),
      label: Text(
        _isSaving ? context.l10n.savingLabel : context.l10n.saveChangesLabel,
      ),
    );
  }
}
