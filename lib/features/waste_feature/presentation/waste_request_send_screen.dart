import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:recycleorigin/core/widgets/buton_bottom.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/collect.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/collect_time.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/pasmand.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/price_weight.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/request_address.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/request_waste.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/wasteCart.dart';

import '../../../core/logic/en_to_ar_number_convertor.dart';
import '../../../core/models/customer.dart';
import '../../../core/models/region.dart';
import '../../../core/screens/navigation_bottom_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_dialog_send_request.dart';
import '../../../core/widgets/main_drawer.dart';
import '../../customer_feature/presentation/providers/authentication_provider.dart';
import '../../customer_feature/presentation/widgets/custom_dialog_profile.dart';
import '../business/entities/address.dart';
import 'providers/wastes.dart';
import 'widgets/custom_dialog_enter.dart';

class WasteRequestSendScreen extends StatefulWidget {
  static const routeName = '/waste_request_send_screen';

  @override
  _WasteRequestSendScreenState createState() => _WasteRequestSendScreenState();
}

class _WasteRequestSendScreenState extends State<WasteRequestSendScreen> {
  List<WasteCart> wasteCartItems = [];
  bool _isInit = true;

  var _isLoading = true;
  late Customer customer;
  int totalPrice = 0;
  int totalWeight = 0;

  late int totalPricePure;

  late Address selectedAddress;

  late Region selectedRegion;

  late String _selectedHourStart;

  late String _selectedHourend;

  List<String> months = [];

  List<String> weekDays = [];

  List<DateTime> dateList = [];

  late String selectedHours = '0';

  late DateTime selectedDay = DateTime.now();

  late RequestWaste requestWaste;

  void _showLogindialog() {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialogEnter(
        title: 'Login',
        buttonText: 'Login Screen ',
        description: 'Login to continue',
        image: Image.asset('assets/images/main_page_request_ic.png'),
      ),
    );
  }

  void _showCompletedialog() {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialogProfile(
        title: 'Profile info',
        buttonText: 'Profile Screen ',
        description: 'Please complete your profile',
        image: Image.asset('assets/images/main_page_request_ic.png'),
      ),
    );
  }

  void _showSenddialog() {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialogSendRequest(
        title: '',
        buttonText: 'OK',
        description: 'Your request has been sent successfully',
        image: Image.asset('assets/images/main_page_request_ic.png'),
      ),
    );
  }

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      _isLoading = true;

      await getRegionDate();

      _isLoading = false;
      setState(() {});
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  Future<void> getRegionDate() async {
    setState(() {
      _isLoading = true;
    });

    getDate(3);
    getMonthAndWeek();
    selectedRegion =
        Provider.of<AuthenticationProvider>(context, listen: false).regionData;
    selectedHours = Provider.of<Wastes>(context, listen: false).selectedHours;
    selectedDay = Provider.of<Wastes>(context, listen: false).selectedDay;

    selectedAddress =
        Provider.of<AuthenticationProvider>(context, listen: false)
            .selectedAddress;

    await Provider.of<AuthenticationProvider>(context, listen: false)
        .retrieveRegion(selectedAddress.region.term_id);
    await Provider.of<AuthenticationProvider>(context, listen: false)
        .checkCompleted();

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

  String getHours(String start, String end) {
    String date = '';

    date = start.substring(0, 2) + '-' + end.substring(0, 2);

    return date;
  }

  void getMonthAndWeek() {
    months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    weekDays = [
      'Saturday',
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
    ];
  }

  Future<void> getDate(int numberFutureDate) async {
    DateTime dateTime = DateTime.now();
    dateList.clear();

    for (int i = 0; i < numberFutureDate; i++) {
      dateList.add(dateTime.add(Duration(days: i)));
    }
  }

  Future<void> changeCat(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> createRequest(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    List<Collect> collectList = [];
    for (int i = 0; i < wasteCartItems.length; i++) {
      collectList.add(
        Collect(
          estimated_weight: wasteCartItems[i].weight.toString(),
          estimated_price:
              getPrice(wasteCartItems[i].prices, wasteCartItems[i].weight),
          pasmand: Pasmand(
              id: wasteCartItems[i].id, post_title: wasteCartItems[i].name),
          exact_weight: '',
          exact_price: '',
        ),
      );
    }

    requestWaste = RequestWaste(
        collect_date: CollectTime(
            time: selectedHours,
            day:
                '${weekDays[selectedDay.weekday - 1]}  ${selectedDay.day} ${months[selectedDay.month]}'),
        address_data: RequestAddress(
          name: selectedAddress.name,
          address: selectedAddress.address,
          region: selectedAddress.region.term_id.toString(),
          latitude: selectedAddress.latitude,
          longitude: selectedAddress.longitude,
        ),
        collect_list: collectList);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> sendRequest(BuildContext context, bool isLogin) async {
    setState(() {
      _isLoading = true;
    });

    await Provider.of<Wastes>(context, listen: false)
        .sendRequest(requestWaste, isLogin);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    // var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    var currencyFormat = intl.NumberFormat.decimalPattern();
    bool isLogin =
        Provider.of<AuthenticationProvider>(context, listen: false).isAuth;
    bool isCompleted =
        Provider.of<AuthenticationProvider>(context, listen: false).isCompleted;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Register Request',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.white,
            //fontFamily: 'Iransans',
            // fontSize: 15.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: new IconThemeData(color: AppTheme.appBarIconColor),
      ),
      body: Builder(builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            height: double.infinity,
            width: double.infinity,
            child: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          'Request Details',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.h1,
                            //fontFamily: 'Iransans',
                            fontSize: 17.0,
                          ),
                        ),
                      ),
                      Card(
                        color: AppTheme.white,
                        child: Container(
                          height: deviceHeight * 0.25,
                          width: deviceWidth * 0.9,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            // borderRadius: BorderRadius.circular(5),
                            // border: Border.all(
                            //   color: Colors.grey,
                            //   width: 0.2,
                            // ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Expanded(
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.asset(
                                          'assets/images/main_page_request_ic.png',
                                          height: deviceWidth * 0.06,
                                          width: deviceWidth * 0.06,
                                        ),
                                      ),
                                      Text(
                                        'Number',
                                        style: TextStyle(
                                          color: AppTheme.grey,
                                          //fontFamily: 'Iransans',
                                          fontSize: 12,
                                        ),
                                      ),
                                      Spacer(),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          EnArConvertor()
                                              .replaceArNumber(wasteCartItems
                                                  .length
                                                  .toString())
                                              .toString(),
                                          style: TextStyle(
                                            color: AppTheme.h1,
                                            //fontFamily: 'Iransans',
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.asset(
                                          'assets/images/waste_cart_price_ic.png',
                                          height: deviceWidth * 0.06,
                                          width: deviceWidth * 0.06,
                                          color: Colors.yellow,
                                        ),
                                      ),
                                      Text(
                                        'Total Price',
                                        style: TextStyle(
                                          color: AppTheme.grey,
                                          //fontFamily: 'Iransans',
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '(\$)',
                                        style: TextStyle(
                                          color: AppTheme.grey,
                                          //fontFamily: 'Iransans',
                                          fontSize: 12,
                                        ),
                                      ),
                                      Spacer(),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          totalPrice.toString().isNotEmpty
                                              ? EnArConvertor().replaceArNumber(
                                                  currencyFormat
                                                      .format(totalPrice)
                                                      .toString())
                                              : EnArConvertor()
                                                  .replaceArNumber('0'),
                                          style: TextStyle(
                                            color: AppTheme.h1,
                                            //fontFamily: 'Iransans',
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.asset(
                                          'assets/images/waste_cart_weight_ic.png',
                                          height: deviceWidth * 0.06,
                                          width: deviceWidth * 0.06,
                                        ),
                                      ),
                                      Text(
                                        'Total Weight',
                                        style: TextStyle(
                                          color: AppTheme.grey,
                                          //fontFamily: 'Iransans',
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '(\$)',
                                        style: TextStyle(
                                          color: AppTheme.grey,
                                          //fontFamily: 'Iransans',
                                          fontSize: 12,
                                        ),
                                      ),
                                      Spacer(),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          EnArConvertor()
                                              .replaceArNumber(
                                                  totalWeight.toString())
                                              .toString(),
                                          style: TextStyle(
                                            color: AppTheme.h1,
                                            //fontFamily: 'Iransans',
                                            fontSize: 18,
                                          ),
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
                      Card(
                        color: AppTheme.white,
                        child: Container(
                          width: deviceWidth * 0.9,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            // borderRadius: BorderRadius.circular(5),
                            // border: Border.all(
                            //   color: Colors.grey,
                            //   width: 0.2,
                            // ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.date_range,
                                          size: 30,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Collect Date',
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: AppTheme.grey,
                                            //fontFamily: 'Iransans',
                                            fontSize: 15.0,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: Text(
                                          weekDays[selectedDay.weekday - 1],
                                          style: TextStyle(
                                            color: AppTheme.black,
                                            //fontFamily: 'Iransans',
                                            fontSize: 18.0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Text(
                                        EnArConvertor().replaceArNumber(' ' +
                                            selectedDay.day.toString() +
                                            ' ' +
                                            months[selectedDay.month - 1]),
                                        style: TextStyle(
                                          color: AppTheme.black,
                                          //fontFamily: 'Iransans',
                                          fontSize: 18.0,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.access_time,
                                          size: 30,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Collect hour',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: AppTheme.grey,
                                            //fontFamily: 'Iransans',
                                            fontSize: 15.0,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      Center(
                                        child: Text(
                                          selectedHours,
                                          style: TextStyle(
                                            color: AppTheme.black,
                                            //fontFamily: 'Iransans',
                                            fontSize: 18.0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.location_on,
                                          size: 30,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Region:',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: AppTheme.grey,
                                            //fontFamily: 'Iransans',
                                            fontSize: 15.0,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      Center(
                                        child: Text(
                                          selectedRegion.name,
                                          style: TextStyle(
                                            color: AppTheme.black,
                                            //fontFamily: 'Iransans',
                                            fontSize: 18.0,
                                          ),
                                          textAlign: TextAlign.center,
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
                    onTap: () async {
                      SnackBar addToCartSnackBar = SnackBar(
                        content: Text(
                          'Card is empty',
                          style: TextStyle(
                            color: Colors.white,
                            //fontFamily: 'Iransans',
                            fontSize: 14.0,
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
                        // if (isCompleted) {
                        await createRequest(context);

                        await sendRequest(context, isLogin).then((value) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              NavigationBottomScreen.routeName,
                              (Route<dynamic> route) => false);
                          _showSenddialog();
                        });
                        // } else {
                        //   _showCompletedialog();
                        // }
                      }
                    },
                    child: ButtonBottom(
                      width: deviceWidth * 0.9,
                      height: deviceWidth * 0.14,
                      text: 'Confirm',
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
                                  color:
                                      index.isEven ? Colors.grey : Colors.grey,
                                ),
                              );
                            },
                          )
                        : Container(),
                  ),
                )
              ],
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
