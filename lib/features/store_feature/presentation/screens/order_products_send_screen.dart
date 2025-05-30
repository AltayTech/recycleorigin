import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:recycleorigin/core/widgets/buton_bottom.dart';
import 'package:recycleorigin/core/widgets/custom_dialog_send_request.dart';

import '../../../../core/logic/en_to_ar_number_convertor.dart';
import '../../../../core/models/customer.dart';
import '../../../../core/screens/navigation_bottom_screen.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/main_drawer.dart';
import '../../../customer_feature/presentation/providers/customer_info_provider.dart';
import '../../business/entities/order_send_details.dart';
import '../../business/entities/product_cart.dart';
import '../../business/entities/product_order_send.dart';
import '../providers/Products.dart';

class OrderProductsSendScreen extends StatefulWidget {
  static const routeName = '/orderProductsSendScreen';

  @override
  _OrderProductsSendScreenState createState() =>
      _OrderProductsSendScreenState();
}

class _OrderProductsSendScreenState extends State<OrderProductsSendScreen> {
  var _isLoading = false;
  var _isInit = true;

  late OrderSendDetails orderRequest;

  late List<ProductCart> shoppItems;

  int totalNumber = 0;

  int totalPrice = 0;

  List<ProductOrderSend> productsList = [];

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      await getRegionDate();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> getRegionDate() async {
    setState(() {
      _isLoading = true;
    });

    shoppItems = Provider.of<Products>(context, listen: false).cartItems;
    totalNumber = 0;
    totalPrice = 0;

    if (shoppItems.length > 0) {
      totalNumber = shoppItems.length;

      for (int i = 0; i < shoppItems.length; i++) {
        shoppItems[i].price.isNotEmpty
            ? totalPrice = totalPrice +
                int.parse(shoppItems[i].price) * shoppItems[i].productCount
            : totalPrice = totalPrice;
        productsList.add(ProductOrderSend(
          product: shoppItems[i].id,
          number: shoppItems[i].productCount.toString(),
          total_price:
              (shoppItems[i].productCount * int.parse(shoppItems[i].price))
                  .toString(),
          price: shoppItems[i].price,
        ));
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> createRequest(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    orderRequest = OrderSendDetails(
        total_number: totalNumber.toString(),
        total_price: totalPrice.toString(),
        products: productsList);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> sendRequest(
    BuildContext context,
  ) async {
    setState(() {
      _isLoading = true;
    });

    await Provider.of<Products>(context, listen: false)
        .sendRequest(orderRequest);

    setState(() {
      _isLoading = false;
    });
  }

  void _showSendOrderdialog() {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialogSendRequest(
        title: '',
        buttonText: 'OK',
        description: 'Your order has been sent successfully.',
        image: Image.asset('assets/images/main_page_request_ic.png'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    var currencyFormat = intl.NumberFormat.decimalPattern();

    Customer customer =
        Provider.of<CustomerInfoProvider>(context, listen: false).customer;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: new IconThemeData(color: AppTheme.appBarIconColor),
      ),
      body: Builder(
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 0,
                right: 0,
                height: deviceHeight * 0.35,
                child: Image.asset(
                  'assets/images/cash_pay_header.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: deviceHeight * 0.1,
                left: deviceWidth * 0.1,
                child: Text(
                  'Pay ',
                  style: TextStyle(
                      color: AppTheme.bg,
                      //fontFamily: 'Iransans',
                      fontSize: textScaleFactor * 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: deviceHeight * 0.22,
                left: 0,
                right: 0,
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      height: deviceHeight * 0.55,
                      width: deviceWidth * 0.8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  topLeft: Radius.circular(10),
                                ),
                                color: AppTheme.primary),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 15.0, bottom: 15.0),
                                child: Text(
                                  'Information',
                                  style: TextStyle(
                                    color: AppTheme.bg,
                                    //fontFamily: 'Iransans',
                                    fontSize: textScaleFactor * 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: AppTheme.h1, width: 0.3),
                                color: AppTheme.bg),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Wrap(
                                      children: <Widget>[
                                        Text(
                                          'Name and Latname:    ',
                                          style: TextStyle(
                                            color: AppTheme.grey,
                                            //fontFamily: 'Iransans',
                                            fontSize: textScaleFactor * 14,
                                          ),
                                        ),
                                        Text(
                                          customer.personalData.first_name +
                                              ' ' +
                                              customer.personalData.last_name,
                                          style: TextStyle(
                                            color: AppTheme.black,
                                            //fontFamily: 'Iransans',
                                            fontSize: textScaleFactor * 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Wrap(
                                      children: <Widget>[
                                        Text(
                                          'Province:    ',
                                          style: TextStyle(
                                            color: AppTheme.grey,
                                            //fontFamily: 'Iransans',
                                            fontSize: textScaleFactor * 14,
                                          ),
                                        ),
                                        Text(
                                          customer.personalData.ostan,
                                          style: TextStyle(
                                            color: AppTheme.black,
                                            //fontFamily: 'Iransans',
                                            fontSize: textScaleFactor * 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Wrap(
                                      children: <Widget>[
                                        Text(
                                          'City:   ',
                                          style: TextStyle(
                                            color: AppTheme.grey,
                                            //fontFamily: 'Iransans',
                                            fontSize: textScaleFactor * 14,
                                          ),
                                        ),
                                        Text(
                                          customer.personalData.city,
                                          style: TextStyle(
                                            color: AppTheme.black,
                                            //fontFamily: 'Iransans',
                                            fontSize: textScaleFactor * 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Wrap(
                                      children: <Widget>[
                                        Text(
                                          'Zipcode:    ',
                                          style: TextStyle(
                                            color: AppTheme.grey,
                                            //fontFamily: 'Iransans',
                                            fontSize: textScaleFactor * 14,
                                          ),
                                        ),
                                        Text(
                                          EnArConvertor().replaceArNumber(
                                              customer.personalData.postcode),
                                          style: TextStyle(
                                            color: AppTheme.black,
                                            //fontFamily: 'Iransans',
                                            fontSize: textScaleFactor * 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Wrap(
                                      children: <Widget>[
                                        Text(
                                          'Mobile:    ',
                                          style: TextStyle(
                                            color: AppTheme.grey,
                                            //fontFamily: 'Iransans',
                                            fontSize: textScaleFactor * 14,
                                          ),
                                        ),
                                        Text(
                                          EnArConvertor().replaceArNumber(
                                              (customer.personalData.mobile
                                                      .toString())
                                                  .toString()),
                                          style: TextStyle(
                                            color: AppTheme.black,
                                            //fontFamily: 'Iransans',
                                            fontSize: textScaleFactor * 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Container(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Total Price: ',
                                    style: TextStyle(
                                      color: AppTheme.grey,
                                      //fontFamily: 'Iransans',
                                      fontSize: textScaleFactor * 14,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    EnArConvertor().replaceArNumber(
                                        currencyFormat
                                            .format(totalPrice)
                                            .toString()),
                                    style: TextStyle(
                                      color: AppTheme.black,
                                      //fontFamily: 'Iransans',
                                      fontWeight: FontWeight.w700,
                                      fontSize: textScaleFactor * 22,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: InkWell(
                  onTap: () async {
                    if (totalPrice == 0) {
                      var _snackBarMessage = 'No Item!';
                      final addToCartSnackBar = SnackBar(
                        content: Text(
                          _snackBarMessage,
                          style: TextStyle(
                            color: Colors.white,
                            //fontFamily: 'Iransans',
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
                      ScaffoldMessenger.of(context)
                          .showSnackBar(addToCartSnackBar);
                    } else if (totalPrice > double.parse(customer.money)) {
                      var _snackBarMessage =
                          'The amount in your wallet is not enough.';
                      final addToCartSnackBar = SnackBar(
                        content: Text(
                          _snackBarMessage,
                          style: TextStyle(
                            color: Colors.white,
                            //fontFamily: 'Iransans',
                            fontSize: textScaleFactor * 14.0,
                          ),
                        ),
                        action: SnackBarAction(
                          label: 'OK',
                          onPressed: () {
                            // Some code to undo the change.
                          },
                        ),
                      );
                      ScaffoldMessenger.of(context)
                          .showSnackBar(addToCartSnackBar);
                    } else {
                      await createRequest(context).then(
                        (value) => sendRequest(context).then(
                          (value) {
                            Provider.of<Products>(context, listen: false)
                                .cartItems = [];
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                NavigationBottomScreen.routeName,
                                (Route<dynamic> route) => false);

                            _showSendOrderdialog();
                          },
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ButtonBottom(
                      width: deviceWidth * 0.9,
                      height: deviceWidth * 0.14,
                      text: 'Buy',
                      isActive: true,
                    ),
                  ),
                ),
              ),
              Positioned(
                height: deviceHeight * 0.8,
                width: deviceWidth,
                child: Align(
                    alignment: Alignment.center,
                    child: _isLoading
                        ? SpinKitFadingCircle(
                            itemBuilder: (BuildContext context, int index) {
                              return DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      index.isEven ? Colors.grey : Colors.grey,
                                ),
                              );
                            },
                          )
                        : Container()),
              ),
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
