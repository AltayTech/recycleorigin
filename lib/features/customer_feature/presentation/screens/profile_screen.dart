import 'package:flutter/material.dart';

import '../../../../core/widgets/drawer_or_back_leading.dart';
import '../../../../l10n/l10n.dart';
import '../widgets/profile_view.dart';

/// Full-screen profile route with app bar and drawer on root navigation.
class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        title: Text(context.l10n.profile),
      ),
      drawer: mainDrawerIfRootRoute(context),
      body: const ProfileView(),
    );
  }
}
