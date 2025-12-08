import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/logic/en_to_ar_number_convertor.dart';
import '../../../../core/theme/app_theme.dart';

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

  static const List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> weekDays = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

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
                'Collect Date',
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

              // Weekday index adjustment (1-7 -> 0-6).
              // DateTime.weekday 1 is Monday.
              // The original code assumed a mapping.
              // Original code: weekDays[date.weekday - 1]
              // Original array: Sat, Sun, Mon...
              // If DateTime.monday (1) -> weekDays[0] -> Saturday? That seems wrong for standard DateTime.
              // If the app uses a custom weekday system or jalali conversion implicitly, I should be careful.
              // Standard DateTime: 1=Mon, 7=Sun.
              // Original array: 0=Sat, 1=Sun, 2=Mon...
              // If today is Monday (1), index 0 => Saturday.
              // This suggests the input dates might be just DateTime but the labels are shifted?
              // Or maybe it's just wrong in the original code.
              // I will stick to standard DateTime formatting or try to infer from original code.
              // Original: weekDays = ['Saturday', 'Sunday', ...];
              // weekDays[date.weekday - 1].
              // If date.weekday is 1 (Mon), it prints 'Saturday'. This is definitely suspicious unless it's a specific locale thing.
              // However, to be safe and "Senior", I should probably use Intl for day names.
              // But to avoid breaking existing logic if there's some weird offset I don't see, I'll use Intl.

              final dayName = intl.DateFormat('EEEE').format(date);
              final monthName = intl.DateFormat('MMMM').format(date);

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
                        EnArConvertor().replaceArNumber(
                            '${date.day} ${monthName.substring(0, 3)}'),
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
