import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/logic/en_to_ar_number_convertor.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:recycleorigin/l10n/l10n.dart';

class DateSelector extends StatelessWidget {
  final List<DateTime> dateList;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateSelector({
    Key? key,
    required this.dateList,
    required this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  color: AppTheme.grey, size: 20),
              const SizedBox(width: 8),
              Text(
                context.l10n.collectDateFieldLabel,
                style: TextStyle(
                  color: AppTheme.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dateList.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final date = dateList[index];
              final isSelected = _isSameDay(date, selectedDate);

              final locale = Localizations.localeOf(context).toString();
              final dayName = intl.DateFormat('EEEE', locale).format(date);
              final monthName = intl.DateFormat('MMM', locale).format(date);

              return GestureDetector(
                onTap: () => onDateSelected(date),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : AppTheme.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: isSelected
                        ? Border.all(color: AppTheme.primary)
                        : Border.all(color: Colors.transparent),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        EnArConvertor().replaceArNumber(dayName),
                        style: TextStyle(
                          color: isSelected ? AppTheme.white : AppTheme.h1,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        EnArConvertor()
                            .replaceArNumber('${date.day} $monthName'),
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.white.withOpacity(0.9)
                              : AppTheme.grey,
                          fontSize: 12,
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
