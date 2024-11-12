import 'package:flutter/material.dart';

extension DateTimeRangeExtension on DateTimeRange {
  bool isOverlapping(DateTimeRange other) {
    return (start.isBefore(other.end) && end.isAfter(other.start)) ||
        (other.start.isBefore(end) && other.end.isAfter(start));
  }

  DateTimeRange toLocal() {
    return DateTimeRange(
      start: start.toLocal(),
      end: end.toLocal(),
    );
  }

  String getReadableTimeOnly() {
    final startHour = start.hour.toString().padLeft(2, '0');
    final startMinute = start.minute.toString().padLeft(2, '0');
    final endHour = end.hour.toString().padLeft(2, '0');
    final endMinute = end.minute.toString().padLeft(2, '0');

    return '$startHour:$startMinute - $endHour:$endMinute';
  }
}
