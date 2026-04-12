import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/drawer_or_back_leading.dart';
import '../../../../l10n/l10n.dart';
import '../widgets/profile_view.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: IconThemeData(color: AppTheme.appBarIconColor),
        title: Text(
          context.l10n.profile,
          style: TextStyle(
            color: AppTheme.appBarIconColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      drawer: mainDrawerIfRootRoute(context),
      body: ProfileView(),
    );
  }
}
