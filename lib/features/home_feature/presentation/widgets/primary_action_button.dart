import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'package:recycleorigin/l10n/l10n.dart';

/// Full-width gradient CTA that navigates to the collection request
/// flow.
class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    super.key,
    required this.onPressed,
    this.useLightSurface = false,
  });

  /// Invoked when the user taps the button.
  final VoidCallback onPressed;
  final bool useLightSurface;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = useLightSurface ? Colors.white : null;
    final foregroundColor = useLightSurface ? AppTheme.primary : Colors.white;
    final secondaryColor = useLightSurface
        ? AppTheme.primary.withValues(alpha: 0.1)
        : Colors.white.withValues(alpha: 0.16);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: useLightSurface ? 0 : 20,
        vertical: 4,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: useLightSurface
                  ? Colors.black.withValues(alpha: 0.12)
                  : AppTheme.primary.withValues(alpha: 0.3),
              blurRadius: useLightSurface ? 20 : 16,
              spreadRadius: useLightSurface ? 0 : 2,
              offset: const Offset(0, 10),
            ),
          ],
          gradient: useLightSurface
              ? null
              : LinearGradient(
                  colors: [AppTheme.primary, AppTheme.accent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 62,
              child: Row(
                children: [
                  const SizedBox(width: 18),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.recycling_rounded,
                        color: foregroundColor,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      context.l10n.requestCollectionHeroTitle,
                      style: TextStyle(
                        color: foregroundColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: foregroundColor,
                    size: 24,
                  ),
                  const SizedBox(width: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
