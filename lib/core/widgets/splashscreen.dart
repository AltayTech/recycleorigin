import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../theme/theme_context_extensions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.loaderColor,
    required this.seconds,
    this.photoSize = 100,
    this.onClick,
    this.navigateAfterSeconds,
    this.title = const Text(''),
    this.backgroundColor,
    this.styleTextUnderTheLoader,
    required this.image,
    this.loadingText = const Text(''),
    this.imageBackground = const AssetImage(
      'assets/images/main_page_request_ic.png',
    ),
    this.gradientBackground,
  });

  final Color? loaderColor;
  final int seconds;
  final double photoSize;
  final VoidCallback? onClick;
  final dynamic navigateAfterSeconds;
  final Text title;
  final Color? backgroundColor;
  final TextStyle? styleTextUnderTheLoader;
  final Image image;
  final Text loadingText;
  final ImageProvider imageBackground;
  final Gradient? gradientBackground;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: widget.seconds), () {
      if (widget.navigateAfterSeconds is String) {
        Navigator.of(context).pushReplacementNamed(widget.navigateAfterSeconds);
      } else if (widget.navigateAfterSeconds is Widget) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => widget.navigateAfterSeconds,
          ),
        );
      } else {
        throw ArgumentError(
          'widget.navigateAfterSeconds must either be a String or Widget',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final appColors = context.appColors;
    final loaderColor = widget.loaderColor ?? colors.primary;
    final backgroundColor =
        widget.backgroundColor ?? appColors.scaffoldBackground;
    final gradientBackground = widget.gradientBackground ??
        LinearGradient(
          colors: [
            appColors.scaffoldBackground,
            appColors.scaffoldBackground.withValues(alpha: 0.92),
          ],
        );
    final textStyle = widget.styleTextUnderTheLoader ??
        TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colors.onSurface,
        );

    return Scaffold(
      body: InkWell(
        onTap: widget.onClick,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: widget.imageBackground,
                ),
                gradient: gradientBackground,
                color: backgroundColor,
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.8,
                        child: widget.image,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                      ),
                      widget.title,
                    ],
                  ),
                ),
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.04,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SpinKitThreeBounce(
                        size: 25,
                        duration: const Duration(milliseconds: 2000),
                        itemBuilder: (BuildContext context, int index) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: loaderColor,
                            ),
                          );
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                      ),
                      DefaultTextStyle(
                        style: textStyle,
                        child: widget.loadingText,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
