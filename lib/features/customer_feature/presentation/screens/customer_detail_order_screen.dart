import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import '../../../../core/models/customer.dart';
import '../../../../core/models/order.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/customer_info_provider.dart';
import '../../../../core/logic/en_to_ar_number_convertor.dart';
import '../../../store_feature/presentation/screens/order_view_screen.dart';

class CustomerDetailOrderScreen extends StatefulWidget {
  final Customer customer;

  CustomerDetailOrderScreen({required this.customer});

  @override
  _CustomerDetailOrderScreenState createState() =>
      _CustomerDetailOrderScreenState();
}

class _CustomerDetailOrderScreenState extends State<CustomerDetailOrderScreen> {
  final double rateRadious = 40;

  final double rateLineWidth = 4.0;

  final int rateAnimDuration = 1200;

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    List<Order> orderList =
        Provider.of<CustomerInfoProvider>(context, listen: false).orders;

    return Container(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Text(
                          EnArConvertor()
                              .replaceArNumber((orderList.length.toString())),
                          style: TextStyle(
                            color: Color(0xffA67FEC),
                            //fontFamily: 'Iransans',
                            fontSize: textScaleFactor * 14.0,
                          ),
                        ),
                        Text(
                          'Number ',
                          style: TextStyle(
                            color: Colors.grey,
                            //fontFamily: 'Iransans',
                            fontSize: textScaleFactor * 14.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Orders',
                      style: TextStyle(
                        color: Colors.blueGrey,
                        //fontFamily: 'Iransans',
                        fontSize: textScaleFactor * 14.0,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/images/orders_list.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
              Directionality(
                textDirection: TextDirection.rtl,
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: orderList.length,
                  itemBuilder: (ctx, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                            OrderViewScreen.routeName,
                            arguments: orderList[index].id);
                      },
                      child: OrderItem(
                        number: orderList[index].id.toString(),
                        date: orderList[index].send_date.toString(),
                        totalPrice: orderList[index].total_price.toString(),
                        status: orderList[index].pay_status.toString(),
                        totalNumber: orderList[index].total_number.toString(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: deviceHeight * 0.05,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class OrderItem extends StatelessWidget {
  const OrderItem({
    required this.number,
    required this.date,
    required this.totalPrice,
    required this.status,
    required this.totalNumber,
  });

  final String number;
  final String date;
  final String totalPrice;
  final String status;
  final String totalNumber;

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    var currencyFormat = intl.NumberFormat.decimalPattern();

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        height: deviceHeight * 0.250,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: AppTheme.accent, width: 0.4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'Order No.: ' + number,
                    style: TextStyle(
                      color: AppTheme.h1,
                      //fontFamily: 'Iransans',
                      fontSize: textScaleFactor * 12.0,
                    ),
                  ),
                  Spacer(),
                  Text(
                    status,
                    style: TextStyle(
                      color: AppTheme.primary,
                      //fontFamily: 'Iransans',
                      fontSize: textScaleFactor * 14.0,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: AppTheme.secondary,
              thickness: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Icon(
                            Icons.calendar_today,
                            color: AppTheme.h1,
                          ),
                        ),
                        Text(
                          date,
                          style: TextStyle(
                            color: AppTheme.primary,
                            //fontFamily: 'Iransans',
                            fontSize: textScaleFactor * 13.0,
                          ),
                        ),
                        Spacer(),
                        Text(
                          EnArConvertor()
                                  .replaceArNumber(currencyFormat
                                      .format(double.parse(totalPrice)))
                                  .toString() +
                              ' \$',
                          style: TextStyle(
                            color: AppTheme.primary,
                            //fontFamily: 'Iransans',
                            fontSize: textScaleFactor * 15.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    indent: 15,
                    endIndent: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Number: ',
                          style: TextStyle(
                            color: Colors.grey,
                            //fontFamily: 'Iransans',
                            fontSize: textScaleFactor * 12.0,
                          ),
                        ),
                        Text(
                          EnArConvertor().replaceArNumber(
                            totalNumber,
                          ),
                          style: TextStyle(
                            color: AppTheme.h1,
                            //fontFamily: 'Iransans',
                            fontSize: textScaleFactor * 14.0,
                          ),
                        ),
                        Spacer(),
                        Text(
                          'Details',
                          style: TextStyle(
                            color: AppTheme.secondary,
                            //fontFamily: 'Iransans',
                            fontSize: textScaleFactor * 11.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
