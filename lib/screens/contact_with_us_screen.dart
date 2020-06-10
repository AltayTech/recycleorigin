import 'package:flutter/material.dart';
import '../customer_info.dart';
import '../models/shop.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../provider/app_theme.dart';
import '../widgets/main_drawer.dart';

class ContactWithUs extends StatefulWidget {
  static const routeName = '/ContactWithUs';

  @override
  _ContactWithUsState createState() => _ContactWithUsState();
}

class _ContactWithUsState extends State<ContactWithUs> {
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  bool _isInit = true;

  Shop shopData;

  List<String> aboutInfotitle = [];

  List<String> aboutInfoContent = [];

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      await Provider.of<CustomerInfo>(context, listen: false).fetchShopData();

      aboutInfoContent = [
        shopData.about_shop,
        shopData.return_policy,
        shopData.privacy,
        shopData.how_to_order,
        shopData.faq,
        shopData.pay_methods_desc
      ];
      aboutInfotitle = [
        'درباره فروشگاه',
        'قوانین بازگردانی',
        'حریم خصوصی',
        'نحوه سفارش',
        'سوالات متداول',
        'شیوه پرداخت',
      ];
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    shopData = Provider.of<CustomerInfo>(context).shop;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تماس با ما',
          style: TextStyle(
            color: AppTheme.bg,
            fontFamily: 'Iransans',
            fontSize: textScaleFactor * 18.0,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: new IconThemeData(color: AppTheme.appBarIconColor),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: deviceWidth * 0.3,
                    height: deviceWidth * 0.3,
                    color: AppTheme.bg,
                    child: FadeInImage(
                      placeholder: AssetImage('assets/images/circle.gif'),
                      image: NetworkImage(shopData.logo),
                      fit: BoxFit.contain,
                      height: deviceWidth * 0.5,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Text(
                      shopData.shop_name,
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontFamily: 'BFarnaz',
                        fontSize: textScaleFactor * 24.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Divider(),
                  Column(
                    children: <Widget>[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.indigoAccent,
                                ),
                              ),
                              Expanded(
                                flex: 8,
                                child: Text(
                                  shopData.address,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Iransans',
                                    fontSize: textScaleFactor * 18,
                                  ),
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: Icon(
                                  Icons.call,
                                  color: Colors.indigoAccent,
                                ),
                              ),
                              Expanded(
                                flex: 8,
                                child: Text(
                                  shopData.support_phone,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Iransans',
                                    fontSize: textScaleFactor * 18,
                                  ),
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: Icon(
                                  Icons.smartphone,
                                  color: Colors.indigoAccent,
                                ),
                              ),
                              Expanded(
                                flex: 8,
                                child: Text(
                                  shopData.shop_cellphone,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Iransans',
                                    fontSize: textScaleFactor * 18,
                                  ),
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: deviceHeight * 0.10,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  flex: 8,
                                  child: InkWell(
                                    onTap: () {
                                      _launchURL(
                                          shopData.social_media.instagram);
                                    },
                                    child: Image.asset(
                                        'assets/images/instagram.png'),
                                  ),
                                ),
                                Expanded(
                                  flex: 8,
                                  child: InkWell(
                                      onTap: () {
                                        _launchURL(
                                            shopData.social_media.telegram);
                                      },
                                      child: Image.asset(
                                          'assets/images/telegram.png')),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      endDrawer: Theme(
        data: Theme.of(context).copyWith(
          // Set the transparency here
          canvasColor: Colors
              .transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
        ),
        child: MainDrawer(),
      ),
    );
  }
}
