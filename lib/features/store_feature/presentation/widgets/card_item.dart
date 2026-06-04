import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart' as intl;
import '../../business/entities/product_cart.dart';
import '../bloc/products_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import '../../../auth_feature/presentation/bloc/auth_bloc.dart';
import '../screens/product_detail_screen.dart';
import '../../../../core/logic/en_to_ar_number_convertor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CardItem extends StatefulWidget {
  final ProductCart shoppItem;
  final Function callFunction;

  CardItem({
    required this.shoppItem,
    required this.callFunction,
  });

  @override
  _CardItemState createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  bool _isInit = true;

  var _isLoading = true;

  late bool isLogin;

  int productCount = 0;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isLoading = false;

      productCount = widget.shoppItem.productCount;
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> removeItem() async {
    setState(() {
      _isLoading = true;
    });
    await context.read<ProductsBloc>().removeShopCart(widget.shoppItem.id);
    widget.callFunction();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var deviceHeight = MediaQuery.of(context).size.height;
    var deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    var currencyFormat = intl.NumberFormat.decimalPattern();
    isLogin = context.watch<AuthBloc>().isAuth;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: LayoutBuilder(
        builder: (_, constraints) => Container(
          decoration: AppTheme.listItemBoxFor(context),
          height: deviceWidth * 0.35,
          child: InkWell(
            onTap: () {
              context.read<ProductsBloc>().item = ProductsBloc.itemZero;
              Navigator.of(context).pushNamed(
                ProductDetailScreen.routeName,
                arguments: widget.shoppItem.id,
              );
            },
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    width: deviceWidth,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: double.infinity,
                              child: FadeInImage(
                                placeholder:
                                    AssetImage('assets/images/circle.gif'),
                                image: NetworkImage(
                                    widget.shoppItem.featured_media_url),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: deviceWidth * 0.03,
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      widget.shoppItem.title,
                                      style: TextStyle(
                                        color: context.colors.onSurface,
                                        fontWeight: FontWeight.w600,
                                        //fontFamily: 'Iransans',
                                        fontSize: textScaleFactor * 15,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        height: constraints.maxHeight * 0.23,
                                        width: constraints.maxWidth * 0.3,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Expanded(
                                                child: InkWell(
                                              onTap: () async {
                                                productCount = productCount + 1;

                                                await context
                                                    .read<ProductsBloc>()
                                                    .updateShopCart(
                                                        widget.shoppItem,
                                                        widget.shoppItem
                                                            .color_selected,
                                                        productCount,
                                                        isLogin)
                                                    .then((_) {
                                                  widget.callFunction();
                                                  setState(() {
                                                    _isLoading = false;
                                                    print(
                                                        _isLoading.toString());
                                                  });
                                                });
                                              },
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2),
                                                    color: AppTheme.accent,
                                                  ),
                                                  child: Icon(
                                                    Icons.add,
                                                    color: context.appColors
                                                        .scaffoldBackground,
                                                  )),
                                            )),
                                            Expanded(
                                              child: Text(
                                                EnArConvertor()
                                                    .replaceArNumber(widget
                                                        .shoppItem.productCount
                                                        .toString())
                                                    .toString(),
                                                style: TextStyle(
                                                  color:
                                                      context.colors.onSurface,
                                                  //fontFamily: 'Iransans',
                                                  fontSize:
                                                      textScaleFactor * 14,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Expanded(
                                                child: InkWell(
                                              onTap: () {
                                                productCount = productCount - 1;

                                                context
                                                    .read<ProductsBloc>()
                                                    .updateShopCart(
                                                        widget.shoppItem,
                                                        widget.shoppItem
                                                            .color_selected,
                                                        productCount,
                                                        isLogin)
                                                    .then((_) {
                                                  widget.callFunction();

                                                  setState(() {
                                                    _isLoading = false;
                                                    print(
                                                        _isLoading.toString());
                                                  });
                                                });
                                              },
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2),
                                                    color: AppTheme.accent,
                                                  ),
                                                  child: Icon(
                                                    Icons.remove,
                                                    color: context.appColors
                                                        .scaffoldBackground,
                                                  )),
                                            )),
                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                      Container(
                                        height: constraints.maxHeight * 0.2,
                                        width: constraints.maxWidth * 0.330,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              widget.shoppItem.price.isNotEmpty
                                                  ? EnArConvertor()
                                                      .replaceArNumber(
                                                          currencyFormat
                                                              .format(double
                                                                  .parse(widget
                                                                      .shoppItem
                                                                      .price))
                                                              .toString())
                                                  : EnArConvertor()
                                                      .replaceArNumber('0'),
                                              style: TextStyle(
                                                color: context.colors.onSurface,
                                                //fontFamily: 'Iransans',
                                                fontSize: textScaleFactor * 17,
                                              ),
                                            ),
                                            Text(
                                              '  \$ ',
                                              style: TextStyle(
                                                color: context
                                                    .appColors.subtitleColor,
                                                //fontFamily: 'Iransans',
                                                fontSize: textScaleFactor * 12,
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
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 2,
                  left: 2,
                  child: Container(
                    height: deviceWidth * 0.10,
                    width: deviceWidth * 0.1,
                    child: InkWell(
                      onTap: () {
                        removeItem();
                      },
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: context.appColors.subtitleColor,
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
                                      color: context.appColors.subtitleColor,
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
