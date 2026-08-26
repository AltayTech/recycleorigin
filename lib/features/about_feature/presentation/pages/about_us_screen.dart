import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../store_feature/business/entities/shop.dart';
import '../../../customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/drawer_or_back_leading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AboutUsScreen extends StatefulWidget {
  static const routeName = '/AboutUsScreen';

  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  bool _isInit = true;

  late Shop shopData;

  bool _isLoading = false;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      await searchItems();
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  Future<void> searchItems() async {
    setState(() {
      _isLoading = true;
    });
    await context.read<CustomerInfoBloc>().fetchShopData();
    shopData = context.read<CustomerInfoBloc>().shop;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.textScalerOf(context).scale(1);

    return Scaffold(
      backgroundColor: context.appColors.cardBackground,
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        title: Text(
          'About us',
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
                    color: context.appColors.subtitleColor,
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
                        Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Text(
                            shopData.subject,
                            style: TextStyle(
                              color: context.appColors.subtitleColor,
                              //fontFamily: 'Iransans',
                              fontSize: textScaleFactor * 15.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              shopData.about,
                              style: TextStyle(
                                color: context.colors.onSurface,
                                //fontFamily: 'Iransans',
                                fontSize: textScaleFactor * 15.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Container(
                          height: deviceHeight * 0.7,
                          width: deviceWidth,
                          child: ListView.builder(
                            shrinkWrap: true,
                            primary: false,
                            itemCount: shopData.features_list.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.arrow_right,
                                      color: context.appColors.divider,
                                    ),
                                    Text(
                                      shopData.features_list[index].feature,
                                      style: TextStyle(
                                        color: context.colors.onSurface,
                                        //fontFamily: 'Iransans',
                                        fontStyle: FontStyle.italic,
                                        fontSize: textScaleFactor * 15.0,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
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
      drawer: mainDrawerIfRootRoute(context),
    );
  }
}
