import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigin/core/logic/en_to_ar_number_convertor.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/drawer_or_back_leading.dart';
import '../../../customer_feature/presentation/bloc/customer_info_bloc.dart';
import '../../../store_feature/business/entities/shop.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactWithUs extends StatefulWidget {
  static const routeName = '/ContactWithUs';

  @override
  _ContactWithUsState createState() => _ContactWithUsState();
}

class _ContactWithUsState extends State<ContactWithUs> {
  bool _isLoading = false;

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  bool _isInit = true;

  late Shop shopData;

  List<String> aboutInfotitle = [];

  List<String> aboutInfoContent = [];

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      await searchItems();

      aboutInfoContent = [
        shopData.about,
        shopData.return_policy,
        shopData.privacy,
        shopData.how_to_order,
        shopData.faq,
        shopData.pay_methods_desc
      ];
      aboutInfotitle = [
        'About Store',
        'Return policy',
        'Privacy',
        'How to Order',
        'FQ',
        'How to do payment',
      ];
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  Future<void> searchItems() async {
    setState(() {
      _isLoading = true;
    });
    await context.read<CustomerInfoBloc>()
        .fetchShopData();
    shopData = context.read<CustomerInfoBloc>().shop;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    shopData = context.watch<CustomerInfoBloc>().shop;

    return Scaffold(
      backgroundColor: context.appColors.cardBackground,
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        title: Text(
          'Connect us',
          style: TextStyle(
            color: context.appColors.scaffoldBackground,
            //fontFamily: 'Iransans',
            fontSize: textScaleFactor * 18.0,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: new IconThemeData(color: AppTheme.appBarIconColor),
      ),
      body: _isLoading
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
          : Directionality(
              textDirection: Directionality.of(context),
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
                          color: context.appColors.scaffoldBackground,
                          child: FadeInImage(
                            placeholder: AssetImage('assets/images/circle.gif'),
                            image: NetworkImage(shopData.logo.sizes.medium),
                            fit: BoxFit.contain,
                            height: deviceWidth * 0.5,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Text(
                            shopData.name,
                            style: TextStyle(
                              color: context.colors.onSurface,
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
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
                                          //fontFamily: 'Iransans',
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.call,
                                        color: Colors.indigoAccent,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 8,
                                      child: Text(
                                        EnArConvertor().replaceArNumber(
                                          shopData.support_phone,
                                        ),
                                        style: TextStyle(
                                          color: Colors.black,
                                          //fontFamily: 'Iransans',
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.smartphone,
                                        color: Colors.indigoAccent,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 8,
                                      child: Text(
                                        EnArConvertor()
                                            .replaceArNumber(shopData.mobile),
                                        style: TextStyle(
                                          color: Colors.black,
                                          //fontFamily: 'Iransans',
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 8,
                                        child: InkWell(
                                          onTap: () {
                                            _launchURL(shopData
                                                .social_media.instagram);
                                          },
                                          child: Image.asset(
                                              'assets/images/instagram.png'),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 8,
                                        child: InkWell(
                                            onTap: () {
                                              _launchURL(shopData
                                                  .social_media.telegram);
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
      drawer: mainDrawerIfRootRoute(context),
    );
  }
}
