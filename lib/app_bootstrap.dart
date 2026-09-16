import 'dart:async';
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:recycleorigin/core/config/app_config.dart';
import 'package:recycleorigin/core/config/app_locale_controller.dart';
import 'package:recycleorigin/core/config/app_theme_controller.dart';
import 'package:recycleorigin/core/notifications/fcm_background.dart';
import 'package:recycleorigin/core/notifications/firebase_bootstrap.dart';
import 'package:recycleorigin/core/utils/app_info_service.dart';
import 'package:recycleorigin/core/utils/logger.dart';
import 'package:recycleorigin/recycle_origin_app.dart';

/// Boots the customer app with guarded initialization and global error hooks.
Future<void> bootstrapApp(String envFile) async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      _configureErrorHandlers();

      await _safeStep(
        'orientation',
        () => SystemChrome.setPreferredOrientations(const [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]),
      );
      await _safeStep(
        'AppConfig',
        () => AppConfig.initialize(envFile: envFile),
      );
      await _safeStep(
        'AppInfoService',
        () => AppInfoService.instance.initialize(),
      );
      await _safeStep(
        'AppLocaleController',
        () => AppLocaleController.instance.load(),
      );
      await _safeStep(
        'AppThemeController',
        () => AppThemeController.instance.load(),
      );
      await _safeStep(
        'FirebaseBootstrap',
        () => FirebaseBootstrap.initialize(),
      );
      await _enableCrashlytics();

      if (FirebaseBootstrap.isInitialized &&
          AppConfig.enablePushNotifications) {
        await _safeStep('FCM background handler', () async {
          FirebaseMessaging.onBackgroundMessage(
            firebaseMessagingBackgroundHandler,
          );
        });
      } else {
        AppLogger.warning(
          'Skipping FCM background handler '
          '(firebase=${FirebaseBootstrap.isInitialized}, '
          'push=${AppConfig.enablePushNotifications})',
        );
      }

      runApp(RecycleOriginApp());
    },
    (error, stack) {
      _recordFatal(error, stack);
      runApp(BootstrapErrorApp(error: error));
    },
  );
}

Future<void> _safeStep(String name, Future<void> Function() action) async {
  try {
    await action();
  } catch (error, stackTrace) {
    AppLogger.error(
      'Bootstrap step failed: $name',
      error: error,
      stackTrace: stackTrace,
    );
    await _recordNonFatal(error, stackTrace, reason: 'bootstrap:$name');
  }
}

Future<void> _enableCrashlytics() async {
  if (kIsWeb || !FirebaseBootstrap.isInitialized) {
    return;
  }
  try {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    _configureErrorHandlers(recordToCrashlytics: true);
  } catch (error, stackTrace) {
    AppLogger.warning('Crashlytics init failed', error, stackTrace);
  }
}

void _configureErrorHandlers({bool recordToCrashlytics = false}) {
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.error(
      'Flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
    );
    if (recordToCrashlytics) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    AppLogger.error(
      'Platform dispatcher error',
      error: error,
      stackTrace: stack,
    );
    if (recordToCrashlytics) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            kDebugMode
                ? details.exception.toString()
                : 'Something went wrong loading this screen.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  };
}

Future<void> _recordFatal(Object error, StackTrace stack) async {
  AppLogger.error('Uncaught bootstrap error', error: error, stackTrace: stack);
  if (kIsWeb || !FirebaseBootstrap.isInitialized) {
    return;
  }
  try {
    await FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  } catch (_) {}
}

Future<void> _recordNonFatal(
  Object error,
  StackTrace stack, {
  required String reason,
}) async {
  if (kIsWeb || !FirebaseBootstrap.isInitialized) {
    return;
  }
  try {
    await FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason: reason,
    );
  } catch (_) {}
}

/// Shown when bootstrap fails before the main app can start.
class BootstrapErrorApp extends StatelessWidget {
  const BootstrapErrorApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Color(0xFFD32F2F),
                ),
                const SizedBox(height: 16),
                const Text(
                  'RecycleOrigin could not start',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  kDebugMode
                      ? error.toString()
                      : 'Please update the app or try again later.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
