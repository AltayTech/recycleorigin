import 'package:flutter/material.dart';

import '../../features/store_feature/business/entities/product.dart';
import '../theme/app_theme.dart';
import '../theme/theme_context_extensions.dart';
import 'package:recycleorigin/l10n/l10n.dart';

class CustomDialogSelectColor extends StatefulWidget {
  final Product product;
  final Function function;

  CustomDialogSelectColor({required this.product, required this.function});

  @override
  _CustomDialogSelectColorState createState() =>
      _CustomDialogSelectColorState();
}

class _CustomDialogSelectColorState extends State<CustomDialogSelectColor> {
  var _selectedColorIndex;

  var _selectedColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.textScalerOf(context).scale(1);
    return Padding(
      padding: EdgeInsets.only(
        top: Consts.avatarRadius + Consts.padding,
        bottom: Consts.padding,
        left: Consts.padding,
        right: Consts.padding,
      ),
      child: Container(
        decoration: new BoxDecoration(
          color: context.appColors.scaffoldBackground,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: context.colors.shadow.withValues(alpha: 0.26),
              blurRadius: 5.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(
                widget.product.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.primary,
                  //fontFamily: 'Iransans',
                  height: 2,
                  fontSize: MediaQuery.textScalerOf(context).scale(1) * 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  context.l10n.selectProductColorTitle,
                  style: TextStyle(
                    color: context.appColors.divider,
                    //fontFamily: 'Iransans',
                    fontSize: textScaleFactor * 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              //              Padding(
              //                padding: const EdgeInsets.only(top: 15.0, bottom: 15),
              //                child: ListView.builder(
              //                  scrollDirection: Axis.vertical,
              //                  shrinkWrap: true,
              //                  itemCount: widget.product.color.length,
              //                  itemBuilder: (BuildContext context, int index) {
              //                    return InkWell(
              //                      onTap: () {
              //                        if (widget.product.color[index].available) {
              //                          _selectedColorIndex = index;
              //                          _selectedColor = widget.product.color[index];
              //                          setState(() {});
              //                        }
              //                      },
              //                      child: Container(
              //                        decoration: _selectedColorIndex == index
              //                            ? BoxDecoration(
              //                                border:
              //                                    Border.all(color: context.colors.onSurface, width: 0.2),
              //                                borderRadius: BorderRadius.circular(5),
              //                                color: context.appColors.divider.withOpacity(0.15),
              //                              )
              //                            : BoxDecoration(
              //                                color: context.appColors.scaffoldBackground,
              //                              ),
              //                        child: Row(
              //                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                          children: <Widget>[
              //                            Padding(
              //                              padding: const EdgeInsets.all(4.0),
              //                              child: Text(
              //                                widget.product.color[index].available
              //                                    ? widget.product.color[index].price
              //                                            .isNotEmpty
              //                                        ? EnArConvertor().replaceArNumber(
              //                                            currencyFormat
              //                                                .format(double.parse(widget
              //                                                    .product
              //                                                    .color[index]
              //                                                    .price))
              //                                                .toString())
              //                                        : EnArConvertor().replaceArNumber('0')
              //                                    : 'ناموجود',
              //                                style: TextStyle(
              //                                  color: widget.product.color[index].available
              //                                      ? AppTheme.primary
              //                                      : context.appColors.subtitleColor,
              //                                  //fontFamily: 'Iransans',
              //                                  fontSize: textScaleFactor * 20.0,
              //                                ),
              //                              ),
              //                            ),
              //                            Padding(
              //                              padding: const EdgeInsets.all(4.0),
              //                              child: Text(
              //                                widget.product.color[index].title,
              //                                style: TextStyle(
              //                                  color: widget.product.color[index].available
              //                                      ? AppTheme.primary
              //                                      : context.appColors.subtitleColor,
              //                                  //fontFamily: 'Iransans',
              //                                  fontSize: textScaleFactor * 16,
              //                                ),
              //                              ),
              //                            ),
              //                            Padding(
              //                              padding: const EdgeInsets.all(5.0),
              //                              child: Container(
              //                                width: 25,
              //                                height: 25,
              //                                decoration: BoxDecoration(
              //                                  shape: BoxShape.circle,
              //                                  border: Border.all(
              //                                      color: context.colors.onSurface, width: 0.2),
              //                                  color: Color(
              //                                    int.parse(
              //                                      '0xff' +
              //                                          widget.product.color[index].colorCode
              //                                              .replaceRange(0, 1, ''),
              //                                    ),
              //                                  ),
              //                                ),
              //                              ),
              //                            ),
              //                          ],
              //                        ),
              //                      ),
              //                    );
              //                  },
              //                ),
              //              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Builder(
                  builder: (context) => ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: InkWell(
                      onTap: () {
                        widget.function(_selectedColor);
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: deviceHeight * 0.06,
                        width: deviceWidth * 0.6,
                        decoration: BoxDecoration(
                          color: _selectedColorIndex != null
                              ? AppTheme.primary
                              : context.appColors.subtitleColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              context.l10n.addToCartLabel,
                              style: TextStyle(
                                color: context.appColors.cardBackground,
                                //fontFamily: 'Iransans',
                                fontSize: textScaleFactor * 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Consts {
  Consts._();

  static const double padding = 5.0;
  static const double avatarRadius = 3;
}
