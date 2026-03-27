import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigin/core/models/status.dart';

import '../../../../core/models/customer.dart';
import '../../business/entities/personal_data.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/customer_info_bloc.dart';
import '../../../../core/widgets/info_edit_item.dart';
import '../../../../core/widgets/main_drawer.dart';
import 'customer_user_info_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  List<Status> _typesList = [];
  String? _selectedTypeValue;
  Status? _selectedType;
  bool _isLoadingTypes = false;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadTypes();
  }

  /// Initializes form fields with current customer data
  void _initializeForm() {
    final customer = context.read<CustomerInfoBloc>().customer;

    _nameController.text = customer.personalData.first_name;
    _familyController.text = customer.personalData.last_name;
    _emailController.text = customer.personalData.email;
    _ostanController.text = customer.personalData.ostan;
    _cityController.text = customer.personalData.city;
    _postCodeController.text = customer.personalData.postcode;
    _selectedType = customer.customer_type;
    _selectedTypeValue = customer.customer_type.name;
  }

  /// Loads customer types from the provider
  Future<void> _loadTypes() async {
    if (_isLoadingTypes || !mounted) return;

    setState(() {
      _isLoadingTypes = true;
      _errorMessage = null;
    });

    try {
      await context.read<CustomerInfoBloc>().getTypes();

      if (mounted) {
        final typesList = context.read<CustomerInfoBloc>().typesItems;

        setState(() {
          _typesList = typesList;
          _isLoadingTypes = false;

          // Ensure selected type is still valid
          if (_selectedTypeValue != null) {
            final foundType = _typesList.firstWhere(
              (type) => type.name == _selectedTypeValue,
              orElse: () => _typesList.isNotEmpty ? _typesList.first : Status(),
            );
            _selectedType = foundType;
            _selectedTypeValue = foundType.name;
          } else if (_typesList.isNotEmpty) {
            _selectedType = _typesList.first;
            _selectedTypeValue = _typesList.first.name;
          }
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoadingTypes = false;
          _errorMessage = 'Failed to load user types. Please try again.';
        });
      }
      debugPrint('Error loading types: $error');
    }
  }

  /// Validates the form
  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a user type'),
          backgroundColor: AppTheme.colorOne,
        ),
      );
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
      debugPrint(
          'Customer Type: ${_selectedType?.name} (ID: ${_selectedType?.term_id})');

      final personalData = PersonalData(
        first_name: firstName,
        last_name: lastName,
        email: email,
        city: city,
        ostan: ostan,
        postcode: postcode,
      );

      final customerToSend = Customer(
        customer_type: _selectedType!,
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
            content: const Text('Information updated successfully'),
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
          _errorMessage = 'Failed to save information. Please try again.';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _errorMessage ?? 'An error occurred while saving',
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppTheme.appBarColor,
          iconTheme: const IconThemeData(color: AppTheme.appBarIconColor),
          title: const Text(
            'Edit Personal Information',
            style: TextStyle(color: AppTheme.appBarIconColor),
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
      ),
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
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
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
              'Personal Information',
              Icons.person,
              const Color(0xffA67FEC),
            ),
            const SizedBox(height: 16),
            InfoEditItem(
              title: 'Name',
              controller: _nameController,
              bgColor: AppTheme.white,
              iconColor: const Color(0xffA67FEC),
              keybordType: TextInputType.name,
              fieldHeight: deviceHeight * 0.06,
              thisFocusNode: _nameFocusNode,
              newFocusNode: _familyFocusNode,
            ),
            InfoEditItem(
              title: 'Last Name',
              controller: _familyController,
              bgColor: AppTheme.white,
              iconColor: const Color(0xffA67FEC),
              keybordType: TextInputType.name,
              fieldHeight: deviceHeight * 0.06,
              thisFocusNode: _familyFocusNode,
              newFocusNode: _emailFocusNode,
            ),
            const SizedBox(height: 8),
            _buildUserTypeDropdown(context, textScaleFactor, deviceHeight),
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
              'Contact Information',
              Icons.contact_mail,
              const Color(0xff4392F1),
            ),
            const SizedBox(height: 16),
            InfoEditItem(
              title: 'Email',
              controller: _emailController,
              bgColor: AppTheme.white,
              iconColor: const Color(0xff4392F1),
              keybordType: TextInputType.emailAddress,
              fieldHeight: deviceHeight * 0.06,
              thisFocusNode: _emailFocusNode,
              newFocusNode: _ostanFocusNode,
            ),
            InfoEditItem(
              title: 'Province',
              controller: _ostanController,
              bgColor: AppTheme.white,
              iconColor: const Color(0xff4392F1),
              keybordType: TextInputType.text,
              fieldHeight: deviceHeight * 0.06,
              thisFocusNode: _ostanFocusNode,
              newFocusNode: _cityFocusNode,
            ),
            InfoEditItem(
              title: 'City',
              controller: _cityController,
              bgColor: AppTheme.white,
              iconColor: const Color(0xff4392F1),
              keybordType: TextInputType.text,
              fieldHeight: deviceHeight * 0.06,
              thisFocusNode: _cityFocusNode,
              newFocusNode: _postCodeFocusNode,
            ),
            InfoEditItem(
              title: 'Zip Code',
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

  /// Builds the user type dropdown
  Widget _buildUserTypeDropdown(
    BuildContext context,
    double textScaleFactor,
    double deviceHeight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Icon(
                Icons.category,
                size: 16,
                color: AppTheme.grey,
              ),
              const SizedBox(width: 8),
              Text(
                'User Type:',
                style: TextStyle(
                  color: AppTheme.h1,
                  fontSize: textScaleFactor * 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          height: deviceHeight * 0.06,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppTheme.white,
            border: Border.all(color: AppTheme.secondary, width: 1),
          ),
          child: _isLoadingTypes
              ? Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    ),
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTypeValue,
                    hint: Text(
                      'Select User Type',
                      style: TextStyle(
                        color: AppTheme.grey,
                        fontSize: textScaleFactor * 14.0,
                      ),
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: AppTheme.black,
                      size: 24,
                    ),
                    dropdownColor: AppTheme.white,
                    style: TextStyle(
                      color: AppTheme.black,
                      fontSize: textScaleFactor * 14.0,
                    ),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedTypeValue = newValue;
                          _selectedType = _typesList.firstWhere(
                            (type) => type.name == newValue,
                          );
                        });
                      }
                    },
                    items: _typesList.map<DropdownMenuItem<String>>(
                      (Status type) {
                        return DropdownMenuItem<String>(
                          value: type.name,
                          child: Text(type.name),
                        );
                      },
                    ).toList(),
                  ),
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
      label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
    );
  }
}
