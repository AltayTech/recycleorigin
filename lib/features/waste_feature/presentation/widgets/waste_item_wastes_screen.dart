import 'package:flutter/material.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/waste.dart';
import '../../../../core/theme/app_theme.dart';

class WasteItemWastesScreen extends StatelessWidget {
  final Waste waste;
  final bool isSelected;
  final VoidCallback? onTap;

  const WasteItemWastesScreen({
    Key? key,
    required this.waste,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppTheme.primary : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Center(
                        child: FadeInImage(
                          placeholder:
                              const AssetImage('assets/images/circle.gif'),
                          image:
                              NetworkImage(waste.featured_image.sizes.medium),
                          fit: BoxFit.contain,
                          imageErrorBuilder: (context, error, stackTrace) =>
                              Icon(
                            Icons.image_not_supported_outlined,
                            size: 40,
                            color: AppTheme.grey.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 4.0),
                      child: Center(
                        child: Text(
                          waste.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? AppTheme.primary : AppTheme.h1,
                            fontSize: textScaleFactor * 14.0,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (isSelected)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check,
                      size: 14,
                      color: AppTheme.white,
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
