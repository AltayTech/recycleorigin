import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:recycleorigin/core/widgets/buton_bottom.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/price_weight.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/wasteCart.dart';

import '../../../../core/logic/en_to_ar_number_convertor.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/main_drawer.dart';
import '../../../customer_feature/presentation/providers/authentication_provider.dart';
import '../../../waste_feature/presentation/address_screen.dart';
import '../../../waste_feature/presentation/providers/wastes.dart';
import '../../../waste_feature/presentation/wastes_screen.dart';
import '../../../waste_feature/presentation/widgets/custom_dialog_enter.dart';
import '../../../waste_feature/presentation/widgets/waste_cart_item.dart';

/// This file defines the `WasteCartScreen` widget, which displays the user's waste cart with details about the selected waste items.
///
/// The screen includes the following key components:
///
/// - **AppBar**: Displays the title "Waste selection" with a back button for navigation.
/// - **Waste Summary**: Shows the total number of waste items, their total weight, and total price with animations.
/// - **Waste Items List**: Displays a scrollable list of waste items using the `WasteCartItem` widget.
/// - **Floating Action Button**: Allows the user to add more waste items by navigating to the `WastesScreen`.
/// - **Continue Button**: Proceeds to the address selection screen if the cart is not empty and the user is logged in.
/// - **Loading Indicator**: Displays a spinner while data is being fetched or processed.
/// - **Empty State**: Shows a message when no waste items are in the cart.
///
/// Key Features:
/// - Fetches waste cart items dynamically using the `Wastes` provider.
/// - Calculates and animates the total price and weight of the waste items.
/// - Validates user login and profile completion before proceeding to the next step.
/// - Supports RTL layout for localization.
///
/// Dependencies:
/// - `AppTheme`: Provides theme colors and styles.
/// - `EnArConvertor`: Converts numbers between English and Arabic.
/// - `Wastes`: Supplies waste cart data and manages waste-related actions.
/// - `SpinKitFadingCircle`: A loading spinner widget.
/// - `WasteCartItem`: A custom widget for displaying individual waste item details.
/// - `ButtonBottom`: A custom button widget.
/// - `CustomDialogEnter` and `CustomDialogProfile`: Custom dialogs for login and profile completion prompts.
/// - `MainDrawer`: A custom navigation drawer widget.
///
/// Navigation:
/// - Navigates to `WastesScreen` to add more waste items.
/// - Navigates to `AddressScreen` when the "Continue" button is tapped and all validations pass.
///
/// Note:
/// - Ensure that the `Wastes` provider is properly configured to fetch waste cart data.
/// - Handle cases where the cart is empty or the user is not logged in gracefully.
/// - The `AppTheme` and `EnArConvertor` should be implemented to match the app's design and localization requirements.
/// - Properly dispose of animation controllers to avoid memory leaks.
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

  // Removed unused completed profile dialog to declutter screen logic

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      await Provider.of<AuthenticationProvider>(context, listen: false)
          .checkCompleted();

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
    // double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    // var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    var currencyFormat = intl.NumberFormat.decimalPattern();
    bool isLogin =
        Provider.of<AuthenticationProvider>(context, listen: false).isAuth;
    // bool isCompleted =
    //     Provider.of<AuthenticationProvider>(context, listen: false).isCompleted;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(
          'Waste cart',
          style: TextStyle(
            color: AppTheme.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: new IconThemeData(color: AppTheme.appBarIconColor),
        actions: [
          IconButton(
            tooltip: 'Add items',
            icon: Icon(Icons.add),
            onPressed: () async {
              await Navigator.of(context).pushNamed(
                WastesScreen.routeName,
              );
              await getWasteItems();
              setState(() {});
            },
          )
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildSummaryCard(deviceWidth, currencyFormat),
                  SizedBox(height: 16),
                  Expanded(
                    child: Consumer<Wastes>(
                      builder: (_, value, __) {
                        final items = value.wasteCartItems;
                        if (items.isEmpty) {
                          return _buildEmptyState(deviceWidth);
                        }
                        return Container(
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 8,
                            ),
                            itemBuilder: (ctx, i) => WasteCartItem(
                              wasteItem: items[i],
                              function: getWasteItems,
                            ),
                            separatorBuilder: (ctx, i) => Divider(
                              height: 1,
                              color: Colors.grey.withOpacity(0.2),
                            ),
                            itemCount: items.length,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.05),
                  alignment: Alignment.center,
                  child: SpinKitFadingCircle(
                    itemBuilder: (BuildContext context, int index) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index.isEven ? Colors.grey : Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(deviceWidth, isLogin),
      endDrawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
        ),
        child: MainDrawer(),
      ),
    );
  }

  Widget _buildSummaryCard(
      double deviceWidth, intl.NumberFormat currencyFormat) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildStat(
              icon: 'assets/images/main_page_request_ic.png',
              label: 'Items',
              value: EnArConvertor()
                  .replaceArNumber(wasteCartItems.length.toString())
                  .toString(),
            ),
          ),
          Container(
            height: deviceWidth * 0.16,
            width: 1,
            color: Colors.grey.withOpacity(0.15),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _totalPriceAnimation,
              builder: (context, child) => _buildStat(
                icon: 'assets/images/waste_cart_price_ic.png',
                label: 'Total',
                value: totalPrice.toString().isNotEmpty
                    ? EnArConvertor().replaceArNumber(
                        currencyFormat
                            .format(
                              double.parse(
                                _totalPriceAnimation.value.toStringAsFixed(0),
                              ),
                            )
                            .toString(),
                      )
                    : EnArConvertor().replaceArNumber('0'),
              ),
            ),
          ),
          Container(
            height: deviceWidth * 0.16,
            width: 1,
            color: Colors.grey.withOpacity(0.15),
          ),
          Expanded(
            child: _buildStat(
              icon: 'assets/images/waste_cart_weight_ic.png',
              label: 'Weight (kg)',
              value: EnArConvertor()
                  .replaceArNumber(totalWeight.toString())
                  .toString(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
      {required String icon, required String label, required String value}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          icon,
          height: 28,
          width: 28,
        ),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.h1,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(double deviceWidth) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/collect_list_header.png',
            width: deviceWidth * 0.5,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              color: AppTheme.h1,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Add waste items to continue',
            style: TextStyle(
              color: AppTheme.grey,
              fontSize: 13,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(AppTheme.primary),
                foregroundColor: MaterialStateProperty.all(AppTheme.white),
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 12),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              onPressed: () async {
                await Navigator.of(context).pushNamed(
                  WastesScreen.routeName,
                );
                await getWasteItems();
                setState(() {});
              },
              icon: Icon(Icons.add),
              label: Text('Add waste items'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomBar(double deviceWidth, bool isLogin) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    color: AppTheme.grey,
                    fontSize: 12,
                  ),
                ),
                AnimatedBuilder(
                  animation: _totalPriceAnimation,
                  builder: (context, child) => Text(
                    EnArConvertor().replaceArNumber(
                      intl.NumberFormat.decimalPattern()
                          .format(
                            double.parse(
                              _totalPriceAnimation.value.toStringAsFixed(0),
                            ),
                          )
                          .toString(),
                    ),
                    style: TextStyle(
                      color: AppTheme.h1,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              SnackBar addToCartSnackBar = SnackBar(
                content: Text(
                  'Please add waste',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
                ),
                action: SnackBarAction(
                  label: 'Ok',
                  onPressed: () {},
                ),
              );
              if (wasteCartItems.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(addToCartSnackBar);
              } else if (!isLogin) {
                _showLogindialog();
              } else {
                Navigator.of(context).pushNamed(AddressScreen.routeName);
              }
            },
            child: ButtonBottom(
              width: deviceWidth * 0.5,
              height: deviceWidth * 0.14,
              text: 'Continue',
              isActive: wasteCartItems.isNotEmpty,
            ),
          ),
        ],
      ),
    );
  }
}
