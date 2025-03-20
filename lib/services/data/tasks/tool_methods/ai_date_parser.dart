import 'package:intl/intl.dart';

// Help parse dates from AI responses
class AiDateParser {
  static final _dateFormat = DateFormat('yyyy/MM/dd');

  static DateTime? parseDate(String dateStr) {
    try {
      return _dateFormat.parse(dateStr, true);
    } catch (e) {
      return null;
    }
  }

  /// Parses a list of date strings in YYYY/MM/DD format or YYYY/MM/DD - YYYY/MM/DD ranges
  /// Returns a list of DateTimes, expanding ranges into individual dates
  static List<DateTime> parseDateList(List<String> dateStrings) {
    final results = <DateTime>[];

    for (final dateStr in dateStrings) {
      final date = parseDate(dateStr);
      if (date != null) {
        results.add(date);
      }
    }

    return results;
  }

  /// Converts an ISO date string from the AI to maintain the same "wall clock time"
  /// in the user's local timezone.
  ///
  /// Example: If AI returns "2023-09-15T15:00:00.000Z" (3PM UTC),
  /// this will return a DateTime representing 3PM in the user's local timezone.
  static DateTime? parseIsoIntoLocalThenUTC(String? isoString) {
    if (isoString == null) return null;

    try {
      // Parse the original UTC time
      final DateTime utcTime = DateTime.parse(isoString);

      // Create a new DateTime with the same time components but in local timezone
      // This preserves the "wall clock time" the user intended
      final parsedDateTime = DateTime(
        utcTime.year,
        utcTime.month,
        utcTime.day,
        utcTime.hour,
        utcTime.minute,
        utcTime.second,
        utcTime.millisecond,
        utcTime.microsecond,
      );
      final parsedDateTimeUtc = parsedDateTime.toUtc();
      return parsedDateTimeUtc;
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
