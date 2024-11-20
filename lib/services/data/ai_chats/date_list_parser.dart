import 'package:intl/intl.dart';

class DateListParser {
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

    if (results.length == 2) {
      final [startDate, endDate] = results;
      results.addAll(
          _expandDateRange(startDate, endDate));
    }

    return results;
  }

  static List<DateTime> _expandDateRange(DateTime startDate, DateTime endDate) {
    final results = <DateTime>[];
    for (var i = 0; i <= endDate.difference(startDate).inDays; i++) {
      results.add(startDate.add(Duration(days: i)));
    }
    return results;
  }
}
