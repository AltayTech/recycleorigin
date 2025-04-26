import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../logic/en_to_ar_number_convertor.dart';
import '../widgets/splashscreen.dart';
import 'navigation_bottom_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SplashScreens extends StatefulWidget {
  @override
  _SplashScreensState createState() => _SplashScreensState();
}

class _SplashScreensState extends State<SplashScreens> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      seconds: 3,
      navigateAfterSeconds: new NavigationBottomScreen(),
      title: new Text(
        "Recycle Origin",
        textAlign: TextAlign.center,
        style: new TextStyle(
          fontFamily: 'BFarnaz',
          fontSize: MediaQuery.of(context).textScaleFactor * 30,
          color: Color(0xff06623B),
          shadows: <Shadow>[
            Shadow(
              offset: Offset(0.0, 0.0),
              blurRadius: 0.0,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ],
        ),
      ),
      loadingText: Text(
        EnArConvertor()
            .replaceArNumber('Version 1.0'),
        style: new TextStyle(
          fontFamily: 'Iransans',
          fontWeight: FontWeight.w400,
          fontSize: MediaQuery.of(context).textScaleFactor * 18,
          color: Colors.black,
        ),
      ),
      image: Image.asset(
        'assets/images/splash_main.png',
//        color: AppTheme.primary,
        fit: BoxFit.contain,
        height: MediaQuery.of(context).size.width * 0.7,
        width: MediaQuery.of(context).size.width * 0.7,
      ),
      gradientBackground: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          AppTheme.bg,
          AppTheme.bg,
          AppTheme.bg,
        ],
      ),
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: MediaQuery.of(context).size.width * 0.7,
      onClick: () => print("Flutter Egypt"),
    );
  }
}
