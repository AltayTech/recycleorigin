import 'package:flutter/material.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/core/theme/theme_context_extensions.dart';

/// Reusable call-to-action button used across the waste
/// collection flow (cart, address, date, confirm screens).
class ButtonBottom extends StatelessWidget {
  const ButtonBottom({
    super.key,
    required this.width,
    required this.height,
    required this.text,
    this.isActive = false,
    this.icon,
  });

  final double width;
  final double height;
  final String text;
  final bool isActive;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fgColor = context.appColors.onHeroForeground;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                colors: [
                  AppTheme.primary,
                  AppTheme.primary.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color:
            isActive ? null : context.appColors.subtitleColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: fgColor, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              color: fgColor,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
