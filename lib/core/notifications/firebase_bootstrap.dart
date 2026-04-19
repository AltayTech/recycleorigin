import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Initializes Firebase on mobile/desktop where [DefaultFirebaseOptions] are
/// not required (Android/iOS use native config files).
class FirebaseBootstrap {
  FirebaseBootstrap._();

  /// No-op on web. Catches missing native config so local dev still runs.
  static Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }
    try {
      await Firebase.initializeApp();
    } catch (e, st) {
      assert(() {
        debugPrint('Firebase init skipped: $e');
        debugPrint('$st');
        return true;
      }());
    }
  }
}
