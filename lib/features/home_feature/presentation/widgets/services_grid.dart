import 'package:flutter/material.dart';

import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/theme/app_theme.dart';
import 'service_card.dart';

/// Descriptor for a single entry in the services grid.
class ServiceDescriptor {
  const ServiceDescriptor({
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
}

/// A responsive grid of [ServiceCard] widgets with staggered
/// entrance animations.
///
/// Adapts column count from [AppBreakpoints] (parent width, not full screen).
class ServicesGrid extends StatefulWidget {
  const ServicesGrid({
    super.key,
    required this.descriptors,
  });

  final List<ServiceDescriptor> descriptors;

  @override
  State<ServicesGrid> createState() => _ServicesGridState();
}

class _ServicesGridState extends State<ServicesGrid>
    with SingleTickerProviderStateMixin {
  static const _totalDuration = Duration(milliseconds: 600);
  static const _staggerFraction = 0.15;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _totalDuration,
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount =
            AppBreakpoints.servicesGridCrossAxisCount(width);
        final childAspectRatio =
            AppBreakpoints.servicesGridChildAspectRatio(width);

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: AppTheme.spacingMd,
              mainAxisSpacing: AppTheme.spacingMd,
            ),
            itemCount: widget.descriptors.length,
            itemBuilder: (context, index) {
              final item = widget.descriptors[index];
              final begin = (index * _staggerFraction).clamp(0.0, 0.7);
              final end = (begin + 0.5).clamp(0.0, 1.0);

              final animation = CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  begin,
                  end,
                  curve: Curves.easeOutCubic,
                ),
              );

              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Opacity(
                    opacity: animation.value,
                    child: Transform.translate(
                      offset: Offset(0, 24 * (1 - animation.value)),
                      child: child,
                    ),
                  );
                },
                child: ServiceCard(
                  title: item.title,
                  assetPath: item.assetPath,
                  icon: item.icon,
                  color: item.color,
                  onTap: item.onTap,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
