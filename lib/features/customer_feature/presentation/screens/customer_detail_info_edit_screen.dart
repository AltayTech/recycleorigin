import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigin/core/models/status.dart';

import '../../../../core/models/customer.dart';
import '../../business/entities/personal_data.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/customer_info_provider.dart';
import '../../../../core/widgets/info_edit_item.dart';
import '../../../../core/widgets/main_drawer.dart';
import 'customer_user_info_screen.dart';

class CustomerDetailInfoEditScreen extends StatefulWidget {
  static const routeName = '/customerDetailInfoEditScreen';

  @override
  _CustomerDetailInfoEditScreenState createState() =>
      _CustomerDetailInfoEditScreenState();
}

class _CustomerDetailInfoEditScreenState
    extends State<CustomerDetailInfoEditScreen> {
  final nameController = TextEditingController();
  final familyController = TextEditingController();

  final typeController = TextEditingController();
  final ostanController = TextEditingController();
  final cityController = TextEditingController();

  final postCodeController = TextEditingController();

  List<Status> typesList = [];

  List<String> typeValueList = [];

  late String typeValue;

  late Status selectedType;

  @override
  void initState() {
    Customer customer =
        Provider.of<CustomerInfoProvider>(context, listen: false).customer;
    nameController.text = customer.personalData.first_name;
    familyController.text = customer.personalData.last_name;

    typeController.text = customer.personalData.email;
    ostanController.text = customer.personalData.ostan;
    cityController.text = customer.personalData.city;
    postCodeController.text = customer.personalData.postcode;
    selectedType = customer.customer_type;

    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    familyController.dispose();
    cityController.dispose();
    ostanController.dispose();
    typeController.dispose();
    postCodeController.dispose();
    super.dispose();
  }

  var _isLoading;

  Future<void> retrieveTypes() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<CustomerInfoProvider>(context, listen: false).getTypes();
    typesList.clear();
    typeValueList.clear();
    typesList =
        Provider.of<CustomerInfoProvider>(context, listen: false).typesItems;
    for (int i = 0; i < typesList.length; i++) {
      typeValueList.add(typesList[i].name);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void didChangeDependencies() async {
    await retrieveTypes();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    Customer customerInfo =
        Provider.of<CustomerInfoProvider>(context, listen: false).customer;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppTheme.appBarColor,
          iconTheme: new IconThemeData(color: AppTheme.appBarIconColor),
        ),

        drawer: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.transparent,
          ),
          child: MainDrawer(),
        ), // resizeToAvoidBottomInset: false,
        body: Builder(
          builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: Stack(
              children: <Widget>[
                Container(
                  color: AppTheme.bg,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Personal Info',
                            style: TextStyle(
                              color: AppTheme.black,
                              //fontFamily: 'Iransans',
                              fontSize: textScaleFactor * 14.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Container(
                            child: ListView(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              children: <Widget>[
                                InfoEditItem(
                                  title: 'Name',
                                  controller: nameController,
                                  bgColor: AppTheme.bg,
                                  iconColor: Color(0xffA67FEC),
                                  keybordType: TextInputType.text,
                                  fieldHeight: deviceHeight * 0.05,
                                  thisFocusNode: FocusNode(),
                                  newFocusNode: FocusNode(),
                                ),
                                InfoEditItem(
                                  title: 'Last Name',
                                  controller: familyController,
                                  bgColor: AppTheme.bg,
                                  iconColor: Color(0xffA67FEC),
                                  keybordType: TextInputType.text,
                                  fieldHeight: deviceHeight * 0.05,
                                  thisFocusNode: FocusNode(),
                                  newFocusNode: FocusNode(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    'User type:',
                                    style: TextStyle(
                                      color: AppTheme.black,
                                      //fontFamily: 'Iransans',
                                      fontSize: textScaleFactor * 13.0,
                                    ),
                                  ),
                                ),
                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      width: deviceWidth * 0.78,
                                      height: deviceHeight * 0.05,
                                      alignment: Alignment.centerRight,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: AppTheme.white,
                                          border: Border.all(
                                              color: AppTheme.h1, width: 0.6)),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            right: 8.0, left: 8, top: 6),
                                        child: DropdownButton<String>(
                                          hint: Text(
                                            'User Type',
                                            style: TextStyle(
                                              color: AppTheme.grey,
                                              //fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 13.0,
                                            ),
                                          ),
                                          value: typeValue,
                                          icon: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10.0),
                                            child: Icon(
                                              Icons.arrow_drop_down,
                                              color: AppTheme.black,
                                              size: 20,
                                            ),
                                          ),
                                          dropdownColor: AppTheme.white,
                                          style: TextStyle(
                                            color: AppTheme.black,
                                            //fontFamily: 'Iransans',
                                            fontSize: textScaleFactor * 13.0,
                                          ),
                                          isDense: true,
                                          onChanged: (newValue) {
                                            setState(() {
                                              typeValue = newValue!;
                                              selectedType = typesList[
                                                  typeValueList
                                                      .lastIndexOf(newValue)];
                                            });
                                          },
                                          items: typeValueList
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
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.grey,
                          ),
                          Container(
                            color: AppTheme.bg,
                            child: ListView(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              children: <Widget>[
                                InfoEditItem(
                                  title: 'Province',
                                  controller: ostanController,
                                  bgColor: AppTheme.bg,
                                  iconColor: Color(0xff4392F1),
                                  keybordType: TextInputType.text,
                                  fieldHeight: deviceHeight * 0.05,
                                  thisFocusNode: FocusNode(),
                                  newFocusNode: FocusNode(),
                                ),
                                InfoEditItem(
                                  title: 'City',
                                  controller: cityController,
                                  bgColor: AppTheme.bg,
                                  iconColor: Color(0xff4392F1),
                                  keybordType: TextInputType.text,
                                  fieldHeight: deviceHeight * 0.05,
                                  thisFocusNode: FocusNode(),
                                  newFocusNode: FocusNode(),
                                ),
                                InfoEditItem(
                                  title: 'Zipcode',
                                  controller: postCodeController,
                                  bgColor: AppTheme.bg,
                                  iconColor: Color(0xff4392F1),
                                  keybordType: TextInputType.number,
                                  fieldHeight: deviceHeight * 0.05,
                                  thisFocusNode: FocusNode(),
                                  newFocusNode: FocusNode(),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.grey,
                          ),
                          SizedBox(
                            height: deviceHeight * 0.02,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () {
              setState(() {});
              var _snackBarMessage = 'Information Changed';
              final addToCartSnackBar = SnackBar(
                content: Text(
                  _snackBarMessage,
                  style: TextStyle(
                    color: Colors.white,
                    //fontFamily: 'Iransans',
                    fontSize: textScaleFactor * 14.0,
                  ),
                ),
              );

              Customer customerSend = Customer(
                customer_type: selectedType,
                personalData: PersonalData(
                  first_name: nameController.text,
                  last_name: familyController.text,
                  city: cityController.text,
                  ostan: ostanController.text,
                  postcode: postCodeController.text,
                ),
              );

              Provider.of<CustomerInfoProvider>(context, listen: false)
                  .sendCustomer(customerSend)
                  .then((v) {
                ScaffoldMessenger.of(context).showSnackBar(addToCartSnackBar);
                Navigator.of(context)
                    .popAndPushNamed(CustomerUserInfoScreen.routeName);
              });
            },
            backgroundColor: AppTheme.primary,
            child: Icon(
              Icons.check,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
