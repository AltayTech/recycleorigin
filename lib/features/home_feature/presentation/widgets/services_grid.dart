import 'package:flutter/material.dart';

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

/// A 2-column grid of [ServiceCard] widgets.
///
/// The [onNavigate] callback receives the route name so that
/// navigation logic stays in the parent screen, not deep inside
/// widget children.
class ServicesGrid extends StatelessWidget {
  const ServicesGrid({
    super.key,
    required this.descriptors,
  });

  final List<ServiceDescriptor> descriptors;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.crossAxisExtent;
          final crossAxisCount = width >= 1100
              ? 4
              : width >= 720
                  ? 3
                  : 2;
          final childAspectRatio = width >= 720 ? 1.15 : 1.05;

          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = descriptors[index];
                return ServiceCard(
                  title: item.title,
                  assetPath: item.assetPath,
                  icon: item.icon,
                  color: item.color,
                  onTap: item.onTap,
                );
              },
              childCount: descriptors.length,
            ),
          );
        },
      ),
    );
  }
}
