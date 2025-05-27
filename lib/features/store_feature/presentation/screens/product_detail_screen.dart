import 'package:badges/badges.dart' as badges;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:recycleorigin/core/widgets/buton_bottom.dart';

import '../../../../core/logic/en_to_ar_number_convertor.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/main_drawer.dart';
import '../../business/entities/product.dart';
import '../providers/Products.dart';
import 'cart_screen.dart';

/// This file defines the `ProductDetailScreen` widget, which displays detailed information about a specific product.
///
/// The screen includes the following key components:
///
/// - **AppBar**: Displays a back button and a shopping cart icon with a badge showing the number of items in the cart.
/// - **Product Gallery**: A carousel slider showcasing the product's images.
/// - **Product Details**: Displays the product name, price (with or without discount), and description.
/// - **Add to Cart Button**: Allows the user to add the product to the shopping cart, with validation for price and cart existence.
/// - **Loading Indicator**: Displays a spinner while data is being fetched or actions are being processed.
///
/// Key Features:
/// - Fetches product details using the `Products` provider.
/// - Handles adding the product to the shopping cart with appropriate feedback messages.
/// - Dynamically updates the UI based on the product's price and cart status.
/// - Supports RTL layout for localization.
///
/// Dependencies:
/// - `AppTheme`: Provides theme colors and styles.
/// - `EnArConvertor`: Converts numbers and text between English and Arabic.
/// - `Products`: Supplies product details and manages cart actions.
/// - `SpinKitFadingCircle`: A loading spinner widget.
/// - `ButtonBottom`: A custom button widget.
/// - `MainDrawer`: A custom navigation drawer widget.
/// - `CarouselSlider`: Displays the product's image gallery.
///
/// Navigation:
/// - Navigates to `CartScreen` when the shopping cart icon is tapped.
///
/// Note:
/// - Ensure that the `Products` provider is properly configured to fetch product details and manage cart actions.
/// - The `AppTheme` and `EnArConvertor` should be implemented to match the app's design and localization requirements.
/// - Handle cases where the product ID is invalid or missing gracefully to avoid runtime errors.
class ProductDetailScreen extends StatefulWidget {
  static const routeName = '/productDetailScreen';

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _current = 0;
  var _isLoading;

  bool _isInit = true;

  late Product loadedProduct;
  String _snackBarMessage = '';

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      await searchItems();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> searchItems() async {
    setState(() {
      _isLoading = true;
    });
    final productId = ModalRoute.of(context)?.settings.arguments as int;
    await Provider.of<Products>(context, listen: false).retrieveItem(productId);
    loadedProduct = Provider.of<Products>(context, listen: false).findById();

    setState(() {
      _isLoading = false;
    });
    print(_isLoading.toString());
  }

  Future<void> addToShoppingCart(
      Product loadedProduct, var _selectedColor) async {
    setState(() {
      _isLoading = true;
    });

    await Provider.of<Products>(context, listen: false)
        .addShopCart(loadedProduct, _selectedColor, 1);

    setState(() {
      _isLoading = false;
    });
    print(_isLoading.toString());
  }

  Future<bool> isExistInCart(
    Product loadedProduct,
  ) async {
    bool isExist = false;
    setState(() {
      _isLoading = true;
    });
    isExist = Provider.of<Products>(context, listen: false)
        .cartItems
        .any((prod) => prod.id == loadedProduct.id);

    print(isExist.toString());

    setState(() {
      _isLoading = false;
    });
    return isExist;
  }

  Widget? priceWidget(BuildContext context) {
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    var currencyFormat = intl.NumberFormat.decimalPattern();

    if (loadedProduct.price_without_discount == loadedProduct.price) {
      return Text(
        loadedProduct.price_without_discount.isNotEmpty
            ? EnArConvertor().replaceArNumber(currencyFormat
                .format(double.parse(loadedProduct.price_without_discount))
                .toString())
            : EnArConvertor().replaceArNumber('0'),
        style: TextStyle(
          color: AppTheme.black,
          //fontFamily: 'Iransans',
          fontWeight: FontWeight.bold,
          fontSize: textScaleFactor * 20,
        ),
        textAlign: TextAlign.center,
      );
    } else if (loadedProduct.price_without_discount == '0' ||
        loadedProduct.price_without_discount.isEmpty) {
      return Text(
        loadedProduct.price.isNotEmpty
            ? EnArConvertor().replaceArNumber(currencyFormat
                .format(double.parse(loadedProduct.price))
                .toString())
            : EnArConvertor().replaceArNumber('0'),
        style: TextStyle(
          color: AppTheme.black,
          //fontFamily: 'Iransans',
          fontWeight: FontWeight.bold,
          fontSize: textScaleFactor * 20,
        ),
      );
    } else if (loadedProduct.price == '0' || loadedProduct.price.isEmpty) {
      return Text(
        loadedProduct.price_without_discount.isNotEmpty
            ? EnArConvertor().replaceArNumber(currencyFormat
                .format(double.parse(loadedProduct.price_without_discount))
                .toString())
            : EnArConvertor().replaceArNumber('0'),
        style: TextStyle(
          color: AppTheme.black,
          //fontFamily: 'Iransans',
          fontWeight: FontWeight.bold,
          fontSize: textScaleFactor * 20,
        ),
      );
    } else {
      return Wrap(
        direction: Axis.vertical,
        children: <Widget>[
          Text(
            loadedProduct.price_without_discount.isNotEmpty
                ? EnArConvertor().replaceArNumber(currencyFormat
                    .format(double.parse(loadedProduct.price_without_discount))
                    .toString())
                : EnArConvertor().replaceArNumber('0'),
            style: TextStyle(
              decoration: TextDecoration.lineThrough,
              decorationThickness: 2,
              color: AppTheme.grey,
              //fontFamily: 'Iransans',
              fontSize: textScaleFactor * 16,
            ),
          ),
          Text(
            loadedProduct.price.isNotEmpty
                ? EnArConvertor().replaceArNumber(currencyFormat
                    .format(double.parse(loadedProduct.price))
                    .toString())
                : EnArConvertor().replaceArNumber('0'),
            style: TextStyle(
              color: AppTheme.black,
              //fontFamily: 'Iransans',
              fontWeight: FontWeight.bold,
              fontSize: textScaleFactor * 20,
            ),
          ),
        ],
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    var currencyFormat = intl.NumberFormat.decimalPattern();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.white,
        appBar: AppBar(
          title: Text(
            '',
            style: TextStyle(
              //fontFamily: 'Iransans',
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
        body: Stack(
          children: <Widget>[
            Directionality(
              textDirection: TextDirection.ltr,
              child: Align(
                alignment: Alignment.center,
                child: _isLoading
                    ? SpinKitFadingCircle(
                        itemBuilder: (BuildContext context, int index) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index.isEven ? Colors.grey : Colors.grey,
                            ),
                          );
                        },
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            height: deviceHeight * 0.4,
                            decoration: BoxDecoration(
                                color: AppTheme.white,
                                borderRadius: BorderRadius.circular(5)),
                            child: Stack(
                              children: [
                                CarouselSlider(
                                  options: CarouselOptions(
                                    aspectRatio: 1,
                                    viewportFraction: 1.0,
                                    initialPage: 0,
                                    enableInfiniteScroll: false,
                                    reverse: false,
                                    autoPlay: false,
                                    height: deviceHeight * 0.7,
                                    autoPlayInterval: Duration(seconds: 3),
                                    autoPlayAnimationDuration:
                                        Duration(milliseconds: 800),
                                    enlargeCenterPage: true,
                                    scrollDirection: Axis.horizontal,
                                    onPageChanged: (index, _) {
                                      _current = index;
                                      setState(() {});
                                    },
                                  ),
                                  items: loadedProduct.gallery.map((gallery) {
                                    return Builder(
                                      builder: (BuildContext context) {
                                        return Center(
                                          child: Container(
                                              width: deviceWidth,
                                              height: deviceHeight * 0.7,
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 5.0),
                                              child: FadeInImage(
                                                placeholder: AssetImage(
                                                    'assets/images/circle.gif'),
                                                image: NetworkImage(
                                                    gallery.sizes.medium),
                                                fit: BoxFit.contain,
                                              )),
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0.0,
                                  right: 0.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: loadedProduct.gallery.map<Widget>(
                                      (index) {
                                        return Container(
                                          width: 10.0,
                                          height: 10.0,
                                          margin: EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 2.0),
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: AppTheme.h1,
                                                  width: 0.4),
                                              color: _current ==
                                                      loadedProduct.gallery
                                                          .indexOf(index)
                                                  ? AppTheme.secondary
                                                  : AppTheme.bg),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            color: AppTheme.white,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      loadedProduct.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        height: 2,
                                        color: AppTheme.black,
                                        //fontFamily: 'Iransans',
                                        fontSize: textScaleFactor * 18,
                                      ),
                                      textAlign: TextAlign.right,
                                      textDirection: TextDirection.rtl,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(
                                              bottom: textScaleFactor * 15.0),
                                          child: Text(
                                            '\$',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.grey,
                                              //fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 15.0,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: priceWidget(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: HtmlWidget(
                                      loadedProduct.description,
                                      onTapUrl: (url) async {
                                        return await showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: Text('onTapUrl'),
                                            content: Text(url),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
              ),
            ),
            Positioned(
                bottom: 15,
                left: 15,
                right: 15,
                child: Builder(
                  builder: (BuildContext context) {
                    return InkWell(
                      onTap: () async {
                        bool isExist = await isExistInCart(loadedProduct);
                        setState(() {});
                        if (loadedProduct.price.isEmpty) {
                          _snackBarMessage = 'The Price is 0';
                          SnackBar addToCartSnackBar = SnackBar(
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
                        } else if (isExist) {
                          _snackBarMessage =
                              'This product exist in the Shopping Card';
                          SnackBar addToCartSnackBar = SnackBar(
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
                          await addToShoppingCart(loadedProduct, null);

                          _snackBarMessage = 'Added to Shopping Card';
                          SnackBar addToCartSnackBar = SnackBar(
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
                        }
                      },
                      child: ButtonBottom(
                        width: deviceWidth * 0.9,
                        height: deviceWidth * 0.14,
                        text: 'Add to Shopping Card',
                        isActive: true,
                      ),
                    );
                  },
                )),
          ],
        ),
        drawer: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.transparent,
          ),
          child: MainDrawer(),
        ),
      ),
    );
  }
}
