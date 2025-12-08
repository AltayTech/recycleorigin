import 'package:flutter/material.dart';
import '../../business/entities/collect_hour.dart';
import '../../../../core/theme/app_theme.dart';

class TimeSelector extends StatelessWidget {
  final List<CollectHour> hours;
  final String? selectedStartHour;
  final Function(CollectHour) onHourSelected;
  final bool isLoading;

  const TimeSelector({
    Key? key,
    required this.hours,
    required this.selectedStartHour,
    required this.onHourSelected,
    this.isLoading = false,
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
              Icon(Icons.access_time_rounded, color: AppTheme.grey, size: 20),
              const SizedBox(width: 8),
              Text(
                'Collect Hour',
                style: TextStyle(
                  color: AppTheme.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (hours.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No available hours for this region.',
              style: TextStyle(color: AppTheme.grey),
            ),
          )
        else
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hours.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final hour = hours[index];
                final isSelected = selectedStartHour == hour.start;

                return GestureDetector(
                  onTap: () => onHourSelected(hour),
                  child: Container(
                    width: 100,
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
                    child: Center(
                      child: Text(
                        _formatHourRange(hour.start, hour.end),
                        style: TextStyle(
                          color: isSelected ? AppTheme.white : AppTheme.h1,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
    // Format HH:mm if possible
    final s = start.length >= 5 ? start.substring(0, 5) : start;
    final e = end.length >= 5 ? end.substring(0, 5) : end;

    if (s.length >= 2 && e.length >= 2) {
      return "${s.substring(0, 2)}-${e.substring(0, 2)}";
    }
    return "$s-$e";
  }
}
