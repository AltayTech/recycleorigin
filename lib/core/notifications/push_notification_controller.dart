import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:recycleorigin/core/config/app_config.dart';
import 'package:recycleorigin/core/config/app_locale_controller.dart';
import 'package:recycleorigin/core/constants/urls.dart';
import 'package:recycleorigin/core/network/api_client.dart';
import 'package:recycleorigin/core/notifications/notification_deep_link.dart';
import 'package:recycleorigin/core/utils/logger.dart';

/// Registers this installation for push (Firebase Installation ID), shows
/// foreground notifications, and handles taps.
class PushNotificationController {
  PushNotificationController._();
  static final PushNotificationController instance =
      PushNotificationController._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  FirebaseMessaging? _messaging;
  ApiClient? _api;
  String? _lastRegisteredFid;
  bool _listenersAttached = false;
  Future<void>? _syncInFlight;
  DateTime? _deferSyncUntil;

  static const AndroidNotificationChannel _transactional =
      AndroidNotificationChannel(
        'transactional',
        'Transactional',
        description: 'Order, collect, and wallet updates.',
        importance: Importance.high,
      );

  static const AndroidNotificationChannel _marketing =
      AndroidNotificationChannel(
        'marketing',
        'Marketing',
        description: 'Promotional messages.',
        importance: Importance.defaultImportance,
      );

  /// Call after login and on cold start when already logged in.
  Future<void> syncAfterLogin(ApiClient api) async {
    if (!AppConfig.enablePushNotifications) {
      return;
    }
    final now = DateTime.now();
    final deferUntil = _deferSyncUntil;
    if (deferUntil != null && now.isBefore(deferUntil)) {
      return;
    }
    final running = _syncInFlight;
    if (running != null) {
      await running;
      return;
    }
    _syncInFlight = _syncAfterLoginInternal(api);
    try {
      await _syncInFlight;
    } finally {
      _syncInFlight = null;
    }
  }

  Future<void> _syncAfterLoginInternal(ApiClient api) async {
    if (kIsWeb) {
      return;
    }
    try {
      _messaging ??= FirebaseMessaging.instance;
      if (Platform.isIOS || Platform.isMacOS) {
        await _messaging!.requestPermission();
      } else if (Platform.isAndroid) {
        final st = await Permission.notification.status;
        if (!st.isGranted) {
          await Permission.notification.request();
        }
      }
      await _ensureLocalChannels();
      _api = api;
      if (!_listenersAttached) {
        _listenersAttached = true;
        // Subscribe before register() so the first FID is not missed. The
        // stream fires after every completed registration, including when
        // Firebase rotates the installation ID.
        _messaging!.onRegistered.listen(_onFidRegistered);
        FirebaseMessaging.onMessage.listen(_showLocalFromRemote);
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage m) {
          NotificationDeepLink.openFromData(_stringData(m.data));
        });
        final initial = await _messaging!.getInitialMessage();
        if (initial != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            NotificationDeepLink.openFromData(_stringData(initial.data));
          });
        }
      }
      await _registerWithBackoff();
      _deferSyncUntil = null;
    } catch (e, st) {
      var msg = 'Push init failed';
      if (Platform.isAndroid && _looksLikeTransientFcmInstallationsError(e)) {
        _deferSyncUntil = DateTime.now().add(const Duration(minutes: 2));
        msg =
            '$msg (Android: FCM needs Google Play services and network '
            'access; use a "Google Play" system image on emulators, update '
            'Play Store / Play services on device, or check VPN/firewall).';
        AppLogger.warning(msg);
        return;
      }
      AppLogger.error(msg, error: e, stackTrace: st);
    }
  }

  /// Sends the Firebase Installation ID (FID) from [FirebaseMessaging.onRegistered]
  /// to the backend as this device's push target.
  Future<void> _onFidRegistered(String fid) async {
    final api = _api;
    if (api == null || fid.isEmpty || fid == _lastRegisteredFid) {
      return;
    }
    try {
      final pkg = await PackageInfo.fromPlatform();
      final loc = AppLocaleController.instance.localeNotifier.value;
      final res = await api.post<Map<String, dynamic>>(
        '${Urls.rootUrl}/devices',
        data: <String, dynamic>{
          'token': fid,
          'kind': 'fid',
          'platform': Platform.isIOS ? 'ios' : 'android',
          'app': 'customer',
          'locale': loc.languageCode,
          'app_version': pkg.version,
        },
        parser: (d) => d as Map<String, dynamic>,
      );
      if (res.isSuccess) {
        _lastRegisteredFid = fid;
      }
    } catch (e, st) {
      AppLogger.error(
        'Push device registration failed',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// [FirebaseMessaging.register] occasionally fails with transient Play/FIS
  /// errors; brief backoff helps right after boot or Play services updates.
  Future<void> _registerWithBackoff() async {
    const backoffMs = <int>[0, 800, 1600, 3200];
    for (var i = 0; i < backoffMs.length; i++) {
      if (backoffMs[i] > 0) {
        await Future<void>.delayed(Duration(milliseconds: backoffMs[i]));
      }
      try {
        await _messaging!.register();
        return;
      } catch (e, st) {
        final retry =
            Platform.isAndroid &&
            i < backoffMs.length - 1 &&
            _looksLikeTransientFcmInstallationsError(e);
        if (!retry) {
          Error.throwWithStackTrace(e, st);
        }
      }
    }
  }

  static bool _looksLikeTransientFcmInstallationsError(Object e) {
    final text = e.toString();
    if (e is FirebaseException) {
      final m = e.message;
      if (m != null &&
          (m.contains('SERVICE_NOT_AVAILABLE') ||
              m.contains('FIS_AUTH_ERROR') ||
              m.contains('Firebase Installations Service is unavailable'))) {
        return true;
      }
    }
    return text.contains('SERVICE_NOT_AVAILABLE') ||
        text.contains('FIS_AUTH_ERROR') ||
        text.contains('FirebaseInstallationsException') ||
        text.contains('Firebase Installations Service is unavailable');
  }

  Map<String, dynamic> _stringData(Map<String, dynamic> raw) {
    final out = <String, dynamic>{};
    raw.forEach((k, v) {
      out[k] = v?.toString();
    });
    return out;
  }

  Future<void> onLogout(ApiClient api) async {
    final fid = _lastRegisteredFid;
    _lastRegisteredFid = null;
    _api = null;
    if (fid == null || fid.isEmpty) {
      return;
    }
    final path = '${Urls.rootUrl}/devices';
    await api.delete(path, queryParameters: <String, dynamic>{'token': fid});
    try {
      // Stop FCM delivering to this installation until the next login calls
      // register() again.
      await _messaging?.unregister();
    } catch (e, st) {
      AppLogger.warning('Push unregister failed: $e\n$st');
    }
  }

  Future<void> _ensureLocalChannels() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const init = InitializationSettings(android: androidInit, iOS: iosInit);
    await _local.initialize(
      settings: init,
      onDidReceiveNotificationResponse: (NotificationResponse r) {
        final p = r.payload;
        if (p == null || p.isEmpty) {
          return;
        }
        try {
          final map = jsonDecode(p) as Map<String, dynamic>;
          NotificationDeepLink.openFromData(map);
        } catch (_) {}
      },
    );
    final android = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(_transactional);
    await android?.createNotificationChannel(_marketing);
  }

  void _showLocalFromRemote(RemoteMessage m) {
    final n = m.notification;
    final title = n?.title ?? m.data['title']?.toString() ?? 'RecycleOrigin';
    final body = n?.body ?? m.data['body']?.toString() ?? '';
    final cat = m.data['category']?.toString() ?? 'transactional';
    final channelId = cat == 'marketing' ? _marketing.id : _transactional.id;
    final android = AndroidNotificationDetails(
      channelId,
      channelId == _marketing.id ? 'Marketing' : 'Transactional',
      channelDescription: '',
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    _local.show(
      id: m.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(android: android, iOS: ios),
      payload: jsonEncode(m.data),
    );
  }
}
