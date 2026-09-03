import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/waste.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_context_extensions.dart';

/// Grid tile representing a single waste category that can
/// be toggled on/off to add to / remove from the cart.
class WasteItemWastesScreen extends StatelessWidget {
  final Waste waste;
  final bool isSelected;
  final VoidCallback? onTap;

  const WasteItemWastesScreen({
    super.key,
    required this.waste,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary.withValues(alpha: 0.06)
                : context.appColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppTheme.primary : context.colors.outline,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: context.colors.shadow.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Center(
                        child: FadeInImage(
                          placeholder: const AssetImage(
                            'assets/images/circle.gif',
                          ),
                          image: NetworkImage(
                            waste.featured_image.sizes.medium,
                          ),
                          fit: BoxFit.contain,
                          imageErrorBuilder: (_, __, ___) => Icon(
                            Icons.recycling_rounded,
                            size: 36,
                            color: context.appColors.subtitleColor.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: Text(
                        waste.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.primary
                              : context.colors.onSurface,
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: AnimatedScale(
                    scale: isSelected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: context.appColors.cardBackground,
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
