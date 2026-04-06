import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Banner image displayed at the top of the home screen.
///
/// Sizes itself to 25 % of the viewport height and applies a
/// subtle gradient overlay so any foreground text remains legible.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  static const _borderRadius = 20.0;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.25;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/main_page_header.png',
              fit: BoxFit.cover,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
