import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../customer_feature/presentation/providers/authentication_provider.dart';
import '../../business/entities/address.dart';

/// A widget that represents an individual address item.
///
/// Displays information about the address and provides functionality
/// to remove the address.
class AddressItem extends StatefulWidget {
  final Address addressItem;
  final bool isSelected;

  const AddressItem({
    Key? key,
    required this.addressItem,
    this.isSelected = false,
  }) : super(key: key);

  @override
  _AddressItemState createState() => _AddressItemState();
}

class _AddressItemState extends State<AddressItem> {
  bool _isInit = true;
  late bool _isLoading;
  late bool _isLogin;
  late List<Address> _addressList;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isLoading = false;
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  /// Removes the address item from the list.
  Future<void> _removeItem() async {
    setState(() {
      _isLoading = true;
    });

    await Provider.of<AuthenticationProvider>(context, listen: false)
        .getAddresses();
    _addressList = Provider.of<AuthenticationProvider>(context, listen: false)
        .addressItems;

    _addressList.remove(_addressList
        .firstWhere((prod) => prod.name == widget.addressItem.name));
    await Provider.of<AuthenticationProvider>(context, listen: false)
        .updateAddress(_addressList);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final currencyFormat = intl.NumberFormat.decimalPattern();

    return Card(
      // color: Colors.white,
      child: Container(
        height: deviceWidth * 0.28,
        width: deviceWidth,
        decoration: BoxDecoration(
          color: widget.isSelected
              ? AppTheme.primary.withOpacity(0.1)
              : Colors.white,
          // border: Border.all(color: AppTheme.white, width: 0.3),
          // borderRadius: BorderRadius.circular(5),
        ),
        child: LayoutBuilder(
          builder: (_, constraints) => Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: deviceWidth * 0.05),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Icon(
                        Icons.place,
                        color: AppTheme.primary,
                        size: 30,
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  widget.addressItem.name ?? 'Not',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppTheme.black,
                                    //fontFamily: 'Iransans',
                                    fontSize: textScaleFactor * 18,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                widget.addressItem.region.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: AppTheme.grey,
                                  //fontFamily: 'Iransans',
                                  fontSize: textScaleFactor * 15,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                widget.addressItem.address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: AppTheme.grey,
                                  //fontFamily: 'Iransans',
                                  fontSize: textScaleFactor * 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 2,
                left: 2,
                child: Container(
                  height: deviceWidth * 0.10,
                  width: deviceWidth * 0.1,
                  child: InkWell(
                    onTap: _removeItem,
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
                                color: index.isEven ? Colors.grey : Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
