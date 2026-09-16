import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/theme_context_extensions.dart';

/// Success confirmation shown after submitting a request, order, or similar action.
///
/// Uses the app primary color, accessible tap targets, and scales text via
/// [MediaQuery.textScalerOf] instead of multiplying font sizes by a scale factor.
class CustomDialogSendRequest extends StatelessWidget {
  const CustomDialogSendRequest({
    super.key,
    this.title,
    required this.description,
    this.buttonText = 'OK',
  });

  /// Optional headline above the message. Omit or pass empty to hide.
  final String? title;

  final String description;
  final String buttonText;

  static Future<void> show(
    BuildContext context, {
    String? title,
    required String description,
    String buttonText = 'OK',
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: context.colors.shadow.withValues(alpha: 0.45),
      builder: (ctx) => CustomDialogSendRequest(
        title: title,
        description: description,
        buttonText: buttonText,
      ),
    );
  }

  bool get _hasTitle => title != null && title!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final scheme = theme.colorScheme;

    return Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      shadowColor: context.colors.shadow.withValues(alpha: 0.2),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary.withValues(alpha: 0.12),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/send_popup_tick.png',
                    height: 52,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_hasTitle) ...[
                Text(
                  title!.trim(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: textScaler.scale(17),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: context.colors.onSurface,
                  height: 1.45,
                  fontSize: textScaler.scale(15),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: context.appColors.onHeroForeground,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: textScaler.scale(16),
                      fontWeight: FontWeight.w600,
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
