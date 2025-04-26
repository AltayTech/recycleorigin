import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigin/features/store_feature/presentation/screens/orders_screen.dart';
import 'package:recycleorigin/features/waste_feature/collect_list_screen.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/main_item_button.dart';
import '../../../../core/widgets/top_bar.dart';
import '../../../meassage_feature/presentation/pages/messages_screen.dart';
import '../providers/authentication_provider.dart';
import '../providers/customer_info_provider.dart';
import '../screens/customer_user_info_screen.dart';
import '../screens/login_screen.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  var _isLoading = false;
  bool _isInit = true;

  Future<void> cashOrder() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<CustomerInfoProvider>(context, listen: false)
        .getCustomer();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      cashOrder();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    bool isLogin =
        Provider.of<AuthenticationProvider>(context, listen: false).isAuth;

    double deviceSizeWidth = MediaQuery.of(context).size.width;
    double deviceSizeHeight = MediaQuery.of(context).size.height;
    double textScaleFactor = MediaQuery.of(context).textScaleFactor;
    double itemPaddingF = 0.03;
    return !isLogin
        ? Container(
            child: Center(
              child: Wrap(
                direction: Axis.vertical,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text( "You are not login!"),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(LoginScreen.routeName);
                    },
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          'Login',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(5)),
                    ),
                  )
                ],
              ),
            ),
          )
        : Container(
            width: deviceSizeWidth,
            height: deviceSizeHeight,
            child: Align(
              alignment: Alignment.center,
              child: _isLoading
                  ? SpinKitFadingCircle(
                      itemBuilder: (BuildContext context, int index) {
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index.isEven ? Colors.grey : Colors.grey,
                          ),
                        );
                      },
                    )
                  : Container(
                      width: deviceSizeWidth,
                      height: deviceSizeHeight,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                              top: deviceSizeHeight * 0,
                              width: deviceSizeWidth,
                              child: TopBar()),
                          Positioned(
                            top: deviceSizeHeight * 0.070,
                            right: 20,
                            left: 20,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Spacer(),
                                Text(
                                  'Profile',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: AppTheme.bg,
                                      fontFamily: 'Iransans',
                                      fontSize: textScaleFactor * 24.0,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                              top: deviceSizeHeight * 0.250,
                              right: 0,
                              left: 0,
                              child: Container(
                                height: deviceSizeHeight * 0.7,
                                width: deviceSizeWidth * 0.9,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: GridView(
                                    children: <Widget>[
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).pushNamed(
                                              OrdersScreen.routeName);
                                        },
                                        child: MainItemButton(
                                          title: 'Order',
                                          itemPaddingF: itemPaddingF,
                                          imageUrl:
                                              'assets/images/orders_list.png',
                                          isMonoColor: false,
                                          imageSizeFactor: 0.25,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).pushNamed(
                                              CustomerUserInfoScreen.routeName);
                                        },
                                        child: MainItemButton(
                                          title: 'Personal Info',
                                          itemPaddingF: itemPaddingF,
                                          imageUrl:
                                              'assets/images/user_Icon.png',
                                          isMonoColor: false,
                                          imageSizeFactor: 0.30,
                                        ),

//
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).pushNamed(
                                              MessageScreen.routeName);
                                        },
                                        child: MainItemButton(
                                          title: 'Messages',
                                          itemPaddingF: itemPaddingF,
                                          imageUrl:
                                              'assets/images/message_icon.png',
                                          isMonoColor: false,
                                          imageSizeFactor: 0.25,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).pushNamed(
                                              CollectListScreen.routeName);
                                        },
                                        child: MainItemButton(
                                          title: 'Requests',
                                          itemPaddingF: itemPaddingF,
                                          imageUrl:
                                              'assets/images/main_page_request_ic.png',
                                          isMonoColor: false,
                                          imageSizeFactor: 0.35,
                                        ),
                                      ),
                                    ],
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 1,
                                      crossAxisSpacing: 2,
                                      mainAxisSpacing: 2,
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
            ),
          );
  }
}
