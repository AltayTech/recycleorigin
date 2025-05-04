import 'package:flutter/material.dart';

// import '../../features/home_screen/presentation/pages/home_screen.dart';
import 'app_background.dart';
import 'bottom_nav.dart';
import 'drawer_menu.dart';

/// This file defines the `MainWrapper` widget, which serves as the main container for the app's navigation and layout.
///
/// The widget includes the following key components:
///
/// - **AppBar**: A standard app bar for the application.
/// - **Drawer**: A side navigation menu implemented using the `DrawerMenu` widget.
/// - **Bottom Navigation Bar**: A custom bottom navigation bar implemented using the `BottomNav` widget.
/// - **PageView**: A scrollable container for managing multiple pages, controlled by a `PageController`.
/// - **Background**: A dynamic background image provided by the `AppBackground` class.
///
/// Key Features:
/// - Uses a `PageController` to manage navigation between pages.
/// - Dynamically sets the background image based on the time of day.
/// - Provides a safe area to ensure content is displayed within the visible screen area.
///
/// Dependencies:
/// - `AppBackground`: Supplies the background image based on the time of day.
/// - `BottomNav`: A custom widget for the bottom navigation bar.
/// - `DrawerMenu`: A custom widget for the side navigation drawer.
///
/// Navigation:
/// - The `PageView` widget is designed to host multiple pages, which can be added to the `pageViewWidget` list.
///
/// Note:
/// - Ensure that the `AppBackground`, `BottomNav`, and `DrawerMenu` widgets are properly implemented.
/// - Add the desired pages to the `pageViewWidget` list to enable navigation between them.
class MainWrapper extends StatelessWidget {
  MainWrapper({Key? key}) : super(key: key);
  static const routeName = '/MainWrapper';

  final PageController pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    List<Widget> pageViewWidget = [
      // const HomeScreen(),
      // const HomeScreen(),
      // const HomeScreen(),
    ];
    // var height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        bottomNavigationBar: BottomNav(pageController: pageController),
        appBar: AppBar(),
        drawer: DrawerMenu(),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AppBackground.getBackGroundImage(),
              fit: BoxFit.cover,
            ),
          ),

          // height: height,
          child: PageView(
            controller: pageController,
            children: pageViewWidget,
          ),
        ),
      ),
    );
  }
}
