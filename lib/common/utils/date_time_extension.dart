import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension DateTimeExtension on DateTime {
  DateTime dateOnlyUTC() {
    return toUtc().copyWith(
        hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  }

  String getReadableDayOnly(BuildContext context) {
    final now = DateTime.now();
    final today = now.dateOnlyUTC();
    final targetDate = dateOnlyUTC();

    final dateStr = DateFormat.yMd(AppLocalizations.of(context)!.localeName)
        .format(targetDate);

    if (targetDate == today) {
      return AppLocalizations.of(context)!.todayDate(dateStr);
    } else if (targetDate == today.add(const Duration(days: 1))) {
      return AppLocalizations.of(context)!.tomorrowDate(dateStr);
    } else if (targetDate == today.subtract(const Duration(days: 1))) {
      return AppLocalizations.of(context)!.yesterdayDate(dateStr);
    }

    final weekdayString =
        DateFormat.EEEE(AppLocalizations.of(context)!.localeName)
            .format(targetDate);
    return '$weekdayString ($dateStr)';
  }

  String toSimpleDateString() {
    return toString().split(' ')[0];
  }

  String toSimpleTimeString() {
    return '$hour:${minute.toString().padLeft(2, '0')}';
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isSameWeek(DateTime other) {
    // Get the start of the week for both dates
    final thisWeekStart = DateTime(other.year, other.month, other.day)
        .subtract(Duration(days: other.weekday - 1));
    final otherWeekStart =
        DateTime(year, month, day).subtract(Duration(days: weekday - 1));

    return thisWeekStart.isAtSameMomentAs(otherWeekStart);
  }

  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  bool isAfterOrAt(DateTime other) {
    return isAfter(other) || isAtSameMomentAs(other);
  }

  bool isBeforeOrAt(DateTime other) {
    return isBefore(other) || isAtSameMomentAs(other);
  }
}
