import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:recycleorigin/core/config/app_config.dart';
import 'package:recycleorigin/core/config/app_locale_controller.dart';
import 'package:recycleorigin/core/notifications/fcm_background.dart';
import 'package:recycleorigin/core/notifications/firebase_bootstrap.dart';
import 'package:recycleorigin/core/utils/app_info_service.dart';
import 'package:recycleorigin/recycle_origin_app.dart';

/// Bootstraps the customer app and required platform services.
///
/// Startup steps:
/// 1. Lock orientation to portrait.
/// 2. Load environment-based app configuration.
/// 3. Warm up app metadata service.
/// 4. Launch the root widget tree.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await AppConfig.initialize();

  await AppInfoService.instance.initialize();

  await AppLocaleController.instance.load();

  await FirebaseBootstrap.initialize();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(RecycleOriginApp());
}
