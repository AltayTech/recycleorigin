import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/logic/en_to_ar_number_convertor.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/main_drawer.dart';
import '../../../customer_feature/presentation/providers/customer_info_provider.dart';
import '../../business/entities/color_code.dart';
import '../../business/entities/gallery.dart';
import '../../business/entities/order_details.dart';
import 'product_detail_screen.dart';

/// This file defines the `OrderViewScreen` widget, which displays detailed information about a specific order.
///
/// The screen includes the following key components:
///
/// - **AppBar**: Displays the title "Order Details" with a customizable theme.
/// - **Order Details**: Shows information such as order status, order number, order date, total price, payment type, and payment status.
/// - **Product List**: A list of products included in the order, with details like title, price, color, and quantity.
/// - **Payment Button**: Allows the user to proceed with payment if the payment option is active.
/// - **Loading Indicator**: Displays a spinner while data is being fetched or actions are being processed.
/// - **Image List**: Displays a list of images associated with the order, if available.
///
/// Key Features:
/// - Fetches order details and payment URLs using `CustomerInfoProvider`.
/// - Handles payment actions and displays appropriate messages for success or failure.
/// - Dynamically updates the UI based on the order's payment and upload status.
/// - Supports navigation to the product detail screen for individual products.
///
/// Dependencies:
/// - `AppTheme`: Provides theme colors and styles.
/// - `EnArConvertor`: Converts numbers and text between English and Arabic.
/// - `CustomerInfoProvider`: Supplies order details and handles payment actions.
/// - `SpinKitFadingCircle`: A loading spinner widget.
/// - `MainDrawer`: A custom navigation drawer widget.
/// - `OrderProductItem`: A custom widget for displaying individual product details.
///
/// Navigation:
/// - Navigates to `ProductDetailScreen` when a product is tapped.
///
/// Note:
/// - Ensure that the `CustomerInfoProvider` is properly configured to fetch order details and payment URLs.
/// - The `AppTheme` and `EnArConvertor` should be implemented to match the app's design and localization requirements.
/// - Handle invalid or missing order IDs gracefully to avoid runtime errors.
class OrderViewScreen extends StatefulWidget {
  static const routeName = '/order_view_screen';

  @override
  _OrderViewScreenState createState() => _OrderViewScreenState();
}

class _OrderViewScreenState extends State<OrderViewScreen> {
  bool _isSelectGallery = false;
  bool _isLoading = false;
  bool _payIsActive = false;
  bool _uploadIsOk = false;
  bool _isInit = true;

  late int orderId;
  List<Gallery> _imageList = [];
  late OrderDetails orderDetails;

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open URL: $urlString')),
      );
    }
  }

  Future<void> pay(int orderId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<CustomerInfoProvider>(context, listen: false)
          .payCashOrder(orderId);

      final payUrl =
          await Provider.of<CustomerInfoProvider>(context, listen: false)
              .payUrl;
      await _launchURL(payUrl);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> cashOrder() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<CustomerInfoProvider>(context, listen: false)
          .getOrderDetails(orderId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to load order details: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void checkStatus(OrderDetails oDt) {
    if (oDt.pay_type_slug == 'naghd') {
      _payIsActive = oDt.pay_status_slug == 'not_pay';
    } else {
      _payIsActive = oDt.pay_status_slug == 'not_pay';
      _uploadIsOk = oDt.order_status_slug == 'cheque_ok';
    }
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is int) {
        orderId = arguments;
        cashOrder();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid order ID')),
        );
        Navigator.of(context).pop();
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Widget _buildLoadingIndicator() {
    return SpinKitFadingCircle(
      itemBuilder: (BuildContext context, int index) {
        return DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index.isEven ? Colors.grey : Colors.grey,
          ),
        );
      },
    );
  }

  Widget _buildPaymentButton(double deviceHeight) {
    return InkWell(
      onTap: () {
        if (_payIsActive) {
          pay(orderId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'This payment option is not available',
                style: TextStyle(
                  color: Colors.white,
                  //fontFamily: 'Iransans',
                ),
              ),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: deviceHeight * 0.08,
          decoration: BoxDecoration(
            color: _payIsActive ? AppTheme.primary : Colors.grey,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 2.0,
                spreadRadius: 1.50,
                offset: Offset(1.0, 1.0),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  Icons.monetization_on,
                  color: Colors.white,
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0, left: 10),
                  child: Text(
                    'Payment',
                    style: TextStyle(
                      color: Colors.white,
                      //fontFamily: 'Iransans',
                      fontSize: MediaQuery.of(context).textScaleFactor * 16.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(String? price) {
    if (price == null || price.isEmpty) {
      return '0 \$';
    }

    try {
      final currencyFormat = intl.NumberFormat.decimalPattern();
      final formattedPrice = EnArConvertor()
          .replaceArNumber(currencyFormat.format(double.parse(price)));
      return '$formattedPrice \$';
    } catch (e) {
      return '0 \$';
    }
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    var currencyFormat = intl.NumberFormat.decimalPattern();

    orderDetails =
        Provider.of<CustomerInfoProvider>(context, listen: false).getOrder();
    checkStatus(orderDetails);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: IconThemeData(color: AppTheme.appBarIconColor),
        title: Text(
          'Order Details',
          style: TextStyle(
            color: AppTheme.appBarIconColor,
            //fontFamily: 'Iransans',
          ),
        ),
      ),
      body: Builder(
        builder: (context) => Container(
          height: deviceHeight * 0.8,
          width: deviceWidth,
          child: Align(
            alignment: Alignment.topCenter,
            child: _isLoading
                ? _buildLoadingIndicator()
                : Directionality(
                    textDirection: TextDirection.rtl,
                    child: SingleChildScrollView(
                      child: Wrap(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        'Order Status: ',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          //fontFamily: 'Iransans',
                                          fontSize: textScaleFactor * 14,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        orderDetails.order_status.toString(),
                                        style: TextStyle(
                                          color: AppTheme.primary,
                                          //fontFamily: 'Iransans',
                                          fontSize: textScaleFactor * 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            'Order Number: ',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              //fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 14,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            orderDetails.shenaseh.toString(),
                                            style: TextStyle(
                                              color: AppTheme.black,
                                              //fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            'Order Date: ',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              //fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 14,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            orderDetails.order_register_date
                                                .toString(),
                                            style: TextStyle(
                                              color: AppTheme.black,
                                              //fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            'Total Price: ',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              //fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 14,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            EnArConvertor()
                                                    .replaceArNumber(
                                                        currencyFormat.format(
                                                            double.parse(
                                                                orderDetails
                                                                    .total_cost)))
                                                    .toString() +
                                                ' \$',
                                            style: TextStyle(
                                              color: AppTheme.black,
                                              //fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            'Payment Type: ',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              //fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 14,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            orderDetails.pay_type.toString(),
                                            style: TextStyle(
                                              color: AppTheme.black,
                                              //fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            'Payment Status: ',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              //fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 14,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            orderDetails.pay_status.toString(),
                                            style: TextStyle(
                                              color: AppTheme.black,
                                              //fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            'Prepay: ',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              //fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 14,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            orderDetails.pish.isNotEmpty
                                                ? _formatPrice(
                                                    orderDetails.pish)
                                                : '-',
                                            style: TextStyle(
                                              color: AppTheme.black,
                                              //fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 14,
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Product List',
                              style: TextStyle(
                                color: Colors.black,
                                //fontFamily: 'Iransans',
                                fontSize: textScaleFactor * 14,
                              ),
                            ),
                          ),
                          Card(
                            child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: orderDetails.products.length,
                                itemBuilder: (ctx, i) {
                                  return OrderProductItem(
                                    id: orderDetails.products[i].id,
                                    title: orderDetails.products[i].title,
                                    price: orderDetails.products[i].price_low,
                                    color:
                                        orderDetails.products[i].selected_color,
                                    number: orderDetails.number_of_products
                                        .toString(),
                                  );
                                }),
                          ),
                          if (_imageList.isNotEmpty)
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: _imageList.length,
                              itemBuilder: (ctx, i) {
                                return Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height: deviceHeight * 0.3,
                                        child: Wrap(
                                          children: <Widget>[
                                            Text((i + 1).toString()),
                                            Image.network(
                                              _imageList[i].url,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Center(
                                                  child: Text(
                                                      'Image not available'),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          _buildPaymentButton(deviceHeight),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
      endDrawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
        ),
        child: MainDrawer(),
      ),
    );
  }
}

class OrderProductItem extends StatelessWidget {
  const OrderProductItem({
    required this.id,
    required this.number,
    required this.price,
    required this.color,
    required this.title,
  });

  final int id;
  final String number;
  final String price;
  final ColorCode color;
  final String title;

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    var currencyFormat = intl.NumberFormat.decimalPattern();

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        height: deviceHeight * 0.15,
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(5),
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: id,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                        //fontFamily: 'Iransans',
                        fontSize: textScaleFactor * 14.0,
                        color: AppTheme.black),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Number: ' +
                              EnArConvertor()
                                  .replaceArNumber(number)
                                  .toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            //fontFamily: 'Iransans',
                            fontSize: textScaleFactor * 14.0,
                          ),
                        ),
                      ),
                      Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    color.title,
                                    style: TextStyle(
                                      color: AppTheme.black,
                                      //fontFamily: 'Iransans',
                                      fontSize: textScaleFactor * 12,
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.all(10),
                                  width: 15.0,
                                  height: 15.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.black, width: 0.2),
                                    color: Color(
                                      int.parse(
                                        '0xff' +
                                            color.color_code
                                                .replaceRange(0, 1, ''),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      Expanded(
                        flex: 4,
                        child: Text(
                          price.toString().isNotEmpty
                              ? EnArConvertor()
                                      .replaceArNumber(currencyFormat
                                          .format(double.tryParse(price) ?? 0))
                                      .toString() +
                                  ' \$'
                              : '0 \$',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              //fontFamily: 'Iransans',
                              fontSize: textScaleFactor * 16.0,
                              color: AppTheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
