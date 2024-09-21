import 'package:flutter/material.dart';

extension DateTimeRangeExtension on DateTimeRange {
  bool isOverlapping(DateTimeRange other) {
    return (start.isBefore(other.end) && end.isAfter(other.start)) ||
           (other.start.isBefore(end) && other.end.isAfter(start));
  }
}