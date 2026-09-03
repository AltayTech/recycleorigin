import 'package:flutter/material.dart';
import 'package:recycleorigin/core/constants/urls.dart';
import 'package:recycleorigin/core/network/api_client.dart';
import 'package:recycleorigin/core/network/api_provider.dart';
import 'package:recycleorigin/core/notifications/push_notification_controller.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/core/widgets/drawer_or_back_leading.dart';

/// Toggles push/in-app per category (transactional / marketing).
class NotificationPreferencesScreen extends StatefulWidget {
  static const routeName = '/notification_preferences';

  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  final ApiClient _api = ApiProvider.client;
  bool _loading = true;
  String? _error;
  final Map<String, Map<String, bool>> _prefs = {
    'transactional': {'push': true, 'inapp': true},
    'marketing': {'push': true, 'inapp': true},
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final path = '${Urls.rootUrl}/notifications/preferences';
    final res = await _api.get<Map<String, dynamic>>(
      path,
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
    final items = res.valueOrNull!['items'] as List<dynamic>? ?? [];
    for (final raw in items) {
      final m = raw as Map<String, dynamic>;
      final cat = m['Category'] as String? ?? m['category'] as String? ?? '';
      final ch = m['Channel'] as String? ?? m['channel'] as String? ?? '';
      final en = m['Enabled'] as bool? ?? m['enabled'] as bool? ?? true;
      _prefs.putIfAbsent(cat, () => {'push': true, 'inapp': true});
      if (ch == 'push' || ch == 'inapp') {
        _prefs[cat]![ch] = en;
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final items = <Map<String, dynamic>>[];
    _prefs.forEach((cat, chMap) {
      chMap.forEach((ch, en) {
        items.add(<String, dynamic>{
          'category': cat,
          'channel': ch,
          'enabled': en,
        });
      });
    });
    final path = '${Urls.rootUrl}/notifications/preferences';
    final res = await _api.put<Map<String, dynamic>>(
      path,
      data: <String, dynamic>{'items': items},
      parser: (d) => d as Map<String, dynamic>,
    );
    if (!mounted) {
      return;
    }
    if (res.isSuccess) {
      await PushNotificationController.instance.syncAfterLogin(_api);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res.errorOrNull ?? 'Save failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification settings'),
        leading: const DrawerOrBackLeading(),
        backgroundColor: AppTheme.appBarColor,
        iconTheme: IconThemeData(color: AppTheme.appBarIconColor),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : ListView(
              children: [
                for (final cat in _prefs.keys)
                  ExpansionTile(
                    title: Text(cat),
                    children: [
                      SwitchListTile(
                        title: const Text('Push'),
                        value: _prefs[cat]!['push']!,
                        onChanged: (v) =>
                            setState(() => _prefs[cat]!['push'] = v),
                      ),
                      SwitchListTile(
                        title: const Text('In-app inbox'),
                        value: _prefs[cat]!['inapp']!,
                        onChanged: (v) =>
                            setState(() => _prefs[cat]!['inapp'] = v),
                      ),
                    ],
                  ),
              ],
            ),
    );
  }
}
