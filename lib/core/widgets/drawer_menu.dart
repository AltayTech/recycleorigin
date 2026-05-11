import 'package:flutter/material.dart';
import 'package:recycleorigin/l10n/l10n.dart';
// import 'package:meditest/features/athentication_feature/presentation/pages/auth_page.dart';

// import '../../features/athentication_feature/presentation/providers/authentication_provider.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      shadowColor: Colors.black12,
      backgroundColor: Colors.white60,
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Text(context.l10n.recycleorigin),
          ),
          ListTile(
            title: Text(context.l10n.drawerLoginTitle),
            onTap: () {
              // Navigator.of(context).pushNamed(AuthPage.routeName);
            },
          ),
          ListTile(
            title: Text(context.l10n.drawerGuideTitle),
            onTap: () {
              // Navigator.of(context).popAndPushNamed(HelpScreen.routeName);
            },
          ),
          ListTile(
            title: Text(context.l10n.drawerLogoutTitle),
            onTap: () async {
              // await context.read<AuthBloc>()
              //     .eitherFailureOrLogout();
              // debugPrint(
              //     context.read<AuthBloc>()
              //         .loginSituation
              //         ?.situation);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
