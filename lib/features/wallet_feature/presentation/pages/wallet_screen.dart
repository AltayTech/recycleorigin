import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:recycleorigin/core/models/customer.dart';
import 'package:recycleorigin/core/models/transaction.dart';
import 'package:recycleorigin/features/Charities/presentation/pages/charity_screen.dart';
import 'package:recycleorigin/features/clearing_feature/presentation/pages/clear_screen.dart';
import 'package:recycleorigin/features/customer_feature/presentation/providers/authentication_provider.dart';
import 'package:recycleorigin/features/customer_feature/presentation/providers/customer_info_provider.dart';
import 'package:recycleorigin/features/wallet_feature/presentation/widgets/transaction_item_transactions_screen.dart';

import '../../../../core/logic/en_to_ar_number_convertor.dart';
import '../../../../core/models/search_detail.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/main_drawer.dart';
import '../../../customer_feature/presentation/screens/login_screen.dart';

class WalletScreen extends StatefulWidget {
  static const routeName = '/walletScreen';

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  bool _isInit = true;
  ScrollController _scrollController = new ScrollController();
  var _isLoading;
  int page = 1;
  SearchDetail productsDetail = SearchDetail();

  late Customer customer;

  @override
  void initState() {
    Provider.of<CustomerInfoProvider>(context, listen: false).sPage = 1;

    Provider.of<CustomerInfoProvider>(context, listen: false).searchBuilder();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (page < productsDetail.max_page) {
          page = page + 1;
          Provider.of<CustomerInfoProvider>(context, listen: false).sPage =
              page;

          searchItems();
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      getCustomerInfo();
      searchItems();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> getCustomerInfo() async {
    bool isLogin =
        Provider.of<AuthenticationProvider>(context, listen: false).isAuth;
    if (isLogin) {
      await Provider.of<CustomerInfoProvider>(context, listen: false)
          .getCustomer();
    }
  }

  List<Transaction> loadedProducts = [];
  List<Transaction> loadedProductstolist = [];

  Future<void> searchItems() async {
    setState(() {
      _isLoading = true;
    });

    Provider.of<CustomerInfoProvider>(context, listen: false).searchBuilder();
    await Provider.of<CustomerInfoProvider>(context, listen: false)
        .searchTransactionItems();
    productsDetail =
        Provider.of<CustomerInfoProvider>(context, listen: false).searchDetails;

    loadedProducts.clear();
    loadedProducts =
        await Provider.of<CustomerInfoProvider>(context, listen: false)
            .transactionItems;
    loadedProductstolist.addAll(loadedProducts);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    bool isLogin = Provider.of<AuthenticationProvider>(context).isAuth;

    var currencyFormat = intl.NumberFormat.decimalPattern();

    return Scaffold(
      backgroundColor: Color(0xffF9F9F9),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Wallet',
          style: TextStyle(
            fontFamily: 'Iransans',
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.appBarColor,
        iconTheme: new IconThemeData(color: AppTheme.appBarIconColor),
        elevation: 0,
        centerTitle: true,
        actions: <Widget>[],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: deviceHeight * 0.0, horizontal: deviceWidth * 0.03),
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
                          child: Text('You are not logged in'),
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
                                'Login',
                                style: TextStyle(color: Colors.white),
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
              : Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              color: AppTheme.bg,
                              border: Border.all(width: 5, color: AppTheme.bg)),
                          height: deviceWidth * 0.5,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  height: deviceWidth * 0.9,
                                  width: deviceWidth,
                                  child: FadeInImage(
                                    placeholder:
                                        AssetImage('assets/images/circle.gif'),
                                    image: AssetImage(
                                        'assets/images/wallet_money_bg.png'),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'Credit',
                                        style: TextStyle(
                                          color: AppTheme.grey,
                                          fontFamily: 'Iransans',
                                          fontSize: textScaleFactor * 13.0,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Consumer<CustomerInfoProvider>(
                                        builder: (_, data, ch) => Text(
                                          data.customer != null
                                              ? EnArConvertor().replaceArNumber(
                                                  currencyFormat
                                                      .format(double.parse(data
                                                              .customer.money)
                                                          .round())
                                                      .toString())
                                              : EnArConvertor().replaceArNumber(
                                                  currencyFormat.format(
                                                      double.parse('0'))),
                                          style: TextStyle(
                                            color: AppTheme.black,
                                            fontFamily: 'Iransans',
                                            fontWeight: FontWeight.w700,
                                            fontSize: textScaleFactor * 18.0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Text(
                                        '\$',
                                        style: TextStyle(
                                          color: AppTheme.grey,
                                          fontFamily: 'Iransans',
                                          fontSize: textScaleFactor * 13.0,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed(ClearScreen.routeName);
                                },
                                child: Container(
                                  width: deviceWidth * 0.42,
                                  height: deviceWidth * 0.12,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 0.0,
                                        // has the effect of softening the shadow
                                        spreadRadius: 0,
                                        // has the effect of extending the shadow
                                        offset: Offset(
                                          1.0, // horizontal, move right 10
                                          1.0, // vertical, move down 10
                                        ),
                                      )
                                    ],
                                    color: Color(0xffFF595E),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8, top: 0, left: 0),
                                          child: Icon(
                                            Icons.attach_money,
                                            color: AppTheme.white,
                                          ),
                                        ),
                                        Center(
                                          child: Text(
                                            'Withdraw request',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Iransans',
                                              fontSize: 14.0,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Spacer(),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5.0, bottom: 5),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushNamed(CharityScreen.routeName);
                                  },
                                  child: Container(
                                    width: deviceWidth * 0.42,
                                    height: deviceWidth * 0.12,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey,
                                          blurRadius: 0.0,
                                          // has the effect of softening the shadow
                                          spreadRadius: 0.0,
                                          // has the effect of extending the shadow
                                          offset: Offset(
                                            1.0, // horizontal, move right 10
                                            1.0, // vertical, move down 10
                                          ),
                                        )
                                      ],
                                      color: Color(0xff6A4C93),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 12, top: 7, left: 3),
                                              child: Image.asset(
                                                  'assets/images/donation_ic.png'),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Text(
                                                'Donate to charity',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Iransans',
                                                  fontSize:
                                                      textScaleFactor * 14.0,
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: AppTheme.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          'Transaction list',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color:
                                                AppTheme.black.withOpacity(0.5),
                                            fontFamily: 'Iransans',
                                            fontSize: textScaleFactor * 14.0,
                                          ),
                                        ),
                                        Spacer(),
                                        Consumer<CustomerInfoProvider>(
                                            builder: (_, Wastes, ch) {
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
                                                      'Number:',
                                                      style: TextStyle(
                                                        fontFamily: 'Iransans',
                                                        fontSize:
                                                            textScaleFactor *
                                                                12.0,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 4.0,
                                                            left: 6),
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
                                                        fontFamily: 'Iransans',
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
                                                      'from',
                                                      style: TextStyle(
                                                        fontFamily: 'Iransans',
                                                        fontSize:
                                                            textScaleFactor *
                                                                12.0,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 4.0,
                                                            left: 6),
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
                                                        fontFamily: 'Iransans',
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
                                              'type',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: AppTheme.grey,
                                                fontFamily: 'Iransans',
                                                fontSize:
                                                    textScaleFactor * 14.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'for',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: AppTheme.grey,
                                                fontFamily: 'Iransans',
                                                fontSize:
                                                    textScaleFactor * 14.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'amount(\$)',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: AppTheme.grey,
                                                fontFamily: 'Iransans',
                                                fontSize:
                                                    textScaleFactor * 14.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: deviceHeight * 0.68,
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      scrollDirection: Axis.vertical,
                                      itemCount: loadedProductstolist.length,
                                      itemBuilder: (ctx, i) =>
                                          ChangeNotifierProvider.value(
                                        value: loadedProductstolist[i],
                                        child:
                                            TransactionItemTransactionsScreen(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return DecoratedBox(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: index.isEven
                                              ? Colors.grey
                                              : Colors.grey,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    child: loadedProductstolist.isEmpty
                                        ? Center(
                                            child: Text(
                                            'there is no transaction',
                                            style: TextStyle(
                                              fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 15.0,
                                            ),
                                          ))
                                        : Container())))
                  ],
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
