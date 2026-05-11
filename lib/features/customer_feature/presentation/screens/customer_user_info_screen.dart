import 'package:flutter/material.dart';

import '../../../../core/models/customer.dart';
import '../../../../core/theme/app_theme.dart';
import 'customer_detail_info_screen.dart';
import '../../../../core/widgets/drawer_or_back_leading.dart';

class CustomerUserInfoScreen extends StatefulWidget {
  static const routeName = '/customer_user_info_screen';
  final Customer customer;

  CustomerUserInfoScreen({
    customer,
  }) : this.customer = Customer();

  @override
  _CustomerUserInfoScreenState createState() => _CustomerUserInfoScreenState();
}

class _CustomerUserInfoScreenState extends State<CustomerUserInfoScreen> {
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
      body: Directionality(
          textDirection: Directionality.of(context),
          child: CustomerDetailInfoScreen(
            customer: Customer(),
          )),
    );
  }
}
