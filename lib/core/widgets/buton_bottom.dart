import 'package:flutter/material.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';

class ButtonBottom extends StatelessWidget {
  const ButtonBottom({
    required this.width,
    required this.height,
    required this.text,
    this.isActive = false,
  });

  final double width;
  final double height;
  final String text;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 1.0,
            // has the effect of softening the shadow
            spreadRadius: 1,
            // has the effect of extending the shadow
            offset: Offset(
              1.0, // horizontal, move right 10
              1.0, // vertical, move down 10
            ),
          )
        ],
        color: isActive ? AppTheme.primary : AppTheme.grey,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              // //fontFamily: 'Iransans',
              fontSize: 24,
              fontWeight: FontWeight.w600,

            ),
            textHeightBehavior: TextHeightBehavior(
              applyHeightToFirstAscent: false,
            ),
            // textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
