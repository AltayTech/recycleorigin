import 'package:flutter/material.dart';

import '../../../../core/models/customer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/main_drawer.dart';
import '../widgets/profile_view.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  final Customer customer;

  ProfileScreen({
    customer,
  }) : this.customer = Customer();

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
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
      body: ProfileView(),
    );
  }
}
