import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigin/features/Charities/business/entities/charity.dart';
import 'package:recycleorigin/features/Charities/presentation/providers/charities.dart';
import 'package:recycleorigin/features/Charities/presentation/widgets/charity_item_Charities_screen.dart';

import '../../../../core/logic/en_to_ar_number_convertor.dart';
import '../../../../core/models/search_detail.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/main_drawer.dart';
import '../../../store_feature/presentation/providers/Products.dart';

class CharityScreen extends StatefulWidget {
  static const routeName = '/charitiesScreen';

  @override
  _CharityScreenState createState() => _CharityScreenState();
}

class _CharityScreenState extends State<CharityScreen>
    with SingleTickerProviderStateMixin {
  bool _isInit = true;

  ScrollController _scrollController = new ScrollController();

  var _isLoading;
  int page = 1;

  SearchDetail productsDetail = SearchDetail();

  @override
  void initState() {
    Provider.of<Charities>(context, listen: false).sPage = 1;

    Provider.of<Charities>(context, listen: false).searchBuilder();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (page < productsDetail.max_page) {
          page = page + 1;
          Provider.of<Charities>(context, listen: false).sPage = page;

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
      searchItems();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  List<Charity> loadedProducts = [];
  List<Charity> loadedProductstolist = [];

  Future<void> _submit() async {
    loadedProducts.clear();
    loadedProducts =
        await Provider.of<Charities>(context, listen: false).charitiesItems;
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

    Provider.of<Charities>(context, listen: false).searchBuilder();
    await Provider.of<Charities>(context, listen: false).searchCharitiesItem();
    productsDetail =
        Provider.of<Charities>(context, listen: false).searchDetails;

    _submit();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> changeCat(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    Provider.of<Charities>(context, listen: false).sPage = 1;

    Provider.of<Charities>(context, listen: false).searchBuilder();
    loadedProductstolist.clear();

    await searchItems();

    setState(() {
      _isLoading = false;
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

    return Scaffold(
      backgroundColor: Color(0xffF9F9F9),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Charities',
          style: TextStyle(
            //fontFamily: 'Iransans',
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.appBarColor,
        iconTheme: new IconThemeData(color: AppTheme.appBarIconColor),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: deviceHeight * 0.0, horizontal: deviceWidth * 0.03),
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Please select the charity you want to donate to',
                      style: TextStyle(
                        //fontFamily: 'Iransans',
                        color: AppTheme.grey,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Spacer(),
                      Consumer<Products>(
                        builder: (_, products, ch) {
                          return Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: deviceHeight * 0.0, horizontal: 3),
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
                                        fontSize: 12.0,
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
                                        fontSize: 13.0,
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
                                        fontSize: 12.0,
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
                                        fontSize: 13.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    height: deviceHeight * 0.68,
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.vertical,
                      itemCount: loadedProductstolist.length,
                      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                        value: loadedProductstolist[i],
                        child: CharityItemCharitiesScreen(),
                      ),
                    ),
                  ),
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
                                color: index.isEven ? Colors.grey : Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(
                          child: loadedProductstolist.isEmpty
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
              ),
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
    );
  }
}
