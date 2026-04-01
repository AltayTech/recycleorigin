import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../logic/en_to_ar_number_convertor.dart';
import '../utils/app_info_service.dart';
import '../widgets/splashscreen.dart';
import 'navigation_bottom_screen.dart';
import 'package:recycleorigin/l10n/l10n.dart';

class SplashScreens extends StatefulWidget {
  @override
  _SplashScreensState createState() => _SplashScreensState();
}

class _SplashScreensState extends State<SplashScreens> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadAppVersion();
    });
  }

  /// Loads app version dynamically from AppInfoService
  Future<void> _loadAppVersion() async {
    try {
      final appInfo = AppInfoService.instance;
      if (!appInfo.isInitialized) {
        await appInfo.initialize();
      }
      if (mounted) {
        setState(() {
          _appVersion = '${context.l10n.version} ${appInfo.version}';
        });
      }
    } catch (e) {
      // Fallback to default version if loading fails
      if (mounted) {
        setState(() {
          _appVersion = '${context.l10n.version} 1.0.0';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      seconds: 3,
      navigateAfterSeconds: new NavigationBottomScreen(),
      title: new Text(
        context.l10n.recycleorigin,
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
        _appVersion.isEmpty
            ? context.l10n.loadingLabel
            : EnArConvertor().replaceArNumber(_appVersion),
        style: new TextStyle(
          //fontFamily: 'Iransans',
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
      imageBackground: AssetImage(
        'assets/images/login_bg.png',
//        color: AppTheme.primary,
      ),
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: MediaQuery.of(context).size.width * 0.7,
      onClick: () => print("Flutter Egypt"),
    );
  }
}
