import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/customer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/drawer_or_back_leading.dart';
import '../../../../core/widgets/info_edit_item.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/l10n.dart';
import '../bloc/customer_info_bloc.dart';

/// Screen for editing customer information with form validation and modern UI.
class CustomerDetailInfoEditScreen extends StatefulWidget {
  static const routeName = '/customerDetailInfoEditScreen';

  const CustomerDetailInfoEditScreen({super.key});

  @override
  State<CustomerDetailInfoEditScreen> createState() =>
      _CustomerDetailInfoEditScreenState();
}

class _CustomerDetailInfoEditScreenState
    extends State<CustomerDetailInfoEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _familyController = TextEditingController();
  final _emailDisplayController = TextEditingController();
  final _phoneDisplayController = TextEditingController();
  final _ostanController = TextEditingController();
  final _cityController = TextEditingController();
  final _postCodeController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _familyFocusNode = FocusNode();
  final _ostanFocusNode = FocusNode();
  final _cityFocusNode = FocusNode();
  final _postCodeFocusNode = FocusNode();
  final _emailFocusNode = FocusNode(canRequestFocus: false);
  final _phoneFocusNode = FocusNode(canRequestFocus: false);

  late final Customer _currentCustomer;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentCustomer = context.read<CustomerInfoBloc>().customer;
    _initializeForm();
  }

  void _initializeForm() {
    final data = _currentCustomer.personalData;
    _nameController.text = data.first_name;
    _familyController.text = data.last_name;
    _emailDisplayController.text = data.email;
    _ostanController.text = data.ostan;
    _cityController.text = data.city;
    _postCodeController.text = data.postcode;
    final phoneDisplay = data.mobile.trim().isNotEmpty
        ? data.mobile.trim()
        : data.phone.trim();
    _phoneDisplayController.text = phoneDisplay;
  }

  Future<void> _handleSave() async {
    if (_isSaving || !mounted) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final personalData = _currentCustomer.personalData.copyWith(
        first_name: _nameController.text.trim(),
        last_name: _familyController.text.trim(),
        ostan: _ostanController.text.trim(),
        city: _cityController.text.trim(),
        postcode: _postCodeController.text.trim(),
      );

      final customerToSend = Customer(
        id: _currentCustomer.id,
        status: _currentCustomer.status,
        customer_type: _currentCustomer.customer_type,
        money: _currentCustomer.money,
        personalData: personalData,
      );

      await context.read<CustomerInfoBloc>().sendCustomer(customerToSend);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.informationUpdatedSuccess),
          backgroundColor: AppTheme.primary,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pop();
    } catch (error, stackTrace) {
      developer.log(
        'Failed to save customer profile',
        name: 'recycleorigin.profile',
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() {
          _errorMessage = context.l10n.failedSaveCustomerInfoMessage;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.failedSaveCustomerInfoMessage),
            backgroundColor: context.appColors.danger,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _familyController.dispose();
    _emailDisplayController.dispose();
    _phoneDisplayController.dispose();
    _ostanController.dispose();
    _cityController.dispose();
    _postCodeController.dispose();

    _nameFocusNode.dispose();
    _familyFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _ostanFocusNode.dispose();
    _cityFocusNode.dispose();
    _postCodeFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: const IconThemeData(color: AppTheme.appBarIconColor),
        title: Text(
          l10n.editPersonalInformationAppBarTitle,
          style: TextStyle(color: AppTheme.appBarIconColor),
        ),
      ),
      drawer: mainDrawerIfRootRoute(context),
      body: _buildBody(context),
      floatingActionButton: _buildSaveButton(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = context.l10n;
    final deviceHeight = MediaQuery.sizeOf(context).height;

    return Container(
      color: context.appColors.scaffoldBackground,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null && !_isSaving) _buildErrorMessage(),
              const SizedBox(height: 8),
              _buildPersonalInfoSection(context, deviceHeight, l10n),
              const SizedBox(height: 16),
              _buildContactInfoSection(context, deviceHeight, l10n),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.appColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.appColors.danger),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: context.appColors.danger, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: context.appColors.danger,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(
    BuildContext context,
    double deviceHeight,
    AppLocalizations l10n,
  ) {
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
              l10n.personalInformationTitle,
              Icons.person,
              AppTheme.iconAccentPurple,
            ),
            const SizedBox(height: 16),
            InfoEditItem(
              title: l10n.nameLabel,
              controller: _nameController,
              bgColor: context.appColors.cardBackground,
              iconColor: AppTheme.iconAccentPurple,
              keybordType: TextInputType.name,
              fieldHeight: deviceHeight * 0.06,
              thisFocusNode: _nameFocusNode,
              newFocusNode: _familyFocusNode,
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.profileNameRequiredMessage;
                }
                return null;
              },
            ),
            InfoEditItem(
              title: l10n.lastNameLabel,
              controller: _familyController,
              bgColor: context.appColors.cardBackground,
              iconColor: AppTheme.iconAccentPurple,
              keybordType: TextInputType.name,
              fieldHeight: deviceHeight * 0.06,
              thisFocusNode: _familyFocusNode,
              newFocusNode: _ostanFocusNode,
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.profileNameRequiredMessage;
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoSection(
    BuildContext context,
    double deviceHeight,
    AppLocalizations l10n,
  ) {
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
              l10n.contactInformationTitle,
              Icons.contact_mail,
              AppTheme.iconAccentBlue,
            ),
            const SizedBox(height: 16),
            InfoEditItem(
              title: l10n.emailAddressLabel,
              controller: _emailDisplayController,
              bgColor: context.appColors.cardBackground,
              iconColor: AppTheme.iconAccentBlue,
              keybordType: TextInputType.emailAddress,
              fieldHeight: deviceHeight * 0.06,
              thisFocusNode: _emailFocusNode,
              newFocusNode: _phoneFocusNode,
              readOnly: true,
              helperText: l10n.emailIsLoginCredentialHint,
              validator: (_) => null,
            ),
            InfoEditItem(
              title: l10n.mobileLabel,
              controller: _phoneDisplayController,
              bgColor: context.appColors.cardBackground,
              iconColor: AppTheme.iconAccentBlue,
              keybordType: TextInputType.phone,
              fieldHeight: deviceHeight * 0.06,
              thisFocusNode: _phoneFocusNode,
              newFocusNode: _ostanFocusNode,
              readOnly: true,
              helperText: l10n.phoneIsLoginIdentifierHint,
              validator: (_) => null,
            ),
            InfoEditItem(
              title: l10n.provinceFieldLabel,
              controller: _ostanController,
              bgColor: context.appColors.cardBackground,
              iconColor: AppTheme.iconAccentBlue,
              keybordType: TextInputType.text,
              fieldHeight: deviceHeight * 0.06,
              thisFocusNode: _ostanFocusNode,
              newFocusNode: _cityFocusNode,
              validator: (_) => null,
            ),
            InfoEditItem(
              title: l10n.cityFieldLabel,
              controller: _cityController,
              bgColor: context.appColors.cardBackground,
              iconColor: AppTheme.iconAccentBlue,
              keybordType: TextInputType.text,
              fieldHeight: deviceHeight * 0.06,
              thisFocusNode: _cityFocusNode,
              newFocusNode: _postCodeFocusNode,
              validator: (_) => null,
            ),
            InfoEditItem(
              title: l10n.zipCodeLabel,
              controller: _postCodeController,
              bgColor: context.appColors.cardBackground,
              iconColor: AppTheme.iconAccentBlue,
              keybordType: TextInputType.number,
              fieldHeight: deviceHeight * 0.06,
              thisFocusNode: _postCodeFocusNode,
              newFocusNode: _postCodeFocusNode,
              textInputAction: TextInputAction.done,
              validator: (String? value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return null;
                }
                if (trimmed.length != 5) {
                  return l10n.postalCodeHintMessage;
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: context.colors.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    final l10n = context.l10n;

    return FloatingActionButton.extended(
      onPressed: _isSaving ? null : _handleSave,
      backgroundColor: AppTheme.primary,
      foregroundColor: context.appColors.cardBackground,
      icon: _isSaving
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.appColors.onHeroForeground,
                ),
              ),
            )
          : Icon(Icons.check),
      label: Text(
        _isSaving ? l10n.savingLabel : l10n.saveChangesLabel,
      ),
    );
  }
}
