import 'package:flutter/material.dart';

/// A badge widget that displays a value on top of a child widget
/// 
/// Commonly used to show notification counts, cart items, etc.
/// The badge is positioned at the top-right corner of the child.
class Badge extends StatelessWidget {
  const Badge({
    super.key,
    required this.child,
    required this.value,
    this.color = Colors.black12,
    this.textColor = Colors.black54,
    this.badgeSize = 16.0,
    this.fontSize = 10.0,
  });

  /// The widget to display the badge on
  final Widget child;
  
  /// The value to display in the badge
  final String value;
  
  /// Background color of the badge
  final Color color;
  
  /// Text color of the badge
  final Color textColor;
  
  /// Minimum size of the badge
  final double badgeSize;
  
  /// Font size of the badge text
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        child,
        if (value.isNotEmpty)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(badgeSize / 2),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 0.5,
                ),
                color: color,
              ),
              constraints: BoxConstraints(
                minWidth: badgeSize,
                minHeight: badgeSize,
              ),
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    );
  }
}
