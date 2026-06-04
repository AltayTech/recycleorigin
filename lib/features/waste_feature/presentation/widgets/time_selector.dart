import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../business/entities/collect_hour.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import 'package:recycleorigin/l10n/l10n.dart';

/// Horizontal scrollable time-slot picker.
class TimeSelector extends StatelessWidget {
  final List<CollectHour> hours;
  final String? selectedStartHour;
  final Function(CollectHour) onHourSelected;
  final bool isLoading;

  const TimeSelector({
    super.key,
    required this.hours,
    required this.selectedStartHour,
    required this.onHourSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 4,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.iconAccentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  color: AppTheme.iconAccentPurple,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.collectHourSectionTitle,
                style: TextStyle(
                  color: context.colors.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (isLoading)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(
                color: context.appColors.subtitleColor,
              ),
            ),
          )
        else if (hours.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.appColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.appColors.warning.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: context.appColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.noCollectionHoursForRegion,
                    style: TextStyle(
                      color: context.appColors.warning,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 76,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hours.length,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 2),
              itemBuilder: (context, index) {
                final hour = hours[index];
                final isSelected = selectedStartHour == hour.start;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onHourSelected(hour);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: 110,
                    margin: const EdgeInsets.only(
                      right: 10,
                      top: 2,
                      bottom: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary
                          : context.appColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary
                            : context.colors.outline,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: context.colors.shadow
                                    .withValues(alpha: 0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 18,
                          color: isSelected
                              ? context.appColors.onHeroForeground
                                  .withValues(alpha: 0.8)
                              : context.colors.onSurfaceVariant,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatHourRange(
                            hour.start,
                            hour.end,
                          ),
                          style: TextStyle(
                            color: isSelected
                                ? context.appColors.onHeroForeground
                                : context.colors.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  String _formatHourRange(String start, String end) {
    final ds = DateTime.tryParse(start);
    final de = DateTime.tryParse(end);
    if (ds != null && de != null) {
      final a =
          '${ds.hour.toString().padLeft(2, '0')}:${ds.minute.toString().padLeft(2, '0')}';
      final b =
          '${de.hour.toString().padLeft(2, '0')}:${de.minute.toString().padLeft(2, '0')}';
      return '$a–$b';
    }
    final s = start.length >= 5 ? start.substring(0, 5) : start;
    final e = end.length >= 5 ? end.substring(0, 5) : end;
    if (s.length >= 2 && e.length >= 2) {
      return '${s.substring(0, 2)}-${e.substring(0, 2)}';
    }
    return '$s-$e';
  }
}
