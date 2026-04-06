import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// A single tappable card representing one home-screen service.
class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.title,
    this.assetPath,
    this.icon,
    required this.color,
    required this.onTap,
  }) : assert(
          (assetPath == null) != (icon == null),
          'Provide either an assetPath or an icon.',
        );

  final String title;
  final String? assetPath;
  final IconData? icon;
  final Color color;
  final VoidCallback onTap;

  static const _borderRadius = 20.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_borderRadius),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: color.withValues(alpha: 0.08),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(_borderRadius),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: _ServiceIcon(
                            assetPath: assetPath,
                            icon: icon,
                            color: color,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: AppTheme.h1.withValues(alpha: 0.45),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.h1,
                          height: 1.2,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 4,
                    width: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 20,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceIcon extends StatelessWidget {
  const _ServiceIcon({
    required this.assetPath,
    required this.icon,
    required this.color,
  });

  final String? assetPath;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (assetPath != null) {
      return Image.asset(
        assetPath!,
        height: 32,
        width: 32,
        color: color,
        fit: BoxFit.contain,
      );
    }

    return Icon(icon, color: color, size: 30);
  }
}
