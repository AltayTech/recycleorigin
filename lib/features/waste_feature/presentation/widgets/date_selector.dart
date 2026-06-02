import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/logic/en_to_ar_number_convertor.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import 'package:recycleorigin/l10n/l10n.dart';

/// Horizontal scrollable date picker with day-of-week and
/// day-month labels. Highlighted selected date with animated
/// transitions.
class DateSelector extends StatelessWidget {
  final List<DateTime> dateList;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateSelector({
    super.key,
    required this.dateList,
    required this.selectedDate,
    required this.onDateSelected,
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
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: Color(0xFF3B82F6),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.collectDateFieldLabel,
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
        SizedBox(
          height: 96,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dateList.length,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            itemBuilder: (context, index) {
              final date = dateList[index];
              final isSelected = _isSameDay(date, selectedDate);

              final locale =
                  Localizations.localeOf(context).toString();
              final dayName =
                  intl.DateFormat('EEE', locale).format(date);
              final dayNum = date.day.toString();
              final monthName =
                  intl.DateFormat('MMM', locale).format(date);
              final converter = EnArConvertor();

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onDateSelected(date);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: 70,
                  margin: const EdgeInsets.only(
                    right: 10,
                    top: 2,
                    bottom: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primary
                          : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primary
                                  .withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color:
                                  Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        converter.replaceArNumber(dayName),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white.withOpacity(0.85)
                              : Colors.grey.shade500,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        converter.replaceArNumber(dayNum),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : context.colors.onSurface,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        converter.replaceArNumber(monthName),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white.withOpacity(0.8)
                              : Colors.grey.shade400,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
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

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
