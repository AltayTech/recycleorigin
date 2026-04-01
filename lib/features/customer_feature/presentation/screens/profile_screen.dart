import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/main_drawer.dart';
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
      endDrawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
        ),
        child: MainDrawer(),
      ),
      body: ProfileView(),
    );
  }
}
