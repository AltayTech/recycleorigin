import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/price_weight.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/wasteCart.dart';
import 'package:recycleorigin/core/widgets/buton_bottom.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../customer_feature/presentation/providers/auth.dart';
import '../../../waste_feature/presentation/providers/wastes.dart';
import '../../../waste_feature/presentation/wastes_screen.dart';
import '../../../waste_feature/presentation/widgets/custom_dialog_enter.dart';
import '../../../customer_feature/presentation/widgets/custom_dialog_profile.dart';
import '../../../../core/logic/en_to_ar_number_convertor.dart';
import '../../../../core/widgets/main_drawer.dart';
import '../../../waste_feature/presentation/widgets/waste_cart_item.dart';
import '../../../waste_feature/presentation/address_screen.dart';

class WasteCartScreen extends StatefulWidget {
  static const routeName = '/waste_cart_screen';

  @override
  _WasteCartScreenState createState() => _WasteCartScreenState();
}

class _WasteCartScreenState extends State<WasteCartScreen>
    with TickerProviderStateMixin {
  List<WasteCart> wasteCartItems = [];
  bool _isInit = true;

  var _isLoading = true;
  int totalPrice = 0;
  int totalWeight = 0;
  int totalPricePure = 0;

  void _showLogindialog() {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialogEnter(
        title: 'Login',
        buttonText: 'Login page ',
        description: 'Please Login for continue',
        image: Image.asset('assets/images/main_page_request_ic.png'),
      ),
    );
  }

  void _showCompletedialog() {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialogProfile(
        title: 'User Information',
        buttonText: 'Profile ',
        description: 'Please complete the information for continue',
        image: Image.asset('assets/images/main_page_request_ic.png'),
      ),
    );
  }

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      await Provider.of<Auth>(context, listen: false).checkCompleted();

      await getWasteItems();

      setState(() {});
    }
    _isInit = false;
    await getWasteItems();

    super.didChangeDependencies();
  }

  Future<void> getWasteItems() async {
    setState(() {
      _isLoading = true;
    });
    wasteCartItems = Provider.of<Wastes>(context, listen: false).wasteCartItems;
    totalPrice = 0;
    totalWeight = 0;
    totalPricePure = 0;
    if (wasteCartItems.length > 0) {
      for (int i = 0; i < wasteCartItems.length; i++) {
        print(wasteCartItems[i].featured_image.sizes.medium);
        wasteCartItems[i].prices.length > 0
            ? totalPrice = totalPrice +
                int.parse(getPrice(
                        wasteCartItems[i].prices, wasteCartItems[i].weight)) *
                    wasteCartItems[i].weight
            : totalPrice = totalPrice;
        wasteCartItems[i].prices.length > 0
            ? totalWeight = totalWeight + wasteCartItems[i].weight
            : totalWeight = totalWeight;
      }
    }
    changeNumberAnimation(double.parse(totalPrice.toString()));
    totalPricePure = totalPrice;

    setState(() {
      _isLoading = false;
    });
  }

  String getPrice(List<PriceWeight> prices, int weight) {
    String price = '0';

    for (int i = 0; i < prices.length; i++) {
      if (weight > int.parse(prices[i].weight)) {
        price = prices[i].price;
      } else {
        price = prices[i].price;
        break;
      }
    }
    return price;
  }

  late AnimationController _totalPriceController;
  late Animation<double> _totalPriceAnimation;

  @override
  initState() {
    _totalPriceController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _totalPriceAnimation = _totalPriceController;
    super.initState();
  }

  @override
  void dispose() {
    _totalPriceController.dispose();
    super.dispose();
  }

  void changeNumberAnimation(double newValue) {
    setState(() {
      _totalPriceAnimation = new Tween<double>(
        begin: _totalPriceAnimation.value,
        end: newValue,
      ).animate(new CurvedAnimation(
        curve: Curves.ease,
        parent: _totalPriceController,
      ));
    });
    _totalPriceController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    var currencyFormat = intl.NumberFormat.decimalPattern();
    bool isLogin = Provider.of<Auth>(context, listen: false).isAuth;
    bool isCompleted = Provider.of<Auth>(context, listen: false).isCompleted;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(
          'Waste selection ',
          style: TextStyle(
            color: AppTheme.white,
            fontFamily: 'Iransans',
//            fontSize: textScaleFactor * 14,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: new IconThemeData(color: AppTheme.appBarIconColor),
      ),
      body: Builder(builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              height: double.infinity,
              width: double.infinity,
              child: Stack(
                children: <Widget>[
                  SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: deviceWidth * 0.35,
                          decoration: BoxDecoration(
                              color: AppTheme.white,
                              borderRadius: BorderRadius.circular(5),
                              border:
                                  Border.all(color: Colors.grey, width: 0.2)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      Spacer(),
                                      Image.asset(
                                        'assets/images/main_page_request_ic.png',
                                        height: deviceWidth * 0.09,
                                        width: deviceWidth * 0.09,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 4, bottom: 4),
                                        child: Text(
                                          EnArConvertor()
                                              .replaceArNumber(wasteCartItems
                                                  .length
                                                  .toString())
                                              .toString(),
                                          style: TextStyle(
                                            color: AppTheme.h1,
                                            fontFamily: 'Iransans',
                                            fontSize: textScaleFactor * 18,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Number',
                                        style: TextStyle(
                                          color: AppTheme.grey,
                                          fontFamily: 'Iransans',
                                          fontSize: textScaleFactor * 12,
                                        ),
                                      ),
                                      Spacer(),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      Spacer(),
                                      Image.asset(
                                        'assets/images/waste_cart_price_ic.png',
                                        height: deviceWidth * 0.09,
                                        width: deviceWidth * 0.09,
                                        color: Colors.yellow[600],
                                      ),
                                      AnimatedBuilder(
                                        animation: _totalPriceAnimation,
                                        builder: (BuildContext context,
                                            Widget? child) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                top: 4, bottom: 4),
                                            child: Text(
                                              totalPrice.toString().isNotEmpty
                                                  ? EnArConvertor()
                                                      .replaceArNumber(
                                                          currencyFormat
                                                              .format(
                                                                  double.parse(
                                                                _totalPriceAnimation
                                                                    .value
                                                                    .toStringAsFixed(
                                                                        0),
                                                              ))
                                                              .toString())
                                                  : EnArConvertor()
                                                      .replaceArNumber('0'),
                                              style: TextStyle(
                                                color: AppTheme.h1,
                                                fontFamily: 'Iransans',
                                                fontSize: textScaleFactor * 18,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      Text(
                                        '\$ ',
                                        style: TextStyle(
                                          color: AppTheme.grey,
                                          fontFamily: 'Iransans',
                                          fontSize: textScaleFactor * 12,
                                        ),
                                      ),
                                      Spacer(),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      Spacer(),
                                      Image.asset(
                                        'assets/images/waste_cart_weight_ic.png',
                                        height: deviceWidth * 0.09,
                                        width: deviceWidth * 0.09,
                                      ),
//                                      Icon(
//                                        Icons.av_timer,
//                                        color: Colors.blue,
//                                        size: 40,
//                                      ),
                                      FittedBox(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 4, bottom: 4),
                                          child: Text(
                                            EnArConvertor()
                                                .replaceArNumber(
                                                    totalWeight.toString())
                                                .toString(),
                                            style: TextStyle(
                                              color: AppTheme.h1,
                                              fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      FittedBox(
                                        child: Text(
                                          'Kilogram',
                                          style: TextStyle(
                                            color: AppTheme.grey,
                                            fontFamily: 'Iransans',
                                            fontSize: textScaleFactor * 12,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Consumer<Wastes>(
                            builder: (_, value, ch) => value
                                        .wasteCartItems.length !=
                                    0
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.white,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: value.wasteCartItems.length,
                                        itemBuilder: (ctx, i) => WasteCartItem(
                                          wasteItem: value.wasteCartItems[i],
                                          function: getWasteItems,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: deviceHeight * 0.6,
                                    child: Center(
                                      child: Text('Please add waste'),
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
//                    right: 0,
                    child: InkWell(
                      onTap: () {
                        SnackBar addToCartSnackBar = SnackBar(
                          content: Text(
                            'Please add waste',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Iransans',
                              fontSize: textScaleFactor * 14.0,
                            ),
                          ),
                          action: SnackBarAction(
                            label: 'Ok',
                            onPressed: () {
                              // Some code to undo the change.
                            },
                          ),
                        );
                        if (wasteCartItems.isEmpty) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(addToCartSnackBar);
                        } else if (!isLogin) {
                          _showLogindialog();
                        } else {
                          if (isCompleted) {
                            Navigator.of(context)
                                .pushNamed(AddressScreen.routeName);
                          } else {
                            _showCompletedialog();
                          }
                        }
                      },
                      child: ButtonBottom(
                        width: deviceWidth * 0.75,
                        height: deviceWidth * 0.14,
                        text: 'Continue',
                        isActive: wasteCartItems.isNotEmpty,
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
                              itemBuilder: (BuildContext context, int index) {
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
                          : Container(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      endDrawer: Theme(
        data: Theme.of(context).copyWith(
          // Set the transparency here
          canvasColor: Colors
              .transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
        ),
        child: MainDrawer(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).pushNamed(
            WastesScreen.routeName,
          );
          getWasteItems();
          setState(() {});
        },
        backgroundColor: AppTheme.primary,
        child: Icon(
          Icons.add,
          color: AppTheme.white,
        ),
      ),
    );
  }
}
