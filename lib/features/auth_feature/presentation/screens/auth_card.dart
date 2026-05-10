import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/core/connection/http_exception.dart';
import 'package:recycleorigin/core/screens/navigation_bottom_screen.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/core/utils/logger.dart';
import 'package:recycleorigin/features/auth_feature/data/firebase_auth_service.dart';
import 'package:recycleorigin/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigin/features/auth_feature/presentation/screens/email_verification_screen.dart';
import 'package:recycleorigin/features/auth_feature/presentation/screens/forgot_password_screen.dart';
import 'package:recycleorigin/l10n/app_localizations.dart';
import 'package:recycleorigin/l10n/l10n.dart';

enum AuthMode { registration, login }

class AuthCard extends StatefulWidget {
  const AuthCard({super.key});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
    'first_name': '',
    'last_name': '',
  };

  bool _isLoading = false;
  bool _obscurePassword = true;

  static final RegExp _emailRegex = RegExp(
    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
  );

  void _showErrorDialog(String message, {String? detail}) {
    final l10n = context.l10n;
    final trimmed = detail?.trim();
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        final bodySmall = Theme.of(ctx).textTheme.bodySmall;
        return AlertDialog(
          icon: Icon(
            Icons.error_outline,
            color: scheme.error,
            size: 32,
          ),
          title: Text(l10n.authProblemTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              if (trimmed != null && trimmed.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  _truncateAuthDetail(trimmed),
                  style: bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.accept),
            ),
          ],
        );
      },
    );
  }

  static String _truncateAuthDetail(String s) {
    if (s.length <= 320) return s;
    return '${s.substring(0, 320)}…';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    final authBloc = context.read<AuthBloc>();
    final l10n = context.l10n;

    try {
      if (_authMode == AuthMode.login) {
        AppLogger.debug('Login mode');
        final ok = await authBloc.login(_authData);
        if (!mounted) return;
        if (ok) {
          _routePostLogin(authBloc.state.emailVerified);
        } else {
          _showErrorDialog(l10n.authLoginFailedInvalidCredentials);
        }
      } else {
        AppLogger.debug('Registration mode');
        final ok = await authBloc.register(_authData);
        if (!mounted) return;
        if (!ok) {
          _showErrorDialog(l10n.authGenericError);
          return;
        }
        Navigator.of(context).pushReplacementNamed(
          EmailVerificationScreen.routeName,
        );
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      _showErrorDialog(
        _mapAuthException(error, l10n),
        detail: _authExceptionDetail(error, l10n),
      );
    } on HttpException catch (error) {
      if (!mounted) return;
      _showErrorDialog(_mapHttpException(error.toString(), l10n));
    } catch (error, stackTrace) {
      AppLogger.error(
        'Auth submit failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      _showErrorDialog(l10n.authGenericError);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    final authBloc = context.read<AuthBloc>();
    final l10n = context.l10n;
    try {
      final ok = await authBloc.signInWithGoogle();
      if (!mounted || !ok) return;
      _routePostLogin(authBloc.state.emailVerified);
    } on AuthException catch (error) {
      if (!mounted) return;
      _showErrorDialog(
        _mapAuthException(error, l10n),
        detail: _authExceptionDetail(error, l10n),
      );
    } catch (_) {
      if (!mounted) return;
      _showErrorDialog(l10n.authGoogleSignInFailed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _routePostLogin(bool emailVerified) {
    if (!emailVerified) {
      Navigator.of(context).pushReplacementNamed(
        EmailVerificationScreen.routeName,
      );
      return;
    }
    Navigator.of(context)
        .pushReplacementNamed(NavigationBottomScreen.routeName);
  }

  String _mapAuthException(AuthException error, AppLocalizations l10n) {
    switch (error.code) {
      case AuthErrorCodes.wrongPassword:
      case AuthErrorCodes.userNotFound:
        return l10n.authLoginFailedInvalidCredentials;
      case AuthErrorCodes.invalidEmail:
        return l10n.authEmailInvalid;
      case AuthErrorCodes.weakPassword:
        return l10n.authPasswordTooShort;
      case AuthErrorCodes.emailAlreadyInUse:
        return l10n.authEmailAlreadyRegistered;
      case AuthErrorCodes.networkRequestFailed:
        return l10n.authNetworkError;
      case AuthErrorCodes.exchangeFailed:
        return l10n.authServerExchangeFailed;
      case AuthErrorCodes.cancelled:
        return l10n.authGenericError;
      case 'too-many-requests':
        return l10n.authTooManyRequests;
      case 'operation-not-allowed':
        return l10n.authOperationNotAllowed;
      case 'invalid-app-credential':
      case 'app-not-authorized':
        return l10n.authInvalidAppCredential;
      default:
        if (error.message.toUpperCase().contains('CONFIGURATION_NOT_FOUND')) {
          return l10n.authFirebaseConfigurationNotFound;
        }
        return l10n.authGenericError;
    }
  }

  /// Extra line for support (e.g. backend JSON or Firebase message).
  String? _authExceptionDetail(AuthException error, AppLocalizations l10n) {
    final m = error.message.trim();
    if (m.isEmpty || m == error.code) return null;
    if (error.code == AuthErrorCodes.exchangeFailed ||
        error.code == AuthErrorCodes.unknown ||
        error.code == 'internal-error') {
      return m;
    }
    if (_mapAuthException(error, l10n) == l10n.authGenericError) {
      return m;
    }
    return null;
  }

  String _mapHttpException(String raw, AppLocalizations l10n) {
    if (raw.contains('EMAIL_EXISTS')) {
      return l10n.authEmailAlreadyRegistered;
    }
    if (raw.contains('INVALID_EMAIL')) {
      return l10n.authEmailInvalid;
    }
    if (raw.contains('WEAK_PASSWORD')) {
      return l10n.authPasswordTooShort;
    }
    if (raw.contains('EMAIL_NOT_FOUND') || raw.contains('INVALID_PASSWORD')) {
      return l10n.authLoginFailedInvalidCredentials;
    }
    return l10n.authGenericError;
  }

  void _toggleMode() {
    FocusScope.of(context).unfocus();
    setState(() {
      _authMode =
          _authMode == AuthMode.login ? AuthMode.registration : AuthMode.login;
    });
  }

  String? _validateEmail(String? value) {
    final l10n = context.l10n;
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return l10n.authEmailRequired;
    }
    if (!_emailRegex.hasMatch(v)) {
      return l10n.authEmailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final l10n = context.l10n;
    if (value == null || value.isEmpty) {
      return l10n.authPasswordRequired;
    }
    if (_authMode == AuthMode.registration && value.length < 8) {
      return l10n.authPasswordTooShort;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final textTheme = theme.textTheme;
    final ext = theme.extension<AppColorsExtension>();

    final fieldTheme = theme.copyWith(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.45),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        labelStyle: textTheme.bodyMedium,
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: ext?.subtitleColor ?? colorScheme.onSurfaceVariant,
        ),
      ),
    );

    return Theme(
      data: fieldTheme,
      child: Card(
        elevation: 0,
        color: colorScheme.surface.withValues(alpha: 0.98),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _authMode == AuthMode.login
                      ? l10n.authWelcomeBackTitle
                      : l10n.authCreateAccountTitle,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  _authMode == AuthMode.login
                      ? l10n.authSubtitleSignIn
                      : l10n.authSubtitleSignUp,
                  style: textTheme.bodyMedium?.copyWith(
                    color: ext?.subtitleColor ?? colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingLg),
                AnimatedSize(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOutCubic,
                  alignment: Alignment.topCenter,
                  child: _authMode == AuthMode.registration
                      ? Column(
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: l10n.firstNameHint,
                                prefixIcon: Icon(
                                  Icons.person_outline_rounded,
                                  color: colorScheme.primary,
                                ),
                              ),
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.givenName],
                              validator: (v) {
                                if (_authMode != AuthMode.registration) {
                                  return null;
                                }
                                if (v == null || v.trim().isEmpty) {
                                  return l10n.authFirstNameRequired;
                                }
                                return null;
                              },
                              onSaved: (v) =>
                                  _authData['first_name'] = v?.trim() ?? '',
                            ),
                            const SizedBox(height: AppTheme.spacingMd),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: l10n.lastNameHint,
                                prefixIcon: Icon(
                                  Icons.badge_outlined,
                                  color: colorScheme.primary,
                                ),
                              ),
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.familyName],
                              validator: (v) {
                                if (_authMode != AuthMode.registration) {
                                  return null;
                                }
                                if (v == null || v.trim().isEmpty) {
                                  return l10n.authLastNameRequired;
                                }
                                return null;
                              },
                              onSaved: (v) =>
                                  _authData['last_name'] = v?.trim() ?? '',
                            ),
                            const SizedBox(height: AppTheme.spacingMd),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.emailAddressLabel,
                    hintText: l10n.emailInputHint,
                    prefixIcon: Icon(
                      Icons.alternate_email_rounded,
                      color: colorScheme.primary,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  autofillHints: const [AutofillHints.email],
                  validator: _validateEmail,
                  onSaved: (v) => _authData['email'] = v?.trim() ?? '',
                ),
                const SizedBox(height: AppTheme.spacingMd),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.passwordInputHint,
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      color: colorScheme.primary,
                    ),
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? l10n.authShowPassword
                          : l10n.authHidePassword,
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  autofillHints: _authMode == AuthMode.login
                      ? const [AutofillHints.password]
                      : const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    if (!_isLoading) {
                      _submit();
                    }
                  },
                  validator: _validatePassword,
                  onSaved: (v) => _authData['password'] = v ?? '',
                ),
                if (_authMode == AuthMode.login)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pushNamed(
                                ForgotPasswordScreen.routeName,
                              ),
                      child: Text(l10n.authForgotPasswordLink),
                    ),
                  ),
                const SizedBox(height: AppTheme.spacingLg),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : Text(
                            _authMode == AuthMode.login
                                ? l10n.login
                                : l10n.authRegisterButton,
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.onPrimary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: colorScheme.outline.withValues(alpha: 0.4),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSm,
                      ),
                      child: Text(
                        l10n.authOrDivider,
                        style: textTheme.bodySmall?.copyWith(
                          color: ext?.subtitleColor ??
                              colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: colorScheme.outline.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMd),
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      side: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.6),
                      ),
                    ),
                    icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                    label: Text(
                      l10n.authContinueWithGoogle,
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _isLoading ? null : _toggleMode,
                  child: Text(
                    _authMode == AuthMode.login
                        ? l10n.authNotRegisteredPrompt
                        : l10n.authSwitchToLoginPrompt,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
