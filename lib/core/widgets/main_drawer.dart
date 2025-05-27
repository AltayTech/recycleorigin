import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/features/Charities/presentation/pages/charity_screen.dart';
import 'package:recycleorigin/features/customer_feature/presentation/providers/customer_info_provider.dart';
import 'package:recycleorigin/features/meassage_feature/presentation/pages/messages_screen.dart';

import '../../features/customer_feature/presentation/providers/authentication_provider.dart';
import '../../features/customer_feature/presentation/screens/login_screen.dart';
import '../../features/customer_feature/presentation/screens/profile_screen.dart';
import '../../features/store_feature/presentation/screens/cart_screen.dart';
import '../../features/store_feature/presentation/screens/product_screen.dart';
import '../screens/navigation_bottom_screen.dart';

/// This widget is a drawer that contains main menu options
/// it is used in [NavigationBottomScreen] as a drawer
/// it contains a list of [ListTile] which are built by [buildListTile]
/// it also contains a [Divider] to separate the list from the logout button
/// the logout button is used to log out the user
/// it calls [AuthenticationProvider.logout] when clicked
///
/// It is used in [NavigationBottomScreen] as a drawer
///
/// The drawer contains the following items:
/// - Home
/// - Store
/// - Cards
/// - Charities
/// - Cources
/// - Supports
/// - Guids
/// - Contact Us
/// - About Us
/// - Logout
///
/// It also contains a [Image] at the top of the drawer which is the header image of the app
///
/// The [buildListTile] method is used to build each item in the list
/// it takes a [String] title and an [IconData] icon as arguments
/// it returns a [ListTile] with the given title and icon
///
/// The [Divider] is used to separate the list from the logout button
///
/// The logout button is a [ListTile] with a title of "Logout"
/// it calls [AuthenticationProvider.logout] when clicked
/// it also pops the drawer when clicked

class MainDrawer extends StatelessWidget {
  Widget buildListTile(String title, IconData icon, Function()? tapHandler) {
    return ListTile(
      leading: Icon(
        icon,
        size: 26,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: tapHandler,
    );
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    Color textColor = Colors.white;
    Color iconColor = Colors.white;
    return Drawer(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          child: Stack(
            children: <Widget>[
              Container(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 5,
                    sigmaY: 5,
                  ),
                  child:
                      Container(color: AppTheme.appBarColor.withOpacity(0.9)),
                ),
              ),
              Wrap(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        height: deviceHeight * 0.25,
                        width: double.infinity,
                        child: Image.asset(
                          'assets/images/main_page_header.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Consumer<AuthenticationProvider>(
                    builder: (_, auth, ch) => ListTile(
                      title: Text(
                        auth.isAuth ? "Profile" : "Login",
                        style: TextStyle(
                          fontFamily: "Iransans",
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: textColor,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      trailing: Icon(
                        Icons.account_circle,
                        color: iconColor,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        auth.isAuth
                            ? Navigator.of(context)
                                .pushNamed(ProfileScreen.routeName)
                            : Navigator.of(context)
                                .pushNamed(LoginScreen.routeName);
                      },
                    ),
                  ),
                  Divider(
                    thickness: 2,
                  ),
                  Container(
                    height: deviceHeight * 0.63,
                    child: SingleChildScrollView(
                      child: Wrap(
                        children: <Widget>[
                          ListTile(
                            title: Text(
                              "Home",
                              style: TextStyle(
                                fontFamily: "Iransans",
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: textColor,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            trailing: Icon(
                              Icons.home,
                              color: iconColor,
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  NavigationBottomScreen.routeName,
                                  (Route<dynamic> route) => false);
                            },
                          ),
                          ListTile(
                            title: Text(
                              "Store",
                              style: TextStyle(
                                fontFamily: "Iransans",
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: textColor,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            trailing: Icon(
                              Icons.phonelink,
                              color: iconColor,
                            ),
                            onTap: () {
                              Navigator.of(context).pop();

                              Navigator.of(context).pushNamed(
                                  ProductsScreen.routeName,
                                  arguments: 0);
                            },
                          ),
                          ListTile(
                            title: Text(
                              "Card",
                              style: TextStyle(
                                fontFamily: "Iransans",
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: textColor,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            trailing: Icon(
                              Icons.shopping_cart,
                              color: iconColor,
                            ),
                            onTap: () {
                              Navigator.of(context).pop();

                              Navigator.of(context)
                                  .pushNamed(CartScreen.routeName);
                            },
                          ),
                          // ListTile(
                          //   title: Text(
                          //     "Charities",
                          //     style: TextStyle(
                          //       fontFamily: "Iransans",
                          //       fontWeight: FontWeight.w500,
                          //       fontSize: 16,
                          //       color: textColor,
                          //     ),
                          //     textAlign: TextAlign.right,
                          //   ),
                          //   trailing: Container(
                          //       height: deviceHeight * 0.025,
                          //       width: deviceHeight * 0.025,
                          //       child: Image.asset(
                          //         'assets/images/donation_ic.png',
                          //         color: iconColor,
                          //       )),
                          //   onTap: () {
                          //     Navigator.of(context).pop();
                          //
                          //     Navigator.of(context)
                          //         .pushNamed(CharityScreen.routeName);
                          //   },
                          // ),
                          // ListTile(
                          //   title: Text(
                          //     "Cources",
                          //     style: TextStyle(
                          //       fontFamily: "Iransans",
                          //       fontWeight: FontWeight.w500,
                          //       fontSize: 16,
                          //       color: textColor,
                          //     ),
                          //     textAlign: TextAlign.right,
                          //   ),
                          //   trailing: Icon(
                          //     Icons.description,
                          //     color: iconColor,
                          //   ),
                          //   onTap: () {
                          //     Navigator.of(context).pop();
                          //
                          //     Navigator.of(context)
                          //         .pushNamed(MessageScreen.routeName);
                          //   },
                          // ),
                          ListTile(
                            title: Text(
                              "Supports",
                              style: TextStyle(
                                fontFamily: "Iransans",
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: textColor,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            trailing: Icon(
                              Icons.description,
                              color: iconColor,
                            ),
                            onTap: () {
                              Navigator.of(context).pop();

                              Navigator.of(context)
                                  .pushNamed(MessageScreen.routeName);
                            },
                          ),
                          // ListTile(
                          //   title: Text(
                          //     "Guids",
                          //     style: TextStyle(
                          //       fontFamily: "Iransans",
                          //       fontWeight: FontWeight.w500,
                          //       fontSize: 16,
                          //       color: textColor,
                          //     ),
                          //     textAlign: TextAlign.right,
                          //   ),
                          //   trailing: Icon(
                          //     Icons.help,
                          //     color: iconColor,
                          //   ),
                          //   onTap: () {
                          //     Navigator.of(context).pop();
                          //
                          //     Navigator.of(context)
                          //         .pushNamed(GuideScreen.routeName);
                          //   },
                          // ),
                          // ListTile(
                          //   title: Text(
                          //     "Contact Us",
                          //     style: TextStyle(
                          //       fontFamily: "Iransans",
                          //       fontWeight: FontWeight.w500,
                          //       fontSize: 16,
                          //       color: textColor,
                          //     ),
                          //     textAlign: TextAlign.right,
                          //   ),
                          //   trailing: Icon(
                          //     Icons.contact_phone,
                          //     color: iconColor,
                          //   ),
                          //   onTap: () {
                          //     Navigator.of(context).pop();
                          //
                          //     Navigator.of(context)
                          //         .pushNamed(ContactWithUs.routeName);
                          //   },
                          // ),
                          // ListTile(
                          //   title: Text(
                          //     "About Us",
                          //     style: TextStyle(
                          //       fontFamily: "Iransans",
                          //       fontWeight: FontWeight.w500,
                          //       fontSize: 16,
                          //       color: textColor,
                          //     ),
                          //     textAlign: TextAlign.right,
                          //   ),
                          //   trailing: Icon(
                          //     Icons.account_balance,
                          //     color: iconColor,
                          //   ),
                          //   onTap: () {
                          //     Navigator.of(context).pop();
                          //
                          //     Navigator.of(context)
                          //         .pushNamed(AboutUsScreen.routeName);
                          //   },
                          // ),
                          ListTile(
                            title: Text(
                              "Logout",
                              style: TextStyle(
                                fontFamily: "Iransans",
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: textColor,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            trailing: Icon(
                              FontAwesomeIcons.signOutAlt,
                              color: iconColor,
                            ),
                            onTap: () async {
                              Provider.of<CustomerInfoProvider>(context,
                                      listen: false)
                                  .customer = Provider.of<CustomerInfoProvider>(
                                      context,
                                      listen: false)
                                  .customer_zero;
                              await Provider.of<AuthenticationProvider>(context,
                                      listen: false)
                                  .removeToken();
                              Provider.of<AuthenticationProvider>(context,
                                      listen: false)
                                  .isFirstLogout = true;
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  NavigationBottomScreen.routeName,
                                  (Route<dynamic> route) => false);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
