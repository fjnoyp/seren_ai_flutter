import 'package:intl/intl.dart';

// Help parse dates from AI responses
class AiDateParser {
  static final _dateFormat = DateFormat('yyyy/MM/dd');

  /// Parses a list of date strings in YYYY/MM/DD format or YYYY/MM/DD - YYYY/MM/DD ranges
  /// Returns a list of DateTimes, expanding ranges into individual dates
  static List<DateTime> parseDateList(List<String> dateStrings) {
    final results = <DateTime>[];

    for (final dateStr in dateStrings) {
      try {
        final date = _dateFormat.parse(dateStr, true);
        results.add(date);
      } catch (e) {
        // Skip invalid dates
        continue;
      }
    }

    return results;
  }

  /// Converts an ISO date string from the AI to maintain the same "wall clock time"
  /// in the user's local timezone.
  ///
  /// Example: If AI returns "2023-09-15T15:00:00.000Z" (3PM UTC),
  /// this will return a DateTime representing 3PM in the user's local timezone.
  static DateTime? parseIsoIntoLocal(String? isoString) {
    if (isoString == null) return null;

    try {
      // Parse the original UTC time
      final DateTime utcTime = DateTime.parse(isoString);

      // Create a new DateTime with the same time components but in local timezone
      // This preserves the "wall clock time" the user intended
      final test = DateTime(
        utcTime.year,
        utcTime.month,
        utcTime.day,
        utcTime.hour,
        utcTime.minute,
        utcTime.second,
        utcTime.millisecond,
        utcTime.microsecond,
      );

      print('test: $test');
      print('test.toUtc(): ${test.toUtc()}');
      print('test.toLocal(): ${test.toLocal()}');

      final fuckingUTC = test.toUtc();
      print('fuckingUTC: $fuckingUTC');

      return fuckingUTC;
    } catch (e) {
      // If parsing fails, return null
      return null;
    }
  }

  // static List<DateTime> _expandDateRange(DateTime startDate, DateTime endDate) {
  //   final results = <DateTime>[];
  //   for (var i = 0; i <= endDate.difference(startDate).inDays; i++) {
  //     results.add(startDate.add(Duration(days: i)));
  //   }
  //   return results;
  // }
}
