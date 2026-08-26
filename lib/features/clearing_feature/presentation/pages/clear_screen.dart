import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:recycleorigin/core/models/customer.dart';
import 'package:recycleorigin/core/widgets/buton_bottom.dart';
import 'package:recycleorigin/core/widgets/currency_input_formatter.dart';
import 'package:recycleorigin/core/widgets/custom_dialog_send_request.dart';
import 'package:recycleorigin/features/clearing_feature/business/entities/clearing.dart';
import 'package:recycleorigin/features/clearing_feature/presentation/bloc/clearings_bloc.dart';
import 'package:recycleorigin/features/clearing_feature/presentation/widgets/clearing_item_clear_screen.dart';
import 'package:recycleorigin/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigin/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigin/features/customer_feature/presentation/bloc/customer_info_state.dart';

import '../../../../core/logic/en_to_ar_number_convertor.dart';
import '../../../../core/models/search_detail.dart';
import '../../../../core/screens/navigation_bottom_screen.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/drawer_or_back_leading.dart';
import '../../../auth_feature/presentation/screens/login_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/l10n/l10n.dart';

class ClearScreen extends StatefulWidget {
  static const routeName = '/ClearScreen';

  @override
  _ClearScreenState createState() => _ClearScreenState();
}

class _ClearScreenState extends State<ClearScreen>
    with SingleTickerProviderStateMixin {
  bool _isInit = true;
  var _isLoading = false;
  int page = 1;
  SearchDetail productsDetail = SearchDetail();
  ScrollController _scrollController = new ScrollController();

  late Customer customer;

  final shabaController = TextEditingController();
  final donationController = TextEditingController();

  @override
  void initState() {
    context.read<CustomerInfoBloc>().sPage = 1;

    context.read<ClearingsBloc>().searchBuilder();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (page < productsDetail.max_page) {
          page = page + 1;
          context.read<ClearingsBloc>().sPage = page;

          searchItems();
        }
      }
    });

    shabaController.text = 'IR';
    donationController.text = '0';
    super.initState();
  }

  @override
  void dispose() {
    shabaController.dispose();
    donationController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      getCustomerInfo();
      customer = context.read<CustomerInfoBloc>().customer;
      searchItems();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> getCustomerInfo() async {
    bool isLogin = context.read<AuthBloc>().isAuth;
    if (isLogin) {
      await context.read<CustomerInfoBloc>().getCustomer();
    }
  }

  void _showSenddialog() {
    CustomDialogSendRequest.show(
      context,
      description: context.l10n.clearingRequestRegisteredSuccess,
      buttonText: context.l10n.okLabel,
    );
  }

  Future<void> sendClearingRequest(String money, String shaba) async {
    setState(() {
      _isLoading = true;
    });

    await context
        .read<CustomerInfoBloc>()
        .sendClearingRequest(money.toString(), shaba);
    setState(() {
      _isLoading = false;
    });
  }

  List<Clearing> loadedProducts = [];
  List<Clearing> loadedProductstolist = [];

  Future<void> searchItems() async {
    setState(() {
      _isLoading = true;
    });

    context.read<ClearingsBloc>().searchBuilder();
    await context.read<ClearingsBloc>().searchCleaingsItems();
    productsDetail = context.read<ClearingsBloc>().searchDetails;

    loadedProducts.clear();
    loadedProducts = context.read<ClearingsBloc>().deliveriesItems;
    loadedProductstolist.addAll(loadedProducts);

    setState(() {
      _isLoading = false;
    });
  }

  String removeSemicolon(String rawString) {
    print(rawString);

    String newvalue = rawString.replaceAll(',', '');

    return newvalue;
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    bool isLogin = context.watch<AuthBloc>().isAuth;

    var currencyFormat = intl.NumberFormat.decimalPattern();

    return Scaffold(
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        title: Text(
          context.l10n.clearingPayTitle,
          style: TextStyle(
            //fontFamily: 'Iransans',
            color: context.appColors.cardBackground,
          ),
        ),
        backgroundColor: AppTheme.appBarColor,
        iconTheme: new IconThemeData(color: AppTheme.appBarIconColor),
        elevation: 0,
        centerTitle: true,
        actions: <Widget>[],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Builder(
          builder: (context) {
            return SingleChildScrollView(
              child: !isLogin
                  ? Container(
                      height: deviceHeight * 0.8,
                      child: Center(
                        child: Wrap(
                          direction: Axis.vertical,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(context.l10n.youarenotlogin),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(LoginScreen.routeName);
                              },
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text(
                                    context.l10n.login,
                                    style: const TextStyle(
                                        color: AppTheme.appBarIconColor),
                                  ),
                                ),
                                decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  : Container(
                      color: context.appColors.scaffoldBackground,
                      height: deviceHeight * 0.9,
                      child: Stack(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: <Widget>[
                                //                                    Container(
                                //                                      decoration: BoxDecoration(
                                //                                          color: context.appColors.cardBackground,
                                //                                          border: Border.all(
                                //                                            width: 5,
                                //                                            color: context.appColors.cardBackground,
                                //                                          )),
                                //                                      height: deviceWidth * 0.5,
                                //                                      child: Padding(
                                //                                        padding: const EdgeInsets.all(15.0),
                                //                                        child: Stack(
                                //                                          children: <Widget>[
                                //                                            Container(
                                //                                              height: deviceWidth * 0.9,
                                //                                              width: deviceWidth,
                                //                                              color: context.appColors.cardBackground,
                                //                                              child: FadeInImage(
                                //                                                placeholder: AssetImage(
                                //                                                    'assets/images/circle.gif'),
                                //                                                image: AssetImage(
                                //                                                    'assets/images/wallet_money_bg.png'),
                                //                                                fit: BoxFit.contain,
                                //                                              ),
                                //                                            ),
                                //                                            Center(
                                //                                              child: Column(
                                //                                                mainAxisAlignment:
                                //                                                    MainAxisAlignment.center,
                                //                                                children: <Widget>[
                                //                                                  Text(
                                //                                                    'امتیاز',
                                //                                                    style: TextStyle(
                                //                                                      color: context.appColors.subtitleColor,
                                //                                                      //fontFamily: 'Iransans',
                                //                                                      fontSize:
                                //                                                          textScaleFactor *
                                //                                                              13.0,
                                //                                                    ),
                                //                                                    textAlign: TextAlign.center,
                                //                                                  ),
                                //                                                  Consumer<CustomerInfo>(
                                //                                                    builder: (_, data, ch) =>
                                //                                                        Text(
                                //                                                      data.customer != null
                                //                                                          ? EnArConvertor().replaceArNumber(
                                //                                                              currencyFormat
                                //                                                                  .format(double
                                //                                                                      .parse(data
                                //                                                                          .customer
                                //                                                                          .money))
                                //                                                                  .toString())
                                //                                                          : EnArConvertor()
                                //                                                              .replaceArNumber(
                                //                                                                  currencyFormat
                                //                                                                      .format(double
                                //                                                                          .parse(
                                //                                                                              '0'))),
                                //                                                      style: TextStyle(
                                //                                                        color: context.colors.onSurface,
                                //                                                        //fontFamily: 'Iransans',
                                //                                                        fontWeight:
                                //                                                            FontWeight.w700,
                                //                                                        fontSize:
                                //                                                            textScaleFactor *
                                //                                                                18.0,
                                //                                                      ),
                                //                                                      textAlign:
                                //                                                          TextAlign.center,
                                //                                                    ),
                                //                                                  ),
                                //                                                  Text(
                                //                                                    'تومان',
                                //                                                    style: TextStyle(
                                //                                                      color: context.appColors.subtitleColor,
                                //                                                      //fontFamily: 'Iransans',
                                //                                                      fontSize:
                                //                                                          textScaleFactor *
                                //                                                              13.0,
                                //                                                    ),
                                //                                                    textAlign: TextAlign.center,
                                //                                                  ),
                                //                                                ],
                                //                                              ),
                                //                                            ),
                                //                                          ],
                                //                                        ),
                                //                                      ),
                                //                                    ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 10, bottom: 8),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: context.appColors.cardBackground,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primary
                                                .withValues(alpha: 0.08),
                                            blurRadius: 10,
                                            spreadRadius: 5,
                                            offset: Offset(
                                              0,
                                              0,
                                            ),
                                          )
                                        ],
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 12,
                                          bottom: 4,
                                          left: 16,
                                          right: 16),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Center(
                                            child: Text(
                                              context.l10n.walletCreditUsdLabel,
                                              style: TextStyle(
                                                color: context
                                                    .appColors.subtitleColor,
                                                //fontFamily: 'Iransans',
                                                fontSize: 13.0,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Spacer(),
                                          BlocBuilder<CustomerInfoBloc,
                                              CustomerInfoState>(
                                            builder: (_, state) => Text(
                                              EnArConvertor().replaceArNumber(
                                                  currencyFormat
                                                      .format(double.parse(
                                                          state.customer.money))
                                                      .toString()),
                                              style: TextStyle(
                                                color: context.colors.onSurface,
                                                //fontFamily: 'Iransans',
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18.0,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 16, bottom: 8),
                                  child: Text(
                                    context.l10n.clearingAccountNumberLabel,
                                    style: TextStyle(
                                      color: context.colors.onSurface,
                                      //fontFamily: 'Iransans',
                                      fontSize: textScaleFactor * 14.0,
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: context.colors.onSurface,
                                    //fontFamily: 'Iransans',
                                    fontSize: textScaleFactor * 16.0,
                                  ),
                                  textDirection: TextDirection.ltr,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  textInputAction: TextInputAction.go,
                                  keyboardType: TextInputType.number,
                                  controller: shabaController,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: context.appColors.cardBackground,
                                    contentPadding: const EdgeInsets.only(
                                        left: 20.0,
                                        right: 20,
                                        top: 10,
                                        bottom: 10),
                                    border: OutlineInputBorder(
                                      gapPadding: 10,
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: new BorderSide(
                                        color: context.appColors.cardBackground,
                                      ),
                                    ),
                                    labelStyle: TextStyle(
                                      color: AppTheme.iconAccentBlue,
                                      //fontFamily: 'Iransans',
                                      fontSize: textScaleFactor * 10.0,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 16, bottom: 8),
                                  child: Text(
                                    context.l10n.clearingRequestAmountUsdLabel,
                                    style: TextStyle(
                                      color: context.colors.onSurface,
                                      //fontFamily: 'Iransans',
                                      fontSize: textScaleFactor * 14.0,
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: context.colors.onSurface,
                                    //fontFamily: 'Iransans',
                                    fontSize: textScaleFactor * 16.0,
                                  ),
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.center,
                                  textInputAction: TextInputAction.go,
                                  controller: donationController,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: context.appColors.cardBackground,
                                    contentPadding: const EdgeInsets.only(
                                        left: 20.0,
                                        right: 20,
                                        top: 0,
                                        bottom: 10),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide(
                                        width: 0,
                                        color: context.appColors.cardBackground,
                                      ),
                                    ),
                                    labelStyle: TextStyle(
                                      color: AppTheme.iconAccentBlue,
                                      //fontFamily: 'Iransans',
                                      fontSize: textScaleFactor * 10.0,
                                    ),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    new CurrencyInputFormatter(),
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 24, bottom: 8),
                                  child: Text(
                                    context.l10n.clearingPaymentListTitle,
                                    style: TextStyle(
                                      color: context.colors.onSurface,
                                      //fontFamily: 'Iransans',
                                      fontSize: textScaleFactor * 14.0,
                                    ),
                                  ),
                                ),

                                Divider(
                                  height: 1,
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        context.l10n.clearingPaymentListTitle,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: context.colors.onSurface
                                              .withValues(alpha: 0.5),
                                          //fontFamily: 'Iransans',
                                          fontSize: textScaleFactor * 14.0,
                                        ),
                                      ),
                                      Spacer(),
                                      BlocBuilder<CustomerInfoBloc,
                                              CustomerInfoState>(
                                          builder: (_, state) {
                                        return Container(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: deviceHeight * 0.0,
                                                horizontal: 3),
                                            child: Wrap(
                                              alignment: WrapAlignment.start,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              direction: Axis.horizontal,
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 3,
                                                      vertical: 5),
                                                  child: Text(
                                                    context.l10n
                                                        .cartNumberSummaryPrefix,
                                                    style: TextStyle(
                                                      //fontFamily: 'Iransans',
                                                      fontSize:
                                                          textScaleFactor *
                                                              12.0,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 4.0, left: 6),
                                                  child: Text(
                                                    productsDetail.total != -1
                                                        ? EnArConvertor()
                                                            .replaceArNumber(
                                                                loadedProductstolist
                                                                    .length
                                                                    .toString())
                                                        : EnArConvertor()
                                                            .replaceArNumber(
                                                                '0'),
                                                    style: TextStyle(
                                                      //fontFamily: 'Iransans',
                                                      fontSize:
                                                          textScaleFactor *
                                                              13.0,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 3,
                                                      vertical: 5),
                                                  child: Text(
                                                    context.l10n
                                                        .tableColumnFromLabel,
                                                    style: TextStyle(
                                                      //fontFamily: 'Iransans',
                                                      fontSize:
                                                          textScaleFactor *
                                                              12.0,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 4.0, left: 6),
                                                  child: Text(
                                                    productsDetail.total != -1
                                                        ? EnArConvertor()
                                                            .replaceArNumber(
                                                                productsDetail
                                                                    .total
                                                                    .toString())
                                                        : EnArConvertor()
                                                            .replaceArNumber(
                                                                '0'),
                                                    style: TextStyle(
                                                      //fontFamily: 'Iransans',
                                                      fontSize:
                                                          textScaleFactor *
                                                              13.0,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: deviceWidth * 0.10,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            context.l10n.tableColumnStatusLabel,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: context
                                                  .appColors.subtitleColor,
                                              //fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 14.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            context.l10n.tableColumnDateLabel,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: context
                                                  .appColors.subtitleColor,
                                              //fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 14.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            context.l10n.summaryPriceUsdTitle,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: context
                                                  .appColors.subtitleColor,
                                              //fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 14.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: deviceHeight * 0.35,
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    scrollDirection: Axis.vertical,
                                    itemCount: loadedProductstolist.length,
                                    itemBuilder: (ctx, i) =>
                                        ChangeNotifierProvider.value(
                                      value: loadedProductstolist[i],
                                      child: ClearingItemClearScreen(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: InkWell(
                              onTap: () async {
                                SnackBar addToCartSnackBar = SnackBar(
                                  content: Text(
                                    context
                                        .l10n.clearingEnterAccountNumberSnack,
                                    style: TextStyle(
                                      color: context.appColors.cardBackground,
                                      //fontFamily: 'Iransans',
                                      fontSize: textScaleFactor * 14.0,
                                    ),
                                  ),
                                  action: SnackBarAction(
                                    label: context.l10n.understandLabel,
                                    onPressed: () {
                                      // Some code to undo the change.
                                    },
                                  ),
                                );
                                if (shabaController.text == 'IR') {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(addToCartSnackBar);
                                } else if (double.parse(removeSemicolon(
                                        donationController.text)) >
                                    double.parse(customer.money)) {
                                  SnackBar addToCartSnackBar = SnackBar(
                                    content: Text(
                                      context.l10n.clearingAmountExceedsBalance,
                                      style: TextStyle(
                                        color: context.appColors.cardBackground,
                                        //fontFamily: 'Iransans',
                                        fontSize: textScaleFactor * 14.0,
                                      ),
                                    ),
                                    action: SnackBarAction(
                                      label: context.l10n.okLabel,
                                      onPressed: () {
                                        // Some code to undo the change.
                                      },
                                    ),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(addToCartSnackBar);
                                } else {
                                  await sendClearingRequest(
                                          donationController.text,
                                          shabaController.text)
                                      .then((value) => Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                              NavigationBottomScreen.routeName,
                                              (Route<dynamic> route) => false));
                                  _showSenddialog();
                                }
                              },
                              child: ButtonBottom(
                                width: deviceWidth * 0.9,
                                height: deviceWidth * 0.14,
                                text: context.l10n.clearingPayTitle,
                                isActive: true,
                              ),
                            ),
                          ),
                          Positioned(
                              top: 0,
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Align(
                                  alignment: Alignment.center,
                                  child: _isLoading
                                      ? SpinKitFadingCircle(
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return DecoratedBox(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: context
                                                    .appColors.subtitleColor,
                                              ),
                                            );
                                          },
                                        )
                                      : Container()))
                        ],
                      ),
                    ),
            );
          },
        ),
      ),
      drawer: mainDrawerIfRootRoute(context),
    );
  }
}
