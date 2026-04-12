import 'package:flutter/material.dart';
import '../../../support_tickets/presentation/screens/support_tickets_list_screen.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/customer.dart';
import '../../../../core/widgets/drawer_or_back_leading.dart';

class CustomerNotificationScreen extends StatefulWidget {
  static const routeName = '/customer_notification_screen';
  final Customer customer;

  CustomerNotificationScreen({
    customer,
  }) : this.customer = Customer();

  @override
  _CustomerNotificationScreenState createState() =>
      _CustomerNotificationScreenState();
}

class _CustomerNotificationScreenState
    extends State<CustomerNotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: new IconThemeData(color: AppTheme.appBarIconColor),
      ),

      drawer: mainDrawerIfRootRoute(context), // resizeToAvoidBottomInset: false,
      body: const SupportTicketsListScreen(),
    );
  }
}
