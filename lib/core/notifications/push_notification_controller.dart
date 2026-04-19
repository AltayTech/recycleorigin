import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:recycleorigin/core/config/app_locale_controller.dart';
import 'package:recycleorigin/core/constants/urls.dart';
import 'package:recycleorigin/core/network/api_client.dart';
import 'package:recycleorigin/core/notifications/notification_deep_link.dart';
import 'package:recycleorigin/core/utils/logger.dart';

/// Registers FCM token, shows foreground notifications, and handles taps.
class PushNotificationController {
  PushNotificationController._();
  static final PushNotificationController instance =
      PushNotificationController._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  FirebaseMessaging? _messaging;
  String? _lastRegisteredToken;
  bool _listenersAttached = false;

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
      final token = await _getFcmToken();
      if (token == null || token.isEmpty) {
        return;
      }
      if (token == _lastRegisteredToken) {
        return;
      }
      final pkg = await PackageInfo.fromPlatform();
      final loc = AppLocaleController.instance.localeNotifier.value;
      final body = <String, dynamic>{
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'app': 'customer',
        'locale': loc.languageCode,
        'app_version': pkg.version,
      };
      final path = '${Urls.rootUrl}/devices';
      final res = await api.post<Map<String, dynamic>>(
        path,
        data: body,
        parser: (d) => d as Map<String, dynamic>,
      );
      if (res.isSuccess) {
        _lastRegisteredToken = token;
      }
      if (!_listenersAttached) {
        _listenersAttached = true;
        _messaging!.onTokenRefresh.listen((t) async {
          _lastRegisteredToken = null;
          final b = Map<String, dynamic>.from(body)..['token'] = t;
          await api.post<Map<String, dynamic>>(path, data: b);
          _lastRegisteredToken = t;
        });
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
    } catch (e, st) {
      var msg = 'Push init failed';
      if (Platform.isAndroid && _looksLikeFcmServiceUnavailable(e)) {
        msg = '$msg (Android: FCM needs Google Play services and network '
            'access; use a "Google Play" system image on emulators, update '
            'Play Store / Play services on device, or check VPN/firewall).';
      }
      AppLogger.error(msg, error: e, stackTrace: st);
    }
  }

  /// [getToken] occasionally fails with SERVICE_NOT_AVAILABLE; brief backoff
  /// helps right after boot or Play services updates.
  Future<String?> _getFcmToken() async {
    const backoffMs = <int>[0, 800, 1600];
    for (var i = 0; i < backoffMs.length; i++) {
      if (backoffMs[i] > 0) {
        await Future<void>.delayed(Duration(milliseconds: backoffMs[i]));
      }
      try {
        return await _messaging!.getToken();
      } catch (e, st) {
        final retry = Platform.isAndroid &&
            i < backoffMs.length - 1 &&
            _looksLikeFcmServiceUnavailable(e);
        if (!retry) {
          Error.throwWithStackTrace(e, st);
        }
      }
    }
    return null;
  }

  static bool _looksLikeFcmServiceUnavailable(Object e) {
    if (e is FirebaseException) {
      final m = e.message;
      if (m != null && m.contains('SERVICE_NOT_AVAILABLE')) {
        return true;
      }
    }
    return e.toString().contains('SERVICE_NOT_AVAILABLE');
  }

  Map<String, dynamic> _stringData(Map<String, dynamic> raw) {
    final out = <String, dynamic>{};
    raw.forEach((k, v) {
      out[k] = v?.toString();
    });
    return out;
  }

  Future<void> onLogout(ApiClient api) async {
    final token = _lastRegisteredToken;
    _lastRegisteredToken = null;
    if (token == null || token.isEmpty) {
      return;
    }
    final path = '${Urls.rootUrl}/devices';
    await api.delete(path, queryParameters: <String, dynamic>{'token': token});
  }

  Future<void> _ensureLocalChannels() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const init = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
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
    final android = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
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
