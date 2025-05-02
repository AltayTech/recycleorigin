import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/request_waste_item.dart';
import 'package:recycleorigin/features/customer_feature/presentation/providers/authentication_provider.dart';

import '../../core/models/search_detail.dart';
import '../../core/theme/app_theme.dart';
import 'presentation/providers/wastes.dart';
import '../collect_feature/presentation/widgets/collect_item_collect_screen.dart';
import '../../core/logic/en_to_ar_number_convertor.dart';
import '../../core/widgets/main_drawer.dart';
import '../customer_feature/presentation/screens/login_screen.dart';

/// Collect List Screen
///
/// This screen is used to show the list of all waste collect requests.
///
/// It loads the list of requests from the server and shows them in a list view.
/// The user can filter the requests by date and waste type.
/// The user can also sort the requests by newest, highest price, lowest price.
///
/// The screen is divided into two parts. The first part shows the list of requests
/// and the second part shows the details of the selected request.
///
/// The screen also has a drawer that contains the menu items to navigate to other
/// screens.
class CollectListScreen extends StatefulWidget {
  static const routeName = '/collectListScreen';

  @override
  _CollectListScreenState createState() => _CollectListScreenState();
}

/// The state of the Collect List Screen
///
/// It contains the logic to load the list of requests, filter and sort them.
class _CollectListScreenState extends State<CollectListScreen>
    with SingleTickerProviderStateMixin {
  /// The scroll controller of the list view
  ScrollController _scrollController = new ScrollController();

  /// The flag to indicate if the screen is loading
  var _isLoading;

  /// The key of the scaffold
  var scaffoldKey;

  /// The page number of the list
  int page = 1;

  /// The search detail object
  SearchDetail productsDetail = SearchDetail();

  /// The sort value
  var sortValue = 'Newest';

  /// The list of sort values
  List<String> sortValueList = ['Newest', 'Highest Price', 'Lowest Price'];

  /// The list of loaded products
  List<RequestWasteItem> loadedProducts = [];

  /// The list of loaded products to list
  List<RequestWasteItem> loadedProductstolist = [];

  /// The function to submit the search
  Future<void> _submit() async {
    loadedProducts.clear();
    loadedProducts =
        await Provider.of<Wastes>(context, listen: false).CollectItems;
    loadedProductstolist.addAll(loadedProducts);
  }

  /// The function to filter the items
  Future<void> filterItems() async {
    loadedProductstolist.clear();
    await searchItems();
  }

  /// The function to search the items
  Future<void> searchItems() async {
    setState(() {
      _isLoading = true;
    });

    Provider.of<Wastes>(context, listen: false).searchBuilder();
    await Provider.of<Wastes>(context, listen: false).searchCollectItems();
    productsDetail = Provider.of<Wastes>(context, listen: false).searchDetails;
    _submit();

    setState(() {
      _isLoading = false;
    });
  }

  /// The function to change the category
  Future<void> changeCat(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    print(_isLoading.toString());

    Provider.of<Wastes>(context, listen: false).sPage = 1;

    Provider.of<Wastes>(context, listen: false).searchBuilder();

    loadedProductstolist.clear();

    await searchItems();

    setState(() {
      _isLoading = false;
      print(_isLoading.toString());
    });
  }

  /// The build method of the screen
  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    bool isLogin = Provider.of<AuthenticationProvider>(context).isAuth;

    var currencyFormat = intl.NumberFormat.decimalPattern();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Color(0xffF9F9F9),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Request List',
          style: TextStyle(
            fontFamily: 'Iransans',
          ),
        ),
        backgroundColor: AppTheme.appBarColor,
        iconTheme: new IconThemeData(color: AppTheme.appBarIconColor),
        elevation: 0,
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: SingleChildScrollView(
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
                          child: Text('You are not Login'),
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
              : Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: deviceHeight * 0.0,
                      horizontal: deviceWidth * 0.03),
                  child: Stack(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: deviceWidth * 0.25,
                              child: Builder(
                                builder: (BuildContext context) {
                                  return Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Container(
                                      width: deviceWidth,
                                      child: FadeInImage(
                                        placeholder: AssetImage(
                                            'assets/images/circle.gif'),
                                        image: AssetImage(
                                            'assets/images/collect_list_header.png'),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Spacer(),
                                    Consumer<Wastes>(builder: (_, Wastes, ch) {
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
                                                          right: 4.0, left: 6),
                                                  child: Text(
                                                    productsDetail != null
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
                                                    'From',
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
                                                          right: 4.0, left: 6),
                                                  child: Text(
                                                    productsDetail != null
                                                        ? EnArConvertor()
                                                            .replaceArNumber(
                                                                productsDetail
                                                                    .total
                                                                    .toString()
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
                                              ]),
                                        ),
                                      );
                                    }),
                                  ],
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
                                      child: CollectItemCollectsScreen(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
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
                                            'No Request',
                                            style: TextStyle(
                                              fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 14.0,
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ),
                        ),
                      ),
                    ],
                  ),
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