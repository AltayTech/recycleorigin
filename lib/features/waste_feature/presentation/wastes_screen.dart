import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/waste.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/wasteCart.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/main_drawer.dart';
import 'providers/wastes.dart';
import 'widgets/waste_item_wastes_screen.dart';

class WastesScreen extends StatefulWidget {
  static const routeName = '/wastesScreen';

  @override
  _WastesScreenState createState() => _WastesScreenState();
}

class _WastesScreenState extends State<WastesScreen>
    with SingleTickerProviderStateMixin {
  bool _isInit = true;
  var _isLoading;
  Function? callBack = () {};

  List<WasteCart> wasteCartItems = [];
  List<int> wasteCartItemsId = [];

  @override
  void didChangeDependencies() {
    if (_isInit) {
      callBack = ModalRoute.of(context)?.settings.arguments as Function?;

      searchItems();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  List<Waste> loadedWastes = [];

  Future<void> searchItems() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<Wastes>(context, listen: false).searchWastesItem();
    loadedWastes.clear();
    loadedWastes = Provider.of<Wastes>(context, listen: false).wasteItems;
    wasteCartItems = Provider.of<Wastes>(context, listen: false).wasteCartItems;
    wasteCartItemsId =
        Provider.of<Wastes>(context, listen: false).wasteCartItemsId;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.appBarColor,
        iconTheme: new IconThemeData(color: AppTheme.appBarIconColor),
        centerTitle: true,
        title: Text(
          "Waste List",
          style: TextStyle(
            //fontFamily: 'Iransans',
            color: AppTheme.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: deviceHeight * 0.03, horizontal: deviceWidth * 0.03),
          child: Stack(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: deviceHeight * 0.9,
                child: GridView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: loadedWastes.length,
                  itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                    value: loadedWastes[i],
                    child: InkWell(
                        onTap: () {
                          wasteCartItems =
                              Provider.of<Wastes>(context, listen: false)
                                  .wasteCartItems;
                          wasteCartItemsId =
                              Provider.of<Wastes>(context, listen: false)
                                  .wasteCartItemsId;

                          if (wasteCartItemsId.contains(loadedWastes[i].id)) {
                            Provider.of<Wastes>(context, listen: false)
                                .removeWasteCart(loadedWastes[i].id);
                          } else {
                            Provider.of<Wastes>(context, listen: false)
                                .addWasteCart(loadedWastes[i], 1);
                          }
                          wasteCartItemsId =
                              Provider.of<Wastes>(context, listen: false)
                                  .wasteCartItemsId;

                          setState(() {});
                        },
                        child: WasteItemWastesScreen(
                          waste: loadedWastes[i],
                          isSelected:
                              wasteCartItemsId.contains(loadedWastes[i].id),
                        )),
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
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
                      : Container(
                          child: loadedWastes.isEmpty
                              ? Center(
                                  child: Text(
                                  'No items found',
                                  style: TextStyle(
                                    //fontFamily: 'Iransans',
                                    fontSize: textScaleFactor * 15.0,
                                  ),
                                ))
                              : Container(),
                        ),
                ),
              )
            ],
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        backgroundColor: AppTheme.primary,
        child: Icon(
          Icons.check,
          color: AppTheme.white,
        ),
      ),
    );
  }
}
