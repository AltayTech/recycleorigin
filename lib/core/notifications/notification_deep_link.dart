import 'package:flutter/widgets.dart';
import 'package:recycleorigin/core/config/app_config.dart';
import 'package:recycleorigin/core/navigation/app_navigator.dart';
import 'package:recycleorigin/core/screens/coming_soon_screen.dart';
import 'package:recycleorigin/features/customer_feature/presentation/screens/customer_notification_screen.dart';
import 'package:recycleorigin/features/store_feature/presentation/screens/orders_screen.dart';
import 'package:recycleorigin/features/support_tickets/presentation/screens/support_tickets_list_screen.dart';
import 'package:recycleorigin/features/wallet_feature/presentation/pages/wallet_screen.dart';
import 'package:recycleorigin/features/waste_feature/collect_detail_screen.dart';
import 'package:recycleorigin/features/waste_feature/collect_list_screen.dart';

/// Maps FCM [data] payloads to named routes.
class NotificationDeepLink {
  NotificationDeepLink._();

  /// Opens a screen from notification [data] (e.g. `deep_link`, `type`).
  static void openFromData(Map<String, dynamic> data) {
    final nav = appNavigatorKey.currentState;
    if (nav == null) {
      return;
    }
    final deep = data['deep_link'] as String? ?? '';
    if (deep.startsWith('/collects/')) {
      final id = int.tryParse(deep.split('/').last);
      if (id != null) {
        nav.pushNamed(CollectDetailScreen.routeName, arguments: id);
      }
      return;
    }
    if (deep.startsWith('/orders/')) {
      _openStoreOrInbox(nav);
      return;
    }
    if (deep == '/wallet' || deep.startsWith('/wallet')) {
      nav.pushNamed(WalletScreen.routeName);
      return;
    }
    if (deep.startsWith('/tickets')) {
      nav.pushNamed(SupportTicketsListScreen.routeName);
      return;
    }
    final t = data['type'] as String? ?? '';
    if (t.startsWith('collect.')) {
      nav.pushNamed(CollectListScreen.routeName);
      return;
    }
    if (t.startsWith('order.')) {
      _openStoreOrInbox(nav);
      return;
    }
    nav.pushNamed(CustomerNotificationScreen.routeName);
  }

  static void _openStoreOrInbox(NavigatorState nav) {
    if (AppConfig.enableStore) {
      nav.pushNamed(OrdersScreen.routeName);
      return;
    }
    nav.pushNamed(ComingSoonScreen.routeName);
  }
}
