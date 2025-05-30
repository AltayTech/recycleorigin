import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import '../../../../core/logic/en_to_ar_number_convertor.dart';
import '../../../../core/models/category.dart';
import '../../../../core/models/search_detail.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/main_drawer.dart';
import '../../business/entities/product.dart';
import '../providers/Products.dart';
import '../widgets/product_item_product_screeen.dart';
import 'cart_screen.dart';

/// This file defines the `ProductsScreen` widget, which displays a list of products with filtering and sorting options.
///
/// The screen includes the following key components:
///
/// - **AppBar**: Displays the title "Products" with a shopping cart icon showing the number of items in the cart.
/// - **Category Filter**: Allows users to filter products by category using a horizontal scrollable list.
/// - **Sort Dropdown**: Provides sorting options such as "Newest", "High Price", and "Low Price".
/// - **Product List**: A scrollable list of products displayed using the `ProductItemProductScreen` widget.
/// - **Loading Indicator**: Displays a spinner while data is being fetched or processed.
/// - **Empty State**: Shows a message when no products are available.
///
/// Key Features:
/// - Fetches product data and categories using the `Products` provider.
/// - Implements infinite scrolling to load more products as the user scrolls down.
/// - Dynamically updates the UI based on selected filters and sorting options.
/// - Supports RTL layout for localization.
///
/// Dependencies:
/// - `AppTheme`: Provides theme colors and styles.
/// - `EnArConvertor`: Converts numbers and text between English and Arabic.
/// - `Products`: Supplies product data and manages filtering and sorting.
/// - `SpinKitFadingCircle`: A loading spinner widget.
/// - `ProductItemProductScreen`: A custom widget for displaying individual product details.
/// - `MainDrawer`: A custom navigation drawer widget.
///
/// Navigation:
/// - Navigates to `CartScreen` when the shopping cart icon is tapped.
///
/// Note:
/// - Ensure that the `Products` provider is properly configured to fetch product data and categories.
/// - Handle cases where no products or categories are available gracefully.
/// - The `AppTheme` and `EnArConvertor` should be implemented to match the app's design and localization requirements.
class ProductsScreen extends StatefulWidget {
  static const routeName = '/productsScreen';

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with SingleTickerProviderStateMixin {
  bool _isInit = true;

  ScrollController _scrollController = new ScrollController();

  var _isLoading;

  var scaffoldKey;
  int page = 1;

  SearchDetail productsDetail = SearchDetail();

  var sortValue = 'Newest';
  List<String> sortValueList = ['Newest', 'High Price', 'Low Price'];

  List<int> _selectedCategoryIndexs = [];
  int _selectedCategoryId = 0;
  List<String> _selectedCategoryTitle = [];

  List<Category> categoryList = [];

  @override
  void initState() {
    Provider.of<Products>(context, listen: false).sPage = 1;

    Provider.of<Products>(context, listen: false).searchBuilder();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (page < productsDetail.max_page) {
          page = page + 1;
          Provider.of<Products>(context, listen: false).sPage = page;

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
      Provider.of<Products>(context, listen: false).retrieveCategory();

      categoryList =
          Provider.of<Products>(context, listen: false).categoryItems;
      print(_isLoading.toString());

      Provider.of<Products>(context, listen: false).searchBuilder();
      print(_isLoading.toString());

      searchItems();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  List<Product> loadedProducts = [];
  List<Product> loadedProductstolist = [];

  Future<void> _submit() async {
    loadedProducts.clear();
    loadedProducts = await Provider.of<Products>(context, listen: false).items;
    loadedProductstolist.addAll(loadedProducts);
  }

  Future<void> filterItems() async {
    loadedProductstolist.clear();
    await searchItems();
  }

  Future<void> searchItems() async {
    setState(() {
      _isLoading = true;
    });
    print(_isLoading.toString());

    Provider.of<Products>(context, listen: false).searchBuilder();
    await Provider.of<Products>(context, listen: false).searchItem();
    productsDetail =
        Provider.of<Products>(context, listen: false).searchDetails;

    _submit();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> changeCat(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    print(_isLoading.toString());

    Provider.of<Products>(context, listen: false).sPage = 1;

    Provider.of<Products>(context, listen: false).searchBuilder();

    String categoriesEndpoint =
        _selectedCategoryId != 0 ? '$_selectedCategoryId' : '';
    Provider.of<Products>(context, listen: false).sCategory =
        categoriesEndpoint;

    Provider.of<Products>(context, listen: false).searchBuilder();
    loadedProductstolist.clear();

    await searchItems();

    setState(() {
      _isLoading = false;
      print(_isLoading.toString());
    });
  }

  String endPointBuilder(List<dynamic> input) {
    String outPutString = '';
    for (int i = 0; i < input.length; i++) {
      i == 0
          ? outPutString = input[i].toString()
          : outPutString = outPutString + ',' + input[i].toString();
    }
    return outPutString;
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    var currencyFormat = intl.NumberFormat.decimalPattern();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Color(0xffF9F9F9),
      appBar: AppBar(
        title: Text(
          'Products',
          style: TextStyle(
            //fontFamily: 'Iransans',
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.appBarColor,
        iconTheme: new IconThemeData(color: AppTheme.appBarIconColor),
        elevation: 0,
        centerTitle: true,
        actions: <Widget>[
          Consumer<Products>(
            builder: (_, products, ch) {
              if (products.cartItemsCount != 0) {
                return badges.Badge(
                  badgeContent: ch,
                  badgeStyle: badges.BadgeStyle(
                    badgeColor: Color(0xff06623B),
                  ),
                  child: Text(products.cartItemsCount.toString()),
                );
              } else {
                return ch!;
              }
            },
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
              color: AppTheme.bg,
              icon: Icon(
                Icons.shopping_cart,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  color: AppTheme.white,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                    child: Container(
                      height: deviceHeight * 0.05,
                      width: deviceWidth,
                      child: Row(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              _selectedCategoryIndexs.clear();
                              _selectedCategoryTitle.clear();

                              _selectedCategoryIndexs.add(-1);
                              _selectedCategoryId = 0;
                              _selectedCategoryTitle.add('All');

                              changeCat(context);

                              Provider.of<Products>(context, listen: false)
                                  .checkFiltered();
                            },
                            child: Container(
                              decoration: _selectedCategoryId == 0
                                  ? BoxDecoration(
                                      color: AppTheme.bg,
                                      border: Border(
                                        bottom: BorderSide(
                                            color: AppTheme.primary, width: 3),
                                      ),
                                    )
                                  : BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: Center(
                                  child: Text(
                                    'All',
                                    style: TextStyle(
                                      color: _selectedCategoryId == 0
                                          ? AppTheme.primary
                                          : AppTheme.h1,
                                      //fontFamily: 'Iransans',
                                      fontSize: textScaleFactor * 14.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: categoryList.length,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  child: InkWell(
                                    onTap: () {
                                      _selectedCategoryIndexs.clear();
                                      _selectedCategoryTitle.clear();

                                      _selectedCategoryIndexs.add(index);
                                      _selectedCategoryId =
                                          categoryList[index].term_id;
                                      _selectedCategoryTitle
                                          .add(categoryList[index].name);

                                      changeCat(context);
                                    },
                                    child: Container(
                                      decoration: _selectedCategoryIndexs
                                              .contains(index)
                                          ? BoxDecoration(
                                              color: AppTheme.bg,
                                              border: Border(
                                                bottom: BorderSide(
                                                    color: AppTheme.primary,
                                                    width: 3),
                                              ),
                                            )
                                          : BoxDecoration(
                                              color: Colors.transparent,
                                            ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: Center(
                                          child: Text(
                                            categoryList[index].name != null
                                                ? categoryList[index].name
                                                : 'n',
                                            style: TextStyle(
                                              color:
                                                  categoryList[index].term_id ==
                                                          _selectedCategoryId
                                                      ? AppTheme.primary
                                                      : AppTheme.h1,
                                              //fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 14.0,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(
                                alignment: Alignment.centerRight,
                                decoration: BoxDecoration(
                                    color: AppTheme.white,
                                    border: Border.all(
                                        color: AppTheme.h1, width: 0.2)),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 8.0, left: 8, top: 6),
                                  child: DropdownButton<String>(
                                    value: sortValue,
                                    icon: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10.0),
                                      child: Icon(
                                        Icons.arrow_drop_down,
                                        color: AppTheme.black,
                                        size: 20,
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: AppTheme.black,
                                      //fontFamily: 'Iransans',
                                      fontSize: textScaleFactor * 13.0,
                                    ),
                                    isDense: true,
                                    onChanged: (newValue) {
                                      setState(() {
                                        sortValue = newValue!;

                                        if (sortValue == 'High Price') {
                                          Provider.of<Products>(context,
                                                  listen: false)
                                              .sOrder = 'desc';
                                          Provider.of<Products>(context,
                                                  listen: false)
                                              .sOrderBy = 'price';
                                          page = 1;
                                          Provider.of<Products>(context,
                                                  listen: false)
                                              .sPage = page;
                                          loadedProductstolist.clear();

                                          searchItems();
                                        } else if (sortValue == 'Low Price') {
                                          Provider.of<Products>(context,
                                                  listen: false)
                                              .sOrder = 'asc';
                                          Provider.of<Products>(context,
                                                  listen: false)
                                              .sOrderBy = 'price';

                                          page = 1;
                                          Provider.of<Products>(context,
                                                  listen: false)
                                              .sPage = page;
                                          loadedProductstolist.clear();

                                          searchItems();
                                        } else {
                                          Provider.of<Products>(context,
                                                  listen: false)
                                              .sOrder = 'desc';
                                          Provider.of<Products>(context,
                                                  listen: false)
                                              .sOrderBy = 'date';
                                          page = 1;
                                          Provider.of<Products>(context,
                                                  listen: false)
                                              .sPage = page;
                                          loadedProductstolist.clear();

                                          searchItems();
                                        }
                                      });
                                    },
                                    items: sortValueList
                                        .map<DropdownMenuItem<String>>(
                                      (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 3.0),
                                            child: Text(
                                              value,
                                              style: TextStyle(
                                                color: AppTheme.black,
                                                //fontFamily: 'Iransans',
                                                fontSize:
                                                    textScaleFactor * 13.0,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          Consumer<Products>(builder: (_, products, ch) {
                            return Container(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: deviceHeight * 0.0,
                                    horizontal: 3),
                                child: Wrap(
                                  alignment: WrapAlignment.start,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  direction: Axis.horizontal,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 3, vertical: 5),
                                      child: Text(
                                        'Number:',
                                        style: TextStyle(
                                          //fontFamily: 'Iransans',
                                          fontSize: textScaleFactor * 12.0,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 4.0, left: 6),
                                      child: Text(
                                        productsDetail.total != -1
                                            ? EnArConvertor().replaceArNumber(
                                                loadedProductstolist.length
                                                    .toString())
                                            : EnArConvertor()
                                                .replaceArNumber('0'),
                                        style: TextStyle(
                                          //fontFamily: 'Iransans',
                                          fontSize: textScaleFactor * 13.0,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 3, vertical: 5),
                                      child: Text(
                                        'From',
                                        style: TextStyle(
                                          //fontFamily: 'Iransans',
                                          fontSize: textScaleFactor * 12.0,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 4.0, left: 6),
                                      child: Text(
                                        productsDetail.total != -1
                                            ? EnArConvertor().replaceArNumber(
                                                productsDetail.total.toString())
                                            : EnArConvertor()
                                                .replaceArNumber('0'),
                                        style: TextStyle(
                                          //fontFamily: 'Iransans',
                                          fontSize: textScaleFactor * 13.0,
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
                      Container(
                        width: double.infinity,
                        height: deviceHeight * 0.70,
                        child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.vertical,
                          itemCount: loadedProductstolist.length,
                          itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                            value: loadedProductstolist[i],
                            child: ProductItemProductScreen(),
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
                        : Container(
                            child: loadedProductstolist.isEmpty
                                ? Center(
                                    child: Text(
                                    'No Product',
                                    style: TextStyle(
                                      //fontFamily: 'Iransans',
                                      fontSize: textScaleFactor * 15.0,
                                    ),
                                  ))
                                : Container())))
          ],
        ),
      ),
      //            ),
      //            Positioned(
      //              top: 0,
      //              left: 0,
      //              right: 0,
      //              child: AnimatedContainer(
      //                duration: _controller.duration,
      //                curve: Curves.easeIn,
      //                child: ScaleTransition(
      //                  scale: _opacityAnimation,
      //                  child: FadeTransition(
      //                    opacity: _opacityAnimation,
      //                    child: SlideTransition(
      //                      position: _slideAnimation,
      //                      child: Padding(
      //                        padding: const EdgeInsets.only(bottom: 15.0),
      //                        child: Center(
      //                          child: Padding(
      //                            padding: const EdgeInsets.all(8.0),
      //                            child: Container(
      //                              width: MediaQuery.of(context).size.width * 0.9,
      //                              height: AppBar().preferredSize.height,
      //                              decoration: BoxDecoration(
      //                                color: Colors.white,
      //                                borderRadius: BorderRadius.circular(8),
      //                                border: Border.all(
      //                                  color: AppTheme.secondary,
      //                                  width: 0.6,
      //                                ),
      //                              ),
      //                              child: Row(
      //                                children: <Widget>[
      //                                  Padding(
      //                                    padding: const EdgeInsets.all(8.0),
      //                                    child: InkWell(
      //                                      onTap: () {
      //                                        String brandsEndpoint = '';
      //                                        String colorsEndpoint = '';
      //                                        String sellcaseEndpoint = '';
      //                                        String priceRange = '';
      //                                        Provider.of<Products>(context,
      //                                            listen: false)
      //                                            .filterTitle
      //                                            .clear();
      //
      //                                        Provider.of<Products>(context,
      //                                            listen: false)
      //                                            .searchKey =
      //                                            searchTextController.text;
      //
      //                                        Provider.of<Products>(context,
      //                                            listen: false)
      //                                            .sBrand = brandsEndpoint;
      //                                        Provider.of<Products>(context,
      //                                            listen: false)
      //                                            .sColor = colorsEndpoint;
      //                                        Provider.of<Products>(context,
      //                                            listen: false)
      //                                            .sPriceRange = priceRange;
      //                                        Provider.of<Products>(context,
      //                                            listen: false)
      //                                            .sPage = 1;
      //                                        Provider.of<Products>(context,
      //                                            listen: false)
      //                                            .sSellCase = sellcaseEndpoint;
      //                                        Provider.of<Products>(context,
      //                                            listen: false)
      //                                            .searchBuilder();
      //                                        Provider.of<Products>(context,
      //                                            listen: false)
      //                                            .checkFiltered();
      //
      //                                        Provider.of<Products>(context,
      //                                            listen: false)
      //                                            .searchBuilder();
      //                                        Provider.of<Products>(context,
      //                                            listen: false)
      //                                            .checkFiltered();
      //                                        Navigator.of(context).pushReplacementNamed(
      //                                            ProductsScreen.routeName,
      //                                            arguments: 0);
      //                                      },
      //                                      child: Icon(
      //                                        Icons.search,
      //                                        color: AppTheme.primary,
      //                                      ),
      //                                    ),
      //                                  ),
      //                                  Expanded(
      //                                    child: TextFormField(
      //                                      textInputAction: TextInputAction.search,
      //                                      onFieldSubmitted: (_) {
      //                                        Provider.of<Products>(context,
      //                                            listen: false)
      //                                            .searchKey =
      //                                            searchTextController.text;
      //                                        Provider.of<Products>(context,
      //                                            listen: false)
      //                                            .searchBuilder();
      //
      //                                        return Navigator.of(context).pushNamed(
      //                                            ProductsScreen.routeName,
      //                                            arguments: 0);
      //                                      },
      //                                      controller: searchTextController,
      //                                      decoration: InputDecoration(
      //                                        border: InputBorder.none,
      //                                        hintStyle: TextStyle(
      //                                          color: AppTheme.secondary,
      //                                          //fontFamily: 'Iransans',
      //                                          fontSize: MediaQuery.of(context)
      //                                              .textScaleFactor *
      //                                              12.0,
      //                                        ),
      //                                        hintText: 'جستجوی محصولات ...',
      //                                        labelStyle: TextStyle(
      //                                          color: AppTheme.secondary,
      //                                          //fontFamily: 'Iransans',
      //                                          fontSize: MediaQuery.of(context)
      //                                              .textScaleFactor *
      //                                              10.0,
      //                                        ),
      //                                      ),
      //                                    ),
      //                                  ),
      //                                  Padding(
      //                                    padding: const EdgeInsets.all(8.0),
      //                                    child: InkWell(
      //                                        onTap: () {
      //                                          _controller.reverse();
      //                                          setState(() {});
      //                                        },
      //                                        child: Icon(Icons.clear)),
      //                                  ),
      //                                ],
      //                              ),
      //                            ),
      //                          ),
      //                        ),
      //                      ),
      //                    ),
      //                  ),
      //                ),
      //              ),
      //            ),
      //          ],
      //        ),
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
