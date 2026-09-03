import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Initializes Firebase on mobile/desktop where [DefaultFirebaseOptions] are
/// not required (Android/iOS use native config files).
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _initialized = false;

  /// Whether [Firebase.initializeApp] completed successfully.
  static bool get isInitialized => _initialized;

  /// No-op on web. Catches missing native config so local dev still runs.
  ///
  /// Logs in all modes: [assert] bodies are stripped in release, so errors
  /// must not rely on them (otherwise failures are silent).
  static Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }
    try {
      await Firebase.initializeApp();
      _initialized = true;
      await _configureAuth();
    } catch (e, st) {
      _initialized = false;
      developer.log(
        'Firebase init failed',
        name: 'recycleorigin.firebase',
        error: e,
        stackTrace: st,
      );
      assert(() {
        debugPrint('Firebase init skipped: $e');
        debugPrint('$st');
        return true;
      }());
    }
  }

  /// Debug builds skip Play Integrity / reCAPTCHA so email-password can run
  /// on emulators and unsigned-debug devices. Release pre-warms reCAPTCHA so
  /// the first sign-in is less likely to fail the wrapper race.
  static Future<void> _configureAuth() async {
    try {
      final auth = FirebaseAuth.instance;
      if (kDebugMode) {
        await auth.setSettings(appVerificationDisabledForTesting: true);
        developer.log(
          'Firebase Auth app verification disabled (debug)',
          name: 'recycleorigin.firebase',
        );
        return;
      }
      await auth.initializeRecaptchaConfig().timeout(
        const Duration(seconds: 10),
      );
    } catch (e, st) {
      developer.log(
        'Firebase Auth reCAPTCHA config skipped',
        name: 'recycleorigin.firebase',
        error: e,
        stackTrace: st,
      );
    }
  }
}
