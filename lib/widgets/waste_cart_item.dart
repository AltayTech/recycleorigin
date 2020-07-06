import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import '../models/request/price_weight.dart';
import '../models/request/wasteCart.dart';
import '../provider/app_theme.dart';
import '../provider/wastes.dart';
import 'en_to_ar_number_convertor.dart';

class WasteCartItem extends StatefulWidget {
  final WasteCart wasteItem;
  final Function function;

  WasteCartItem({
    Key key,
    this.wasteItem,
    this.function,
  }) : super(key: key);

  @override
  _WasteCartItemState createState() => _WasteCartItemState();
}

class _WasteCartItemState extends State<WasteCartItem>
    with TickerProviderStateMixin {
  bool _isInit = true;

  var _isLoading = true;

  int productWeight = 0;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isLoading = false;

      productWeight = widget.wasteItem.weight;
      changeNumberAnimation(double.parse(
              getPrice(widget.wasteItem.prices, widget.wasteItem.weight)) *
          widget.wasteItem.weight);
      changeUnitPriceAnimation(double.parse(
          getPrice(widget.wasteItem.prices, widget.wasteItem.weight)));
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> removeItem() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<Wastes>(context, listen: false).removeWasteCart(
      widget.wasteItem.id,
    );

    widget.function();
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

  AnimationController _totalPriceController;
  Animation<double> _totalPriceAnimation;

  AnimationController _unitPriceController;
  Animation<double> _unitPriceAnimation;

  @override
  initState() {
    _totalPriceController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _totalPriceAnimation = _totalPriceController;

    _unitPriceController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _unitPriceAnimation = _unitPriceController;
    super.initState();
  }

  @override
  void dispose() {
    _totalPriceController.dispose();
    _unitPriceController.dispose();
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

  void changeUnitPriceAnimation(double newValue) {
    setState(() {
      _unitPriceAnimation = new Tween<double>(
        begin: _unitPriceAnimation.value,
        end: newValue,
      ).animate(new CurvedAnimation(
        curve: Curves.ease,
        parent: _unitPriceController,
      ));
    });
    _unitPriceController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    var deviceHeight = MediaQuery.of(context).size.height;
    var deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    var currencyFormat = intl.NumberFormat.decimalPattern();

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        height: deviceWidth * 0.37,
        width: deviceWidth,
        child: LayoutBuilder(
          builder: (_, constraints) => Container(
            decoration: AppTheme.listItemBox,
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        height: constraints.maxHeight * 0.5,
                        width: constraints.maxWidth,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FadeInImage(
                                  placeholder: AssetImage(
                                      'assets/images/main_page_request_ic.png'),
                                  image: NetworkImage(
                                      widget.wasteItem.featured_image != null
                                          ? widget.wasteItem.featured_image
                                              .sizes.medium
                                          : ''),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 11,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: constraints.maxHeight * 0.10,
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 5,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                widget.wasteItem.name != null
                                                    ? widget.wasteItem.name
                                                    : 'ندارد',
                                                style: TextStyle(
                                                  color: AppTheme.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Iransans',
                                                  fontSize:
                                                      textScaleFactor * 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,

                                            children: <Widget>[
                                              Text(
                                                'هر کیلو: ',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontFamily: 'Iransans',
                                                  fontSize: textScaleFactor * 12,
                                                ),
                                              ),
                                              AnimatedBuilder(
                                                animation: _unitPriceAnimation,
                                                builder:
                                                    (BuildContext context, Widget child) {
                                                  return Text(
                                                    widget.wasteItem.prices.length != 0
                                                        ? EnArConvertor().replaceArNumber(
                                                      currencyFormat.format(
                                                        double.parse(_unitPriceAnimation
                                                            .value
                                                            .toStringAsFixed(0)),
                                                      ),
                                                    )
                                                        : EnArConvertor()
                                                        .replaceArNumber('0'),
                                                    style: TextStyle(
                                                      color: AppTheme.h1,
                                                      fontFamily: 'Iransans',
                                                      fontSize: textScaleFactor * 16,
                                                    ),
                                                  );
                                                },
                                              ),
                                              Text(
                                                '  تومان ',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontFamily: 'Iransans',
                                                  fontSize: textScaleFactor * 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              height:
                              constraints.maxHeight * 0.23,
                              width: constraints.maxWidth * 0.28,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          productWeight =
                                              productWeight + 1;

                                          await Provider.of<Wastes>(
                                              context,
                                              listen: false)
                                              .updateWasteCart(
                                            widget.wasteItem,
                                            productWeight,
                                          );
                                          changeNumberAnimation(
                                              double.parse(getPrice(
                                                  widget.wasteItem
                                                      .prices,
                                                  widget.wasteItem
                                                      .weight)) *
                                                  widget.wasteItem
                                                      .weight);
                                          widget.function();
                                          changeUnitPriceAnimation(
                                              double.parse(getPrice(
                                                  widget.wasteItem
                                                      .prices,
                                                  widget.wasteItem
                                                      .weight)));
                                        },
                                        onDoubleTap: () async {
                                          productWeight =
                                              productWeight + 10;

                                          await Provider.of<Wastes>(
                                              context,
                                              listen: false)
                                              .updateWasteCart(
                                            widget.wasteItem,
                                            productWeight,
                                          );
                                          changeNumberAnimation(
                                              double.parse(getPrice(
                                                  widget.wasteItem
                                                      .prices,
                                                  widget.wasteItem
                                                      .weight)) *
                                                  widget.wasteItem
                                                      .weight);
                                          widget.function();
                                          changeUnitPriceAnimation(
                                              double.parse(getPrice(
                                                  widget.wasteItem
                                                      .prices,
                                                  widget.wasteItem
                                                      .weight)));
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppTheme.accent,
                                            ),
                                            child: Icon(
                                              Icons.add,
                                              color: AppTheme.bg,
                                            )),
                                      )),
                                  Expanded(
                                    child: Padding(
                                      padding:
                                      const EdgeInsets.only(
                                          top: 3.0),
                                      child: Text(
                                        EnArConvertor()
                                            .replaceArNumber(
                                            widget.wasteItem
                                                .weight
                                                .toString())
                                            .toString(),
                                        style: TextStyle(
                                          color: AppTheme.black,
                                          fontFamily: 'Iransans',
                                          fontSize:
                                          textScaleFactor *
                                              14,
                                        ),
                                        textAlign:
                                        TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        if (productWeight > 1) {
                                          productWeight =
                                              productWeight - 1;
                                          print('productCount' +
                                              productWeight
                                                  .toString());

                                          Provider.of<Wastes>(
                                              context,
                                              listen: false)
                                              .updateWasteCart(
                                            widget.wasteItem,
                                            productWeight,
                                          );
                                          changeNumberAnimation(
                                              double.parse(getPrice(
                                                  widget
                                                      .wasteItem
                                                      .prices,
                                                  widget
                                                      .wasteItem
                                                      .weight)) *
                                                  widget.wasteItem
                                                      .weight);
                                          changeUnitPriceAnimation(
                                              double.parse(getPrice(
                                                  widget.wasteItem
                                                      .prices,
                                                  widget.wasteItem
                                                      .weight)));
                                        }
                                        widget.function();
                                      },
                                      onDoubleTap: () async {
                                        if (productWeight > 10) {
                                          productWeight =
                                              productWeight - 10;
                                          print('productCount' +
                                              productWeight
                                                  .toString());

                                          Provider.of<Wastes>(
                                              context,
                                              listen: false)
                                              .updateWasteCart(
                                            widget.wasteItem,
                                            productWeight,
                                          );
                                          changeNumberAnimation(
                                              double.parse(getPrice(
                                                  widget
                                                      .wasteItem
                                                      .prices,
                                                  widget
                                                      .wasteItem
                                                      .weight)) *
                                                  widget.wasteItem
                                                      .weight);
                                          changeUnitPriceAnimation(
                                              double.parse(getPrice(
                                                  widget.wasteItem
                                                      .prices,
                                                  widget.wasteItem
                                                      .weight)));
                                        }
                                        widget.function();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppTheme.accent,
                                        ),
                                        child: Icon(
                                          Icons.remove,
                                          color: AppTheme.bg,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  'کل: ',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'Iransans',
                                    fontSize: textScaleFactor * 12,
                                  ),
                                ),
                                AnimatedBuilder(
                                  animation: _totalPriceAnimation,
                                  builder:
                                      (BuildContext context, Widget child) {
                                    return new Text(
                                      widget.wasteItem.prices.length != 0
                                          ? EnArConvertor()
                                              .replaceArNumber(currencyFormat
                                                  .format(double.parse(
                                                    _totalPriceAnimation.value
                                                        .toStringAsFixed(0),
                                                  ))
                                                  .toString())
                                          : EnArConvertor()
                                              .replaceArNumber('0'),
                                      style: TextStyle(
                                        color: AppTheme.h1,
                                        fontFamily: 'Iransans',
                                        fontSize: textScaleFactor * 18,
                                      ),
                                    );
                                  },
                                ),
                                Text(
                                  '  تومان ',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'Iransans',
                                    fontSize: textScaleFactor * 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    height: deviceWidth * 0.10,
                    width: deviceWidth * 0.1,
                    child: InkWell(
                      onTap: () {
                        return removeItem();
                      },
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.black54,
                      ),
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
      ),
    );
  }
}
