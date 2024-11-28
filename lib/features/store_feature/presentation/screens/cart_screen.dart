import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:recycleorigin/core/widgets/buton_bottom.dart';

import '../../../../models/customer.dart';
import '../../business/entities/product_cart.dart';
import '../providers/Products.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customer_feature/presentation/providers/auth.dart';
import '../../../customer_feature/presentation/providers/customer_info.dart';
import 'order_products_send_screen.dart';
import '../../../../widgets/card_item.dart';
import '../../../../widgets/custom_dialog_enter.dart';
import '../../../customer_feature/presentation/widgets/custom_dialog_profile.dart';
import '../../../../core/logic/en_to_ar_number_convertor.dart';
import '../../../../core/widgets/main_drawer.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart_screen';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<ProductCart> shoppItems = [];
  bool _isInit = true;

  var _isLoading = true;
  late Customer customer;
  int totalPrice = 0;
  int transportCost = 10000;

  late int totalPricePure;

  void _showLogindialog() {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialogEnter(
        title: 'ورود',
        buttonText: 'صفحه ورود ',
        description: 'برای ادامه لطفا وارد شوید',
        image: Image.asset('assets/images/main_page_request_ic.png'),
      ),
    );
  }

  void _showCompletedialog() {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialogProfile(
        title: 'اطلاعات کاربری',
        buttonText: 'صفحه پروفایل ',
        description: 'برای ادامه باید اطلاعات کاربری تکمیل کنید',
        image: Image.asset('assets/images/main_page_request_ic.png'),
      ),
    );
  }

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      await Provider.of<Auth>(context, listen: false).checkCompleted();

      await getShopItems();
      customer = Provider.of<CustomerInfo>(context, listen: false).customer;
      _isLoading = true;

//      await getShopItems();
      bool isLogin = Provider.of<Auth>(context, listen: false).isAuth;

      if (isLogin) {
        try {
          await Provider.of<CustomerInfo>(context, listen: false)
              .getCustomer()
              .then(
            (_) {
              customer =
                  Provider.of<CustomerInfo>(context, listen: false).customer;
            },
          );
        } catch (error) {
          print(error);

          throw (error);
        }
      }

      _isLoading = false;
      setState(() {});
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  Future<void> getShopItems() async {
    setState(() {
      _isLoading = true;
    });
    shoppItems = Provider.of<Products>(context, listen: false).cartItems;
    totalPrice = 0;
    transportCost = 10000;

    totalPricePure = 0;
    if (shoppItems.isNotEmpty) {
      for (int i = 0; i < shoppItems.length; i++) {
        shoppItems[i].price.isNotEmpty
            ? totalPrice = totalPrice +
                int.parse(shoppItems[i].price) * shoppItems[i].productCount
            : totalPrice = totalPrice;
      }
    }
    totalPricePure = totalPrice + transportCost;

    setState(() {
      _isLoading = false;
      print(_isLoading.toString());
    });
    print(_isLoading.toString());
  }

  void setStateFun() {
    getShopItems();
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    var currencyFormat = intl.NumberFormat.decimalPattern();
    bool isLogin = Provider.of<Auth>(context, listen: false).isAuth;
    bool isCompleted = Provider.of<Auth>(context, listen: false).isCompleted;

    getShopItems();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: new IconThemeData(color: AppTheme.appBarIconColor),
      ),
      body: Builder(builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            color: AppTheme.bg,
            height: double.infinity,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Stack(
                children: <Widget>[
                  SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: deviceHeight * 0.07,
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
                                Text(
                                  'تعداد: ' +
                                      EnArConvertor()
                                          .replaceArNumber(
                                              shoppItems.length.toString())
                                          .toString(),
                                  style: TextStyle(
                                    color: AppTheme.black,
                                    fontFamily: 'Iransans',
                                    fontSize: textScaleFactor * 14,
                                  ),
                                ),
                                VerticalDivider(
                                  color: AppTheme.grey,
                                  thickness: 1,
                                  indent: 4,
                                  endIndent: 4,
                                ),
                                Text(
                                  'مبلغ قابل پرداخت (تومان)',
                                  style: TextStyle(
                                    color: AppTheme.grey,
                                    fontFamily: 'Iransans',
                                    fontSize: textScaleFactor * 12,
                                  ),
                                ),
                                Text(
                                  totalPrice.toString().isNotEmpty
                                      ? EnArConvertor().replaceArNumber(
                                          currencyFormat
                                              .format(totalPrice)
                                              .toString())
                                      : EnArConvertor().replaceArNumber('0'),
                                  style: TextStyle(
                                    color: AppTheme.black,
                                    fontFamily: 'Iransans',
                                    fontSize: textScaleFactor * 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: shoppItems.length != 0
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.bg,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: shoppItems.length,
                                    itemBuilder: (ctx, i) => CardItem(
                                      shoppItem: shoppItems[i],
                                      callFunction: setStateFun,
                                    ),
                                  ),
                                )
                              : Center(child: Text('محصولی اضافه نشده است')),
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
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        SnackBar addToCartSnackBar = SnackBar(
                          content: Text(
                            'سبد خرید خالی می باشد!',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Iransans',
                              fontSize: textScaleFactor * 14.0,
                            ),
                          ),
                          action: SnackBarAction(
                            label: 'متوجه شدم',
                            onPressed: () {
                              // Some code to undo the change.
                            },
                          ),
                        );
                        if (shoppItems.isEmpty) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(addToCartSnackBar);
                        } else if (!isLogin) {
                          _showLogindialog();
                        } else {
                          if (isCompleted) {
                            Navigator.of(context)
                                .pushNamed(OrderProductsSendScreen.routeName);
                          } else {
                            _showCompletedialog();
                          }
                        }
                      },
                      child: ButtonBottom(
                        width: deviceWidth * 0.9,
                        height: deviceWidth * 0.14,
                        text: 'انجام خرید',
                        isActive: shoppItems.isNotEmpty,
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
                              : Container()))
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
    );
  }
}
