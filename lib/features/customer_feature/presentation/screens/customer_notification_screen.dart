import 'package:flutter/material.dart';
import '../../../meassage_feature/presentation/pages/messages_screen.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/customer.dart';
import '../../../../core/widgets/main_drawer.dart';

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
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: new IconThemeData(color: AppTheme.appBarIconColor),
      ),

      endDrawer: Theme(
        data: Theme.of(context).copyWith(
          // Set the transparency here
          canvasColor: Colors
              .transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
        ),
        child: MainDrawer(),
      ), // resizeToAvoidBottomInset: false,
      body: MessageScreen(),
    );
  }
}
