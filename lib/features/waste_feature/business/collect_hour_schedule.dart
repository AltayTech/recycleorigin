import 'entities/collect_hour.dart';

/// Decides whether a region slot is offered for a customer-selected calendar day.
class CollectHourSchedule {
  CollectHourSchedule._();

  static bool appliesOnDay(CollectHour hour, DateTime selectedDay) {
    final String p = hour.repeat_pattern.trim().toLowerCase();
    if (p == 'daily' || p.isEmpty) {
      return true;
    }

    final DateTime? anchor = _parseAnchor(hour.start);

    if (p == 'weekly') {
      if (anchor == null) {
        return true;
      }
      return anchor.weekday == selectedDay.weekday;
    }

    if (p == 'none') {
      if (anchor == null) {
        return false;
      }
      return _isSameCalendarDay(anchor, selectedDay);
    }

    return true;
  }

  static bool _isSameCalendarDay(DateTime a, DateTime b) {
    final DateTime la = a.toLocal();
    final DateTime lb = b.toLocal();
    return la.year == lb.year && la.month == lb.month && la.day == lb.day;
  }

  static DateTime? _parseAnchor(String raw) {
    final DateTime? iso = DateTime.tryParse(raw.trim());
    if (iso != null) {
      return iso.toLocal();
    }
    return null;
  }
}
