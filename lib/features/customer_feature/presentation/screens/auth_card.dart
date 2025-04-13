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
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
    'first_name': '',
    'last_name': '',
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
      if (_authMode == AuthMode.Login) {
        debugPrint('login mode');
        // Log user in
        var response =
            await Provider.of<AuthenticationProvider>(context, listen: false)
                .login(_authData!);
        debugPrint(response.toString());

        print('veriiiii');

        // _switchAuthMode();
      } else {
        print('loginmode');
        // Sign user up

        var response =
            await Provider.of<AuthenticationProvider>(context, listen: false)
                .register(_authData);
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

  void _switchInputAuthMode() {
    print('swotchMode');
    if (_authMode == AuthMode.Login) {
      _authMode = AuthMode.Registration;
      _controller.forward();

      setState(() {

      });
    } else {
      _authMode = AuthMode.Login;
      _controller.reverse();
      setState(() {

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
                                          hintText: 'Please enter your first name'
                                        ),
                                        keyboardType:
                                        TextInputType.name,

                                        validator:
                                        _authMode == AuthMode.Registration
                                            ? (value) {

                                          return 'Please enter your first name';
                                        }
                                            : null,

                                        onSaved: (value) {
                                          _authData['first_name'] = value!;
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
                                          hintText: 'Please enter your last name',
                                          counterStyle: TextStyle(
                                            decorationStyle:
                                            TextDecorationStyle.dashed,
                                            color: Colors.grey,
                                            fontFamily: 'Iransans',
                                            fontSize: textScaleFactor * 18.0,
                                          ),
                                        ),
                                        keyboardType:
                                        TextInputType.name,
                                        validator:

                                        _authMode == AuthMode.Registration
                                            ? (value) {

                                            return 'Please enter your last name';
                                        }
                                            : null,
                                        onSaved: (value) {
                                          _authData['last_name'] = value!;
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

              Stack(
                children: <Widget>[
                  Center(
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
                                    hintText: 'Please enter your email',
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
                                    _authData['email'] = value!;
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
                  // AnimatedContainer(
                  //   duration: _controller.duration!,
                  //   curve: Curves.easeIn,
                  //   child: FadeTransition(
                  //     opacity: _opacityAnimation1,
                  //     child: SlideTransition(
                  //       position: _slideAnimation1,
                  //       child: Center(
                  //         child: Stack(
                  //           children: <Widget>[
                  //             Container(
                  //               height: deviceSize.height * 0.055,
                  //               width: deviceSize.width * 0.6,
                  //               decoration: BoxDecoration(
                  //                 borderRadius: BorderRadius.circular(5),
                  //                 border: Border.all(
                  //                     color: AppTheme.h1, width: 0.5),
                  //               ),
                  //               child: Padding(
                  //                 padding:
                  //                 const EdgeInsets.symmetric(horizontal: 8),
                  //                 child: Stack(
                  //                   alignment: Alignment.center,
                  //                   children: <Widget>[
                  //                     TextFormField(
                  //                       textAlign: TextAlign.center,
                  //                       decoration: InputDecoration(
                  //                         border: InputBorder.none,
                  //                         suffix: Text(''),
                  //                         hintText: 'Please enter your email',
                  //                         counterStyle: TextStyle(
                  //                           decorationStyle:
                  //                           TextDecorationStyle.dashed,
                  //                           color: Colors.grey,
                  //                           fontFamily: 'Iransans',
                  //                           fontSize: textScaleFactor * 18.0,
                  //                         ),
                  //                       ),
                  //                       keyboardType:
                  //                       TextInputType.emailAddress,
                  //                       validator: (value) {
                  //                         if (value!.isEmpty) {
                  //                           return 'Please enter your email';
                  //                         }
                  //                         return null;
                  //                       },
                  //                       onSaved: (value) {
                  //                         _authData['email'] = value!;
                  //                       },
                  //                     ),
                  //                     Positioned(
                  //                         right: 3,
                  //                         top: 5,
                  //                         bottom: 12,
                  //                         child: Icon(
                  //                           Icons.mobile_screen_share,
                  //                           color: AppTheme.secondary,
                  //                         )),
                  //                   ],
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              Stack(
                children: <Widget>[
                  Center(
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
                                    hintText: 'Please enter your password',
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
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _authData['password'] = value!;
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
                  // AnimatedContainer(
                  //   duration: _controller.duration!,
                  //   curve: Curves.easeIn,
                  //   child: FadeTransition(
                  //     opacity: _opacityAnimation1,
                  //     child: SlideTransition(
                  //       position: _slideAnimation1,
                  //       child: Center(
                  //         child: Stack(
                  //           children: <Widget>[
                  //             Container(
                  //               height: deviceSize.height * 0.055,
                  //               width: deviceSize.width * 0.6,
                  //               decoration: BoxDecoration(
                  //                 borderRadius: BorderRadius.circular(5),
                  //                 border: Border.all(
                  //                     color: AppTheme.h1, width: 0.5),
                  //               ),
                  //               child: Padding(
                  //                 padding:
                  //                 const EdgeInsets.symmetric(horizontal: 8),
                  //                 child: Stack(
                  //                   alignment: Alignment.center,
                  //                   children: <Widget>[
                  //                     TextFormField(
                  //                       textAlign: TextAlign.center,
                  //                       decoration: InputDecoration(
                  //                         border: InputBorder.none,
                  //                         suffix: Text(''),
                  //                         hintText: 'Please enter your password',
                  //                         counterStyle: TextStyle(
                  //                           decorationStyle:
                  //                           TextDecorationStyle.dashed,
                  //                           color: Colors.grey,
                  //                           fontFamily: 'Iransans',
                  //                           fontSize: textScaleFactor * 18.0,
                  //                         ),
                  //                       ),
                  //                       keyboardType:
                  //                       TextInputType.emailAddress,
                  //                       validator: (value) {
                  //                         if (value!.isEmpty) {
                  //                           return 'Please enter your password';
                  //                         }
                  //                         return null;
                  //                       },
                  //                       onSaved: (value) {
                  //                         _authData['password'] = value!;
                  //                       },
                  //                     ),
                  //                     Positioned(
                  //                         right: 3,
                  //                         top: 5,
                  //                         bottom: 12,
                  //                         child: Icon(
                  //                           Icons.mobile_screen_share,
                  //                           color: AppTheme.secondary,
                  //                         )),
                  //                   ],
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
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
                            fontFamily: 'Iransans',
                            fontSize: textScaleFactor * 13.0,
                          ),
                        ),
                        onPressed: () {
                          debugPrint("login clicked");
                          FocusScope.of(context).requestFocus(FocusNode());
                          _submit();
                          // Navigator.of(context).pop();
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
              TextButton(
                child: Text(
                  _authMode==AuthMode.Login?
                  'Change the Register':'Change the login',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Iransans',
                    fontSize: textScaleFactor * 9.0,
                  ),
                ),
                onPressed: _switchInputAuthMode,

                // textColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
