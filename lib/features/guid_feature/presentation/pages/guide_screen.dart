import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:provider/provider.dart';

import '../../../store_feature/business/entities/shop.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customer_feature/presentation/bloc/customer_info_bloc.dart';
import '../../../../core/widgets/main_drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/l10n/l10n.dart';

class GuideScreen extends StatefulWidget {
  static const routeName = '/guideScreen';

  @override
  _GuideScreenState createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  bool _isInit = true;

  late Shop shopData;

  List<String> aboutInfoContent = [];

  bool _isLoading = false;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      await searchItems();

      aboutInfoContent = [
        shopData.return_policy,
        shopData.privacy,
        shopData.how_to_order,
        shopData.faq,
        shopData.pay_methods_desc
      ];
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  List<String> _guideSectionTitles(BuildContext context) {
    final l10n = context.l10n;
    return <String>[
      l10n.sectionReturnPolicyTitle,
      l10n.sectionPrivacyTitle,
      l10n.sectionHowToOrderTitle,
      l10n.sectionFaqTitle,
      l10n.sectionPaymentMethodsTitle,
    ];
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
    final sectionTitles = _guideSectionTitles(context);

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: Text(
          context.l10n.guideTitle,
          style: TextStyle(
            color: AppTheme.bg,
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
                            color: AppTheme.bg,
                            child: FadeInImage(
                              placeholder:
                                  AssetImage('assets/images/circle.gif'),
                              image: NetworkImage(shopData.logo.sizes.medium),
                              fit: BoxFit.contain,
                              height: deviceWidth * 0.5,
                            )),
                        Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Text(
                            shopData.name,
                            style: TextStyle(
                              color: AppTheme.h1,
                              fontFamily: 'BFarnaz',
                              fontSize: textScaleFactor * 24.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Text(
                            shopData.subject,
                            style: TextStyle(
                              color: AppTheme.grey,
                              //fontFamily: 'Iransans',
                              fontSize: textScaleFactor * 15.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          height: deviceHeight * 0.7,
                          width: deviceWidth,
                          child: ListView.builder(
                            shrinkWrap: true,
                            primary: false,
                            itemCount: sectionTitles.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Card(
                                  child: ExpansionTile(
                                    title: Text(
                                      sectionTitles[index],
                                      style: TextStyle(
                                        color: AppTheme.black,
                                        //fontFamily: 'Iransans',
                                        fontSize: textScaleFactor * 15.0,
                                      ),
                                    ),
                                    children: <Widget>[
                                      HtmlWidget(
                                        aboutInfoContent[index],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
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
