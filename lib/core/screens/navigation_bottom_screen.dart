import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../features/customer_feature/presentation/widgets/profile_view.dart';
import '../../features/home_feature/presentation/home_screen.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/main_drawer.dart';

/// This file defines the `NavigationBottomScreen` widget, which serves as the main navigation container for the app.
///
/// The widget includes the following key components:
///
/// - **AppBar**: Displays the app title with a customizable theme.
/// - **Drawer**: A side navigation menu implemented using the `MainDrawer` widget.
/// - **Bottom Navigation**: Allows navigation between different sections of the app using a bottom navigation bar.
/// - **PageView**: Dynamically displays pages based on the selected bottom navigation item.
///
/// Key Features:
/// - Manages navigation between multiple pages using `_pages` list.
/// - Handles back button presses with a custom `WillPopScope` implementation.
/// - Displays a toast message when the back button is pressed twice within a short interval.
/// - Supports RTL layout for localization.
///
/// Dependencies:
/// - `AppTheme`: Provides theme colors and styles.
/// - `MainDrawer`: A custom widget for the side navigation drawer.
/// - `HomeScreen`: Displays the home page content.
/// - `ProfileView`: Displays the user's profile page.
/// - `Strings`: Supplies localized strings for navigation labels.
///
/// Navigation:
/// - Navigates between `HomeScreen`, `ProfileView`, and other pages defined in the `_pages` list.
///
/// Note:
/// - Ensure that the `AppTheme` and `Strings` are properly configured to match the app's design and localization requirements.
/// - Handle cases where the user attempts to exit the app gracefully with a confirmation dialog.
class NavigationBottomScreen extends StatefulWidget {
  static const routeName = '/NBS';

  @override
  _NavigationBottomScreenState createState() => _NavigationBottomScreenState();
}

class _NavigationBottomScreenState extends State<NavigationBottomScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedPageIndex = 0;
  late DateTime currentBackPressTime;

  @override
  void initState() {
    super.initState();
    // Ensure `onWillPop` can safely run before the first back press.
    currentBackPressTime = DateTime.now().subtract(const Duration(seconds: 3));
  }

  @override
  void dispose() {
    super.dispose();
  }

  final List<Widget> _pages = <Widget>[
    HomeScreen(),
    HomeScreen(),
    HomeScreen(),
    ProfileView(),
  ];

  Future<bool> onWillPop() async {
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.pop(context);
      return false;
    } else {
      final l10n = AppLocalizations.of(context)!;
      DateTime now = DateTime.now();
      if (now.difference(currentBackPressTime) > Duration(seconds: 2)) {
        currentBackPressTime = now;
        FToast().showToast(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                l10n.forexit,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppTheme.black,
                    //fontFamily: 'Iransans',
                    fontSize: MediaQuery.of(context).textScaleFactor * 13.0),
              ),
            ),
          ),
        );
        return Future.value(false);
      }
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
//            bottom: PreferredSize(
//              child: Container(),
//              preferredSize: Size.fromHeight(15),
//            ),
          title: Text(
            l10n.recycleorigin,
            style: const TextStyle(
              // //fontFamily: 'Iransans',
              color: Colors.white,
            ),
          ),
//            shape: RoundedRectangleBorder(
//              borderRadius: new BorderRadius.vertical(
//                  bottom: new Radius.elliptical(
//                      MediaQuery.of(context).size.width * 9, 200.0)),
//            ),
          backgroundColor: AppTheme.appBarColor,
          iconTheme: IconThemeData(color: AppTheme.appBarIconColor),
          centerTitle: true,
        ),
        drawer: Theme(
          data: Theme.of(context).copyWith(
            // Set the transparency here
            canvasColor: Colors.transparent,
          ),
          child: const MainDrawer(),
        ),
        body: _pages[_selectedPageIndex],

//          bottomNavigationBar: BottomNavigationBar(
//            elevation: 8,
//            selectedLabelStyle: TextStyle(
//                color: AppTheme.secondary,
//                //fontFamily: 'Iransans',
//                fontSize: MediaQuery.of(context).textScaleFactor * 10.0),
//            onTap: _selectBNBItem,
//            backgroundColor: AppTheme.bg,
//            unselectedItemColor: Colors.grey,
//            selectedItemColor: AppTheme.primary,
//            currentIndex: _selectedPageIndex,
//            items: [
//              BottomNavigationBarItem(
//                backgroundColor: AppTheme.white,
//                icon: Icon(Icons.home),
//                title: Text(
//                  Strings.navHome,
//                ),
//              ),
//              BottomNavigationBarItem(
//                backgroundColor: AppTheme.white,
//                icon: Icon(Icons.directions_car),
//                title: Text(
//                  Strings.navRequest,
//                ),
//              ),
//              BottomNavigationBarItem(
//                backgroundColor: AppTheme.white,
//                icon: Icon(Icons.add_shopping_cart),
//                title: Text(
//                  Strings.navShop,
//                ),
//              ),
//              BottomNavigationBarItem(
//                backgroundColor: AppTheme.white,
//                icon: Icon(Icons.account_circle),
//                title: Text(
//                  Strings.navProfile,
//                ),
//              ),
//            ],
//          ),
      ),
    );
  }
}
