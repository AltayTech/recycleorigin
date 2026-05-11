import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:recycleorigin/core/config/app_config.dart';
import 'package:recycleorigin/core/config/app_locale_controller.dart';
import 'package:recycleorigin/core/notifications/fcm_background.dart';
import 'package:recycleorigin/core/notifications/firebase_bootstrap.dart';
import 'package:recycleorigin/core/utils/app_info_service.dart';
import 'package:recycleorigin/recycle_origin_app.dart';

Future<void> bootstrapApp(String envFile) async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await AppConfig.initialize(envFile: envFile);
  await AppInfoService.instance.initialize();
  await AppLocaleController.instance.load();
  await FirebaseBootstrap.initialize();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(RecycleOriginApp());
}
