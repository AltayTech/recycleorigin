import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/features/auth_feature/data/firebase_auth_service.dart';
import 'package:recycleorigin/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigin/l10n/app_localizations.dart';
import 'package:recycleorigin/l10n/l10n.dart';

/// Lets the user request a password-reset email via Firebase.
///
/// The screen has two states:
///   - Form: email field + send button.
///   - Confirmation: success message with the email address.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail});

  static const routeName = '/auth/forgot-password';

  final String? initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  bool _isLoading = false;
  bool _sent = false;

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final l10n = context.l10n;
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l10n.authEmailRequired;
    if (!_emailRegex.hasMatch(v)) return l10n.authEmailInvalid;
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await context.read<AuthBloc>().sendPasswordReset(_emailController.text);
      if (!mounted) return;
      setState(() => _sent = true);
    } on AuthException catch (error) {
      if (!mounted) return;
      _showError(_mapAuthError(error, context.l10n));
    } catch (_) {
      if (!mounted) return;
      _showError(context.l10n.authGenericError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _mapAuthError(AuthException error, AppLocalizations l10n) {
    switch (error.code) {
      case AuthErrorCodes.invalidEmail:
        return l10n.authEmailInvalid;
      case AuthErrorCodes.userNotFound:
        return l10n.authLoginFailedInvalidCredentials;
      case AuthErrorCodes.networkRequestFailed:
        return l10n.authNetworkError;
      default:
        return l10n.authGenericError;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.authForgotPasswordTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: _sent
                ? _buildSentBody(theme, l10n)
                : _buildForm(theme, l10n, colorScheme),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(
    ThemeData theme,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.authForgotPasswordSubtitle,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(
              labelText: l10n.emailAddressLabel,
              prefixIcon: Icon(Icons.alternate_email_rounded,
                  color: colorScheme.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
            ),
            validator: _validateEmail,
            onFieldSubmitted: (_) => _isLoading ? null : _submit(),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.authForgotPasswordSendButton),
            ),
          ),
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: Text(l10n.authBackToLogin),
          ),
        ],
      ),
    );
  }

  Widget _buildSentBody(ThemeData theme, AppLocalizations l10n) {
    final email = _emailController.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.mark_email_read_outlined,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Text(
          l10n.authForgotPasswordSentTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          l10n.authForgotPasswordSentBody(email),
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingLg),
        SizedBox(
          height: 48,
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.authBackToLogin),
          ),
        ),
      ],
    );
  }
}
