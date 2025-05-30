import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:recycleorigin/core/widgets/buton_bottom.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/main_drawer.dart';
import '../../customer_feature/presentation/providers/authentication_provider.dart';
import '../business/entities/address.dart';
import 'pages/map_screen.dart';
import 'waste_request_date_screen.dart';
import 'widgets/address_item.dart';
import 'widgets/custom_dialog_enter.dart';

class AddressScreen extends StatefulWidget {
  static const routeName = '/address_screen';

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  List<Address> addressList = [];
  bool _isInit = true;

  var _isLoading = true;

  void _showLogindialog() {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialogEnter(
        title: 'Enter',
        buttonText: 'Login Page ',
        description: 'Please login to continue',
        image: Image.asset('assets/images/main_page_request_ic.png'),
      ),
    );
  }

  @override
  void didChangeDependencies() async {
    await getCustomerAddresses();

    super.didChangeDependencies();
  }

  Future<void> getCustomerAddresses() async {
    print(addressList.toString());

    setState(() {
      _isLoading = true;
    });
    await Provider.of<AuthenticationProvider>(context, listen: false)
        .getAddresses();
    addressList = Provider.of<AuthenticationProvider>(context, listen: false)
        .addressItems;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    var currencyFormat = intl.NumberFormat.decimalPattern();
    bool isLogin =
        Provider.of<AuthenticationProvider>(context, listen: false).isAuth;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Address',
          style: TextStyle(
            color: AppTheme.white,
            //fontFamily: 'Iransans',
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
          child: Container(
            height: double.infinity,
            width: double.infinity,
            child: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            color: AppTheme.white,
                            border: Border.all(width: 5, color: AppTheme.bg)),
                        height: deviceWidth * 0.4,
                        child: Builder(
                          builder: (BuildContext context) {
                            return Container(
                              width: deviceWidth,
                              child: FadeInImage(
                                placeholder:
                                    AssetImage('assets/images/circle.gif'),
                                image: AssetImage(
                                    'assets/images/address_page_header.png'),
                                fit: BoxFit.contain,
                              ),
                            );
                          },
                        ),
                      ),
                      addressList.length != 0
                          ? Container(
                              decoration: BoxDecoration(
                                color: AppTheme.bg,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Consumer<AuthenticationProvider>(
                                  builder: (_, products, ch) =>
                                      ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: products.addressItems.length,
                                    itemBuilder: (ctx, i) => InkWell(
                                      onTap: () async {
                                        await Provider.of<
                                                    AuthenticationProvider>(
                                                context,
                                                listen: false)
                                            .selectAddress(
                                                products.addressItems[i]);
                                        setState(() {});
                                      },
                                      child: AddressItem(
                                        addressItem: products.addressItems[i],
                                        isSelected:
                                            Provider.of<AuthenticationProvider>(
                                                            context,
                                                            listen: false)
                                                        .selectedAddress !=
                                                    null
                                                ? products
                                                        .addressItems[i].name ==
                                                    Provider.of<AuthenticationProvider>(
                                                            context,
                                                            listen: false)
                                                        .selectedAddress
                                                        .name
                                                : false,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              height: deviceHeight * 0.45,
                              child: Center(
                                child: Text('Addresses not found'),
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
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: deviceWidth * 0.14,
                          height: deviceWidth * 0.14,
                          child: FloatingActionButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                MapScreen.routeName,
                              );
                            },
                            backgroundColor: AppTheme.primary,
                            child: Icon(
                              Icons.add,
                              color: AppTheme.white,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          SnackBar addToCartSnackBar = SnackBar(
                            content: Text(
                              'Address does not selected',
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
                          if (!isLogin) {
                            _showLogindialog();
                          } else {
                            Navigator.of(context)
                                .pushNamed(WasteRequestDateScreen.routeName);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: ButtonBottom(
                            width: deviceWidth * 0.75,
                            height: deviceWidth * 0.14,
                            text: 'Continue',
                            isActive: Provider.of<AuthenticationProvider>(
                                        context,
                                        listen: false)
                                    .selectedAddress !=
                                null,
                          ),
                        ),
                      ),
                    ],
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
                            : Container()))
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
