import 'package:flutter/material.dart';
import 'package:recycleorigin/core/constants/urls.dart';
import 'package:recycleorigin/core/network/api_client.dart';
import 'package:recycleorigin/core/notifications/notification_deep_link.dart';
import 'package:recycleorigin/core/notifications/notification_inbox_models.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/core/widgets/drawer_or_back_leading.dart';
import 'package:recycleorigin/features/customer_feature/presentation/screens/notification_preferences_screen.dart';

/// In-app notification inbox backed by GET /notifications.
class CustomerNotificationScreen extends StatefulWidget {
  static const routeName = '/customer_notification_screen';

  const CustomerNotificationScreen({super.key});

  @override
  State<CustomerNotificationScreen> createState() =>
      _CustomerNotificationScreenState();
}

class _CustomerNotificationScreenState extends State<CustomerNotificationScreen> {
  final ApiClient _api = ApiClient();
  final List<UserNotificationItem> _items = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_loading) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final path = '${Urls.rootUrl}/notifications';
    final res = await _api.get<Map<String, dynamic>>(
      path,
      queryParameters: <String, dynamic>{'page': 1, 'limit': 50},
      parser: (d) => d as Map<String, dynamic>,
    );
    if (!mounted) {
      return;
    }
    if (!res.isSuccess) {
      setState(() {
        _loading = false;
        _error = res.errorOrNull ?? 'Failed to load';
      });
      return;
    }
    final body = res.valueOrNull!;
    final raw = body['items'] as List<dynamic>? ?? [];
    final next = raw
        .map((e) => UserNotificationItem.fromJson(e as Map<String, dynamic>))
        .toList();
    setState(() {
      _items
        ..clear()
        ..addAll(next);
      _loading = false;
    });
  }

  Future<void> _markRead(UserNotificationItem it) async {
    if (it.isRead) {
      return;
    }
    final path = '${Urls.rootUrl}/notifications/${it.id}/read';
    await _api.post<Map<String, dynamic>>(path, parser: (d) => d as Map<String, dynamic>);
    setState(() {
      final i = _items.indexWhere((x) => x.id == it.id);
      if (i >= 0) {
        _items[i] = UserNotificationItem(
          id: it.id,
          title: it.title,
          body: it.body,
          category: it.category,
          createdAt: it.createdAt,
          readAt: DateTime.now().toUtc().toIso8601String(),
          deepLink: it.deepLink,
          dataJson: it.dataJson,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        centerTitle: true,
        title: const Text('Notifications'),
        backgroundColor: AppTheme.appBarColor,
        iconTheme: IconThemeData(color: AppTheme.appBarIconColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed(
                NotificationPreferencesScreen.routeName,
              );
            },
          ),
          TextButton(
            onPressed: _items.isEmpty
                ? null
                : () async {
                    final path = '${Urls.rootUrl}/notifications/read-all';
                    await _api.post<Map<String, dynamic>>(
                      path,
                      parser: (d) => d as Map<String, dynamic>,
                    );
                    if (mounted) {
                      await _load();
                    }
                  },
            child: const Text('Read all'),
          ),
        ],
      ),
      body: _error != null
          ? Center(child: Text(_error!))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, i) {
                  final it = _items[i];
                  return ListTile(
                    title: Text(
                      it.title,
                      style: TextStyle(
                        fontWeight:
                            it.isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(it.body),
                    trailing: Text(
                      it.createdAt.length > 16
                          ? it.createdAt.substring(0, 16)
                          : it.createdAt,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    onTap: () async {
                      await _markRead(it);
                      if (it.deepLink != null && it.deepLink!.isNotEmpty) {
                        NotificationDeepLink.openFromData(
                          <String, dynamic>{'deep_link': it.deepLink},
                        );
                      }
                    },
                  );
                },
              ),
            ),
    );
  }
}
