import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigin/core/connection/http_exception.dart';
import 'package:recycleorigin/core/screens/navigation_bottom_screen.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/core/utils/logger.dart';
import 'package:recycleorigin/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigin/features/auth_feature/presentation/screens/login_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/l10n/l10n.dart';

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
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.authProblemTitle),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text(l10n.accept),
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
        AppLogger.debug('Login mode');
        // Log user in
        var response = await context.read<AuthBloc>().login(_authData).then(
          (value) async {
            if (await value) {
              Navigator.of(context)
                  .pushReplacementNamed(NavigationBottomScreen.routeName);
            } else {
              _showErrorDialog('Code is not correct');
            }
          },
        );
        AppLogger.debug('Login response received');

        _isLoading = false;
      } else {
        AppLogger.debug('Registration mode');
        // Sign user up

        var response = await context.read<AuthBloc>().register(_authData);
        if (response) {
          var loginResponse =
              await context.read<AuthBloc>().login(_authData).then(
            (value) async {
              AppLogger.debug('Login response after registration: $value');
              if (await value) {
                Navigator.of(context)
                    .pushReplacementNamed(NavigationBottomScreen.routeName);
              } else {
                _showErrorDialog('Code is not correct');
              }
            },
          );
        } else {
          _showErrorDialog('User already');
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

  void _switchInputAuthMode() async {
    AppLogger.debug('Switching auth mode');
    if (_authMode == AuthMode.Login) {
      _controller.forward();
      // await Future.delayed(Duration(milliseconds: 600), () {
      //   _authMode = AuthMode.Registration;
      // });
      _authMode = AuthMode.Registration;

      setState(() {});
    } else {
      _controller.reverse();
      await Future.delayed(Duration(milliseconds: 400), () {
        _authMode = AuthMode.Login;
      });

      setState(() {});
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _authMode == AuthMode.Login
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AnimatedContainer(
                        duration: _controller.duration!,
                        curve: Curves.easeIn,
                        child: FadeTransition(
                          opacity: _opacityAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Container(
                              height: deviceSize.height * 0.055,
                              width: deviceSize.width * 0.6,
                              decoration: BoxDecoration(
                                  // borderRadius: BorderRadius.circular(5),
                                  // border: Border.all(
                                  //     color: AppTheme.h1, width: 0.5),
                                  ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  TextFormField(
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              8.0), // Example: rounded corners
                                          borderSide: BorderSide(
                                              color: Colors.blue,
                                              width:
                                                  2.0), // Example: blue border, 2px wide
                                        ),
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 4.0),
                                        // Optional: Add some vertical padding
                                        suffix: Text(''),
                                        counterStyle: TextStyle(
                                          decorationStyle:
                                              TextDecorationStyle.dashed,
                                          color: Colors.grey,
                                          //fontFamily: 'Iransans',
                                          fontSize: textScaleFactor * 18.0,
                                        ),
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          //fontFamily: 'Iransans',
                                          fontSize: 11,
                                        ),
                                        hintText: context.l10n.firstNameHint),
                                    keyboardType: TextInputType.name,
                                    validator:
                                        _authMode == AuthMode.Registration
                                            ? (value) {
                                                if (value!.isEmpty) {
                                                  return 'Please enter your first name';
                                                }
                                                return null;
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
                        ),
                      ),
                    ),
              _authMode == AuthMode.Login
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: AnimatedContainer(
                        duration: _controller.duration!,
                        curve: Curves.easeIn,
                        child: FadeTransition(
                          opacity: _opacityAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Container(
                              height: deviceSize.height * 0.055,
                              width: deviceSize.width * 0.6,
                              decoration: BoxDecoration(
                                  // borderRadius: BorderRadius.circular(5),
                                  // border: Border.all(
                                  //     color: AppTheme.h1, width: 0.5),
                                  ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  TextFormField(
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            8.0), // Example: rounded corners
                                        borderSide: BorderSide(
                                            color: Colors.blue,
                                            width:
                                                2.0), // Example: blue border, 2px wide
                                      ),
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 4.0),
                                      suffix: Text(''),
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                        //fontFamily: 'Iransans',
                                        fontSize: 11,
                                      ),
                                      hintText: context.l10n.lastNameHint,
                                      counterStyle: TextStyle(
                                        decorationStyle:
                                            TextDecorationStyle.dashed,
                                        color: Colors.grey,
                                        //fontFamily: 'Iransans',
                                        fontSize: textScaleFactor * 18.0,
                                      ),
                                    ),
                                    keyboardType: TextInputType.name,
                                    validator:
                                        _authMode == AuthMode.Registration
                                            ? (value) {
                                                if (value!.isEmpty) {
                                                  return 'Please enter your last name';
                                                }
                                                return null;
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
                        ),
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Center(
                  child: Container(
                    height: deviceSize.height * 0.055,
                    width: deviceSize.width * 0.6,
                    decoration: BoxDecoration(
                        // borderRadius: BorderRadius.circular(5),
                        // border: Border.all(color: AppTheme.h1, width: 0.5),
                        ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        TextFormField(
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  8.0), // Example: rounded corners
                              borderSide: BorderSide(
                                  color: Colors.blue,
                                  width: 2.0), // Example: blue border, 2px wide
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 4.0),
                            suffix: Text(''),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              //fontFamily: 'Iransans',
                              fontSize: 11,
                            ),
                            hintText: context.l10n.emailInputHint,
                            counterStyle: TextStyle(
                              decorationStyle: TextDecorationStyle.dashed,
                              color: Colors.grey,
                              //fontFamily: 'Iransans',
                              fontSize: textScaleFactor * 18.0,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
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
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Center(
                  child: Container(
                    height: deviceSize.height * 0.055,
                    width: deviceSize.width * 0.6,
                    decoration: BoxDecoration(
                        // borderRadius: BorderRadius.circular(5),
                        // border: Border.all(color: AppTheme.h1, width: 0.5),
                        ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        TextFormField(
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  8.0), // Example: rounded corners
                              borderSide: BorderSide(
                                  color: Colors.blue,
                                  width: 2.0), // Example: blue border, 2px wide
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 4.0),
                            suffix: Text(''),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              //fontFamily: 'Iransans',
                              fontSize: 11,
                            ),
                            hintText: context.l10n.passwordInputHint,
                            counterStyle: TextStyle(
                              decorationStyle: TextDecorationStyle.dashed,
                              color: Colors.grey,
                              //fontFamily: 'Iransans',
                              fontSize: textScaleFactor * 18.0,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
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
                              ? context.l10n.login
                              : context.l10n.authConfirmationCodeButtonLabel,
                          style: TextStyle(
                            //fontFamily: 'Iransans',
                            fontSize: textScaleFactor * 13.0,
                          ),
                        ),
                        onPressed: () async {
                          AppLogger.debug("Login button clicked");
                          FocusScope.of(context).requestFocus(FocusNode());
                          await _submit();
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
                  _authMode == AuthMode.Login
                      ? context.l10n.authNotRegisteredPrompt
                      : context.l10n.authSwitchToLoginPrompt,
                  style: TextStyle(
                    color: Colors.black,
                    //fontFamily: 'Iransans',
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
