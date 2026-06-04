import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../theme/theme_context_extensions.dart';
import '../logic/en_to_ar_number_convertor.dart';
import '../utils/app_info_service.dart';
import 'navigation_bottom_screen.dart';
import 'package:recycleorigin/l10n/l10n.dart';

class SplashScreens extends StatefulWidget {
  const SplashScreens({super.key});

  @override
  State<SplashScreens> createState() => _SplashScreensState();
}

class _SplashScreensState extends State<SplashScreens> {
  static const Duration _splashDuration = Duration(seconds: 3);
  static const String _fallbackVersion = '1.0.0';
  static const double _logoFactor = 0.7;

  final EnArConvertor _numberConvertor = EnArConvertor();
  String? _version;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    Future<void>.delayed(_splashDuration, _goToHome);
  }

  void _goToHome() {
    if (!mounted || _hasNavigated) {
      return;
    }
    _hasNavigated = true;
    Navigator.of(context)
        .pushReplacementNamed(NavigationBottomScreen.routeName);
  }

  /// Loads app version from [AppInfoService] with a safe fallback.
  Future<void> _loadAppVersion() async {
    String resolvedVersion = _fallbackVersion;
    try {
      final appInfo = AppInfoService.instance;
      if (!appInfo.isInitialized) {
        await appInfo.initialize();
      }
      resolvedVersion = appInfo.version;
    } catch (e) {
      resolvedVersion = _fallbackVersion;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _version = resolvedVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final side = MediaQuery.sizeOf(context).width * _logoFactor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final systemUiStyle =
        isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
    final colors = context.colors;
    final appColors = context.appColors;
    final brand = colors.primary;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiStyle,
      child: Scaffold(
        body: InkWell(
          onTap: _goToHome,
          child: Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/login_bg.png'),
              ),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  appColors.scaffoldBackground,
                  appColors.scaffoldBackground,
                  appColors.scaffoldBackground,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    SizedBox(
                      height: side,
                      width: side,
                      child: Image.asset(
                        'assets/images/splash_main.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.recycleorigin,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'BFarnaz',
                        fontSize: textScale * 30,
                        color: brand,
                        shadows: <Shadow>[
                          Shadow(
                            offset: Offset.zero,
                            blurRadius: 0,
                            color: colors.shadow,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 3),
                    SpinKitThreeBounce(
                      size: 25,
                      color: brand,
                      duration: const Duration(milliseconds: 2000),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _buildVersionLabel(context),
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: textScale * 18,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _buildVersionLabel(BuildContext context) {
    if (_version == null) {
      return context.l10n.loadingLabel;
    }
    return _numberConvertor
        .replaceArNumber('${context.l10n.version} $_version');
  }
}
