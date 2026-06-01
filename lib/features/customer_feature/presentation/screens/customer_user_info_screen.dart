import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/drawer_or_back_leading.dart';
import 'customer_detail_info_screen.dart';

/// Shell route for viewing and editing personal customer information.
class CustomerUserInfoScreen extends StatelessWidget {
  static const routeName = '/customer_user_info_screen';

  const CustomerUserInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: const IconThemeData(color: AppTheme.appBarIconColor),
      ),
      drawer: mainDrawerIfRootRoute(context),
      body: Directionality(
        textDirection: Directionality.of(context),
        child: const CustomerDetailInfoScreen(),
      ),
    );
  }
}
