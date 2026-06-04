import 'package:flutter/material.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/core/theme/theme_context_extensions.dart';

class MainItemButton extends StatelessWidget {
  const MainItemButton({
    super.key,
    required this.title,
    this.itemPaddingF = 10,
    this.imageSizeFactor = 0.35,
    this.imageUrl = '',
    this.isMonoColor = true,
  });

  final String title;
  final String imageUrl;
  final double itemPaddingF;
  final double imageSizeFactor;
  final bool isMonoColor;

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.sizeOf(context).width;
    final labelSize = MediaQuery.textScalerOf(context).scale(18);

    return LayoutBuilder(
      builder: (_, constraint) => Padding(
        padding: EdgeInsets.all(deviceWidth * itemPaddingF),
        child: Container(
          decoration: BoxDecoration(
            color: context.appColors.cardBackground,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.08),
                blurRadius: 10.10,
                spreadRadius: 10.510,
                offset: const Offset(0, 0),
              ),
            ],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 7,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SizedBox(
                      height: constraint.maxHeight * imageSizeFactor,
                      child: Image.asset(
                        imageUrl,
                        fit: BoxFit.contain,
                        color: isMonoColor ? AppTheme.primary : null,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: FittedBox(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.colors.onSurface,
                          fontSize: labelSize,
                        ),
                      ),
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
