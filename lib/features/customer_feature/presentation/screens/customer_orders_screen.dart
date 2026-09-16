import 'package:flutter/material.dart';

import '../../../../core/models/customer.dart';
import '../../../../core/theme/app_theme.dart';
import 'customer_detail_order_screen.dart';
import '../../../../core/widgets/drawer_or_back_leading.dart';

class CustomerOrdersScreen extends StatefulWidget {
  static const routeName = '/customer_order_screen';
  final Customer customer;

  CustomerOrdersScreen({customer}) : this.customer = Customer();

  @override
  _CustomerOrdersScreenState createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: new IconThemeData(color: AppTheme.appBarIconColor),
      ),

      drawer: mainDrawerIfRootRoute(
        context,
      ), // resizeToAvoidBottomInset: false,
      body: CustomerDetailOrderScreen(customer: Customer()),
    );
  }
}
