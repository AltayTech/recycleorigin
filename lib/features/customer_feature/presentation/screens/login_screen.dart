import 'package:flutter/material.dart';
import 'package:recycleorigin/features/customer_feature/presentation/screens/auth_card.dart';

import '../../../../core/widgets/main_drawer.dart';

enum AuthMode { VerificationCode, Login }

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Color(0xffF9F9F9),
      endDrawer: Theme(
        data: Theme.of(context).copyWith(
          // Set the transparency here
          canvasColor: Colors
              .transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
        ),
        child: MainDrawer(),
      ), // resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          height: deviceSize.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/login_bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: deviceSize.height * 0.1,
                child: Container(
                  height: deviceSize.height * 0.99,
                  width: deviceSize.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18.0, vertical: 30),
                        child: Text(
                          'Recycle Origin',
                          style: TextStyle(
                            fontFamily: 'BFarnaz',
                            fontWeight: FontWeight.w900,
                            color: Colors.green,
                            fontSize: textScaleFactor * 28.0,
                          ),
                        ),
                      )),
                      Flexible(
                        flex: deviceSize.width > 600 ? 2 : 1,
                        child: AuthCard(),
                      ),
                    ],
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
