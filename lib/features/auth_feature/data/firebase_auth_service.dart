import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:recycleorigin/core/config/app_config.dart';
import 'package:recycleorigin/core/constants/urls.dart';
import 'package:recycleorigin/core/storage/secure_storage.dart';
import 'package:recycleorigin/core/utils/logger.dart';

/// Result of a successful Firebase exchange. Contains the backend access /
/// refresh tokens and the canonical user record from Postgres.
class FirebaseAuthResult {
  const FirebaseAuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final Map<String, dynamic> user;

  bool get emailVerified => user['email_verified'] == true;
  String get role => (user['role'] as String?) ?? '';
  String get provider => (user['auth_provider'] as String?) ?? '';
}

/// Stable error codes that callers can map to localized messages.
class AuthErrorCodes {
  static const wrongPassword = 'wrong-password';
  static const userNotFound = 'user-not-found';
  static const invalidEmail = 'invalid-email';
  static const emailAlreadyInUse = 'email-already-in-use';
  static const weakPassword = 'weak-password';
  static const networkRequestFailed = 'network-request-failed';
  static const cancelled = 'cancelled';
  static const noCurrentUser = 'no-current-user';
  static const emailNotVerified = 'email-not-verified';
  static const exchangeFailed = 'exchange-failed';
  static const unknown = 'unknown';
}

/// User-facing exception thrown by [FirebaseAuthService]. Use [code] to
/// route the UI to a localized message and [message] for the raw fallback.
class AuthException implements Exception {
  const AuthException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'AuthException($code): $message';
}

/// Wraps Firebase Auth + Google Sign-In and the backend
/// `POST /recycleorigin/v1/auth/firebase` exchange.
///
/// This is the ONLY place in the app that interacts with Firebase Auth
/// directly. The Bloc layer should call these methods and persist the
/// returned tokens via [SecureStorage].
class FirebaseAuthService {
  FirebaseAuthService({
    fb.FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    Dio? exchangeClient,
  })  : _authOverride = auth,
        _googleSignInOverride = googleSignIn,
        _exchangeClient = exchangeClient ?? _buildExchangeClient();

  final fb.FirebaseAuth? _authOverride;
  final GoogleSignIn? _googleSignInOverride;
  final Dio _exchangeClient;

  fb.FirebaseAuth? _auth;
  GoogleSignIn? _googleSignIn;

  /// Lazily resolves Firebase Auth so [AuthBloc] can be constructed even when
  /// native Firebase init failed during bootstrap (release ProGuard misconfig,
  /// missing google-services.json, etc.).
  fb.FirebaseAuth get _firebaseAuth =>
      _auth ??= _authOverride ?? _resolveFirebaseAuth();

  GoogleSignIn get _google =>
      _googleSignIn ??= _googleSignInOverride ?? GoogleSignIn.instance;

  Future<void>? _googleInit;

  fb.FirebaseAuth _resolveFirebaseAuth() {
    try {
      return fb.FirebaseAuth.instance;
    } catch (e) {
      throw AuthException(
        AuthErrorCodes.unknown,
        'Firebase is not initialized: $e',
      );
    }
  }

  static Dio _buildExchangeClient() {
    return Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  bool get hasFirebaseUser => _firebaseAuth.currentUser != null;
  fb.User? get currentUser => _firebaseAuth.currentUser;

  /// Sign in with email and password.
  Future<FirebaseAuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return await _exchangeWithBackend(cred.user!);
    } on fb.FirebaseAuthException catch (e) {
      throw _fromFirebase(e);
    } on Object catch (e, st) {
      AppLogger.error('Email sign-in failed', error: e, stackTrace: st);
      throw _wrap(e);
    }
  }

  /// Create a new email/password account, send the verification email, and
  /// exchange for backend tokens.
  Future<FirebaseAuthResult> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        throw const AuthException(
          AuthErrorCodes.unknown,
          'Account creation returned no user',
        );
      }
      if (displayName != null && displayName.trim().isNotEmpty) {
        try {
          await user.updateDisplayName(displayName.trim());
        } catch (_) {}
      }
      try {
        await user.sendEmailVerification();
      } catch (e, st) {
        AppLogger.warning('Failed to send verification email: $e', e, st);
      }
      return await _exchangeWithBackend(user);
    } on fb.FirebaseAuthException catch (e) {
      throw _fromFirebase(e);
    } on Object catch (e, st) {
      AppLogger.error('Email register failed', error: e, stackTrace: st);
      throw _wrap(e);
    }
  }

  /// Sign in with Google. User cancellation is reported as
  /// `code = AuthErrorCodes.cancelled`.
  Future<FirebaseAuthResult> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();
      final GoogleSignInAccount googleUser;
      try {
        googleUser = await _google.authenticate();
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled) {
          throw const AuthException(
            AuthErrorCodes.cancelled,
            'Google sign-in was cancelled',
          );
        }
        final detail = e.description ?? e.toString();
        throw AuthException(
          AuthErrorCodes.unknown,
          e.code == GoogleSignInExceptionCode.clientConfigurationError
              ? 'DEVELOPER_ERROR: $detail'
              : detail,
        );
      }
      final idToken = googleUser.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthException(
          AuthErrorCodes.unknown,
          'Google sign-in did not return an ID token',
        );
      }
      final credential = fb.GoogleAuthProvider.credential(idToken: idToken);
      final cred = await _firebaseAuth.signInWithCredential(credential);
      return await _exchangeWithBackend(cred.user!);
    } on fb.FirebaseAuthException catch (e) {
      throw _fromFirebase(e);
    } on AuthException {
      rethrow;
    } on Object catch (e, st) {
      AppLogger.error('Google sign-in failed', error: e, stackTrace: st);
      throw _wrap(e);
    }
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInit != null) {
      await _googleInit;
      return;
    }
    final pending = _google.initialize();
    _googleInit = pending;
    try {
      await pending;
    } catch (_) {
      _googleInit = null;
      rethrow;
    }
  }

  /// Send a password reset email via Firebase.
  Future<void> sendPasswordReset(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      throw _fromFirebase(e);
    } on Object catch (e) {
      throw _wrap(e);
    }
  }

  /// Resend the verification email to the current user.
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthException(
        AuthErrorCodes.noCurrentUser,
        'You must be signed in to resend verification',
      );
    }
    if (user.emailVerified) {
      return;
    }
    try {
      await user.sendEmailVerification();
    } on fb.FirebaseAuthException catch (e) {
      throw _fromFirebase(e);
    } on Object catch (e) {
      throw _wrap(e);
    }
  }

  /// Reload the Firebase user, then ask the backend to re-issue tokens
  /// reflecting the new `email_verified` claim. Returns null when the user
  /// is not yet verified or no Firebase session exists.
  Future<FirebaseAuthResult?> reloadAndExchangeIfVerified() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return null;
    }
    await user.reload();
    final refreshed = _firebaseAuth.currentUser;
    if (refreshed == null || !refreshed.emailVerified) {
      return null;
    }
    return _exchangeWithBackend(refreshed);
  }

  /// Sign out from Firebase and (best-effort) Google.
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (_) {}
    try {
      await _google.signOut();
    } catch (_) {}
  }

  Future<FirebaseAuthResult> _exchangeWithBackend(fb.User user) async {
    final idToken = await user.getIdToken(true);
    if (idToken == null || idToken.isEmpty) {
      throw const AuthException(
        AuthErrorCodes.exchangeFailed,
        'Failed to obtain Firebase ID token',
      );
    }
    try {
      final response = await _exchangeClient.post<Map<String, dynamic>>(
        Urls.firebaseExchangeEndPoint,
        data: {'id_token': idToken},
      );
      final body = response.data ?? const <String, dynamic>{};
      final access = (body['access_token'] ?? body['token']) as String? ?? '';
      final refresh = (body['refresh_token'] as String?) ?? '';
      final userMap =
          (body['user'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      if (access.isEmpty) {
        throw const AuthException(
          AuthErrorCodes.exchangeFailed,
          'Backend did not return an access token',
        );
      }
      await SecureStorage.saveAccessToken(access);
      if (refresh.isNotEmpty) {
        await SecureStorage.saveRefreshToken(refresh);
      }
      await SecureStorage.saveLoginStatus(true);
      return FirebaseAuthResult(
        accessToken: access,
        refreshToken: refresh,
        user: userMap,
      );
    } on DioException catch (e) {
      throw AuthException(
        AuthErrorCodes.exchangeFailed,
        e.response?.data?.toString() ?? e.message ?? 'Backend exchange failed',
      );
    }
  }

  AuthException _fromFirebase(fb.FirebaseAuthException e) {
    return AuthException(e.code, e.message ?? e.code);
  }

  AuthException _wrap(Object error) {
    if (error is AuthException) return error;
    return AuthException(AuthErrorCodes.unknown, error.toString());
  }
}
