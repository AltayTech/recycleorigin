import 'package:flutter/material.dart';

class CollectHour with ChangeNotifier {
  final String start;
  final String end;
  final bool collect_hour_status;

  CollectHour({
    required this.start,
    required this.end,
    required this.collect_hour_status,
  });

  factory CollectHour.fromJson(Map<String, dynamic> parsedJson) {
    return CollectHour(
      start: parsedJson['start']?.toString() ?? '',
      end: parsedJson['end']?.toString() ?? '',
      collect_hour_status: parsedJson['collect_hour_status'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'start': start,
        'end': end,
        'collect_hour_status': collect_hour_status,
      };
}
