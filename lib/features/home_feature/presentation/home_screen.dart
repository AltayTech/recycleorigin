import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigin/features/wallet_feature/presentation/pages/wallet_screen.dart';
import 'package:recycleorigin/core/widgets/buton_bottom.dart';
import 'package:recycleorigin/core/widgets/main_item_button.dart';

import '../../store_feature/presentation/providers/Products.dart';
import '../../../core/theme/app_theme.dart';
import '../../customer_feature/presentation/providers/authentication_provider.dart';
import '../../articles_feature/presentation/pages/article_screen.dart';
import '../../waste_feature/collect_list_screen.dart';
import '../../collect_feature/presentation/pages/waste_cart_screen.dart';
import '../../../core/widgets/custom_dialog.dart';
import '../../store_feature/presentation/screens/product_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInit = true;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      _isInit = false;
      Provider.of<Products>(context, listen: false).retrieveCategory();

      Provider.of<AuthenticationProvider>(context, listen: false)
          .getTokenFromDB();

      bool _isFirstLogin =
          Provider.of<AuthenticationProvider>(context, listen: false)
              .isFirstLogin;
      if (_isFirstLogin) {
        _showLoginDialog(context);
      }
      bool _isFirstLogout =
          Provider.of<AuthenticationProvider>(context, listen: false)
              .isFirstLogout;
      if (_isFirstLogout) {
        _showLoginDialogExit(context);
        Provider.of<AuthenticationProvider>(context, listen: false)
            .isFirstLogout = false;
      }

      Provider.of<AuthenticationProvider>(context, listen: false).isFirstLogin =
          false;
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  void _showLoginDialog(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog<String>(
        context: context,
        builder: (ctx) => CustomDialog(
          title: "Welcome",
          buttonText: "accept",
          description: "In order to get profile information go to profile section",
          image: Image.asset('assets/images/main_page_request_ic.png'),
        ),
      );
    });
  }

  void _showLoginDialogExit(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog<String>(
        context: context,
        builder: (ctx) => CustomDialog(
          title: "Dear User",
          buttonText: "accept",
          description: "You Logout successfully",
          image: Image.asset('assets/images/main_page_request_ic.png'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    double itemPaddingF = 0.025;

    return SingleChildScrollView(
      child: Container(
        color: AppTheme.bg,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                    color: AppTheme.bg,
                    border: Border.all(width: 5, color: AppTheme.bg)),
                height: deviceWidth * 0.4,
                child: Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: deviceWidth,
                      child: FadeInImage(
                        placeholder: AssetImage('assets/images/circle.gif'),
                        image: AssetImage('assets/images/main_page_header.png'),
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(
                  WasteCartScreen.routeName,
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 8.0, bottom: 2, left: 20, right: 20),
                child: ButtonBottom(
                  width: deviceWidth * 0.9,
                  height: deviceWidth * 0.14,
                  text: "Request collect",
                  isActive: true,
                ),
              ),
            ),
            Container(
              height: deviceHeight * 0.6,
              width: deviceWidth,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView(
                  primary: false,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(CollectListScreen.routeName);
                      },
                      child: MainItemButton(
                        title: "Request",
                        itemPaddingF: itemPaddingF,
                        imageUrl: 'assets/images/main_page_request_ic.png',
                        isMonoColor: false,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed(WalletScreen.routeName);
                      },
                      child: MainItemButton(
                          title: "Wallet",
                          itemPaddingF: itemPaddingF,
                          imageUrl: 'assets/images/main_page_wallet_ic.png'),
                    ),
                    InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(ArticlesScreen.routeName);
                        },
                        child: MainItemButton(
                            title: "Articles",
                            itemPaddingF: itemPaddingF,
                            imageSizeFactor: 0.33,
                            isMonoColor: true,
                            imageUrl: 'assets/images/main_page_paper_ic.png')),
                    InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(ProductsScreen.routeName);
                      },
                      child: MainItemButton(
                          title: "Store",
                          itemPaddingF: itemPaddingF,
                          imageUrl: 'assets/images/main_page_shop_ic.png'),
                    ),
                  ],
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
