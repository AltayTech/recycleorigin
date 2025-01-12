import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigin/core/connection/http_exception.dart';
import 'package:recycleorigin/core/screens/navigation_bottom_screen.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/features/customer_feature/presentation/providers/authentication_provider.dart';
import 'package:recycleorigin/features/customer_feature/presentation/screens/login_screen.dart';

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.VerificationCode;
  Map<String, String> _authData = {
    'phoneNumber': '',
    'verificationCode': '',
  };

  var _isLoading = false;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation1;
  late Animation<double> _opacityAnimation1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 600,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(3, 0),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
    _slideAnimation1 = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(-3, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _opacityAnimation1 = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Problem in Authentication'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Accept'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.VerificationCode) {
        // Log user in
        var response =
            await Provider.of<AuthenticationProvider>(context, listen: false)
                .login(
          _authData['phoneNumber']!,
        );

        print('veriiiii');

        _switchAuthMode();
      } else {
        print('loginmode');
        // Sign user up

        var response =
            await Provider.of<AuthenticationProvider>(context, listen: false)
                .getVerCode(
          _authData['verificationCode']!,
          _authData['phoneNumber']!,
        );
        if (response) {
//          try {
//            Provider.of<Products>(context, listen: false)
//                .addShopCartAfterLogin(true);
//          } catch (error) {
//            print(error.toString());
//          }

          Navigator.of(context)
              .pushReplacementNamed(NavigationBottomScreen.routeName);
        } else {
          _showErrorDialog('Code is not correct');
        }
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage = 'Could not authenticate you. Please try again later';
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    print('swotchMode');
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.VerificationCode;
//        _controller.reverse();
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
        _controller.forward();
      });
    }
  }

  void _switchPhoneCorrectMode() {
    print('swotchMode');
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.VerificationCode;
        _controller.reverse();
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
        _controller.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return Container(
      width: deviceSize.width * 0.85,
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  AnimatedContainer(
                    duration: _controller.duration!,
                    curve: Curves.easeIn,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: Center(
                            child: Text(
                              'Enter your password',
                              style: TextStyle(
                                color: AppTheme.h1,
                                fontFamily: 'Iransans',
                                fontSize: textScaleFactor * 11.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: _controller.duration!,
                    curve: Curves.easeIn,
                    child: FadeTransition(
                      opacity: _opacityAnimation1,
                      child: SlideTransition(
                        position: _slideAnimation1,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: Center(
                            child: Text(
                              'Enter your Email',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                                fontFamily: 'Iransans',
                                fontSize: textScaleFactor * 11.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Stack(
                children: <Widget>[
                  AnimatedContainer(
                    duration: _controller.duration!,
                    curve: Curves.easeIn,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Center(
                          child: Stack(
                            children: <Widget>[
                              Container(
                                height: deviceSize.height * 0.055,
                                width: deviceSize.width * 0.6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Colors.blue, width: 1.5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Stack(
                                    children: <Widget>[
                                      Center(
                                        child: TextFormField(
                                          textAlign: TextAlign.center,
                                          enabled: true,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            suffix: Text(''),
                                            labelStyle: TextStyle(
                                              color: Colors.grey,
                                              fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 15.0,
                                            ),
                                          ),
                                          keyboardType: TextInputType.text,
                                          validator: _authMode == AuthMode.Login
                                              ? (value) {
                                                  _authData[
                                                          'verificationCode'] =
                                                      value!;
                                                  return null;
                                                }
                                              : null,
                                        ),
                                      ),
                                      Positioned(
                                          right: 3,
                                          top: 5,
                                          bottom: 12,
                                          child: Icon(
                                            Icons.mobile_screen_share,
                                            color: Colors.blue,
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: _controller.duration!,
                    curve: Curves.easeIn,
                    child: FadeTransition(
                      opacity: _opacityAnimation1,
                      child: SlideTransition(
                        position: _slideAnimation1,
                        child: Center(
                          child: Stack(
                            children: <Widget>[
                              Container(
                                height: deviceSize.height * 0.055,
                                width: deviceSize.width * 0.6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: AppTheme.h1, width: 0.5),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: <Widget>[
                                      TextFormField(
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          suffix: Text(''),
                                          counterStyle: TextStyle(
                                            decorationStyle:
                                                TextDecorationStyle.dashed,
                                            color: Colors.grey,
                                            fontFamily: 'Iransans',
                                            fontSize: textScaleFactor * 18.0,
                                          ),
                                        ),
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter your email';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          _authData['phoneNumber'] = value!;
                                        },
                                      ),
                                      Positioned(
                                          right: 3,
                                          top: 5,
                                          bottom: 12,
                                          child: Icon(
                                            Icons.mobile_screen_share,
                                            color: AppTheme.secondary,
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              _isLoading
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
                      height: deviceSize.height * 0.055,
                      width: deviceSize.width * 0.6,
                      child: ElevatedButton(
                        child: Text(
                          _authMode == AuthMode.Login
                              ? 'Login'
                              : 'Confirmation Code',
                          style: TextStyle(
                            color: AppTheme.bg,
                            fontFamily: 'Iransans',
                            fontSize: textScaleFactor * 13.0,
                          ),
                        ),
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          _submit();
                        },

                        // shape: RoundedRectangleBorder(
                        //   borderRadius: BorderRadius.circular(5),
                        // ),
                        // padding: EdgeInsets.symmetric(
                        //     horizontal: 30.0, vertical: 8.0),

                        // color: AppTheme.primary,
                        // textColor: AppTheme.bg,
                      ),
                    ),
              AnimatedContainer(
                duration: _controller.duration!,
                curve: Curves.easeIn,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: TextButton(
                      child: Text(
                        'Change the Email',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Iransans',
                          fontSize: textScaleFactor * 9.0,
                        ),
                      ),
                      onPressed: _switchPhoneCorrectMode,

                      // padding: EdgeInsets.only(right: 30.0, left: 30.0, top: 4),
                      // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      // textColor: Theme.of(context).primaryColor,
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
