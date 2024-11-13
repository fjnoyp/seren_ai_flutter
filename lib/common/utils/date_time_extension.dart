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
      return AppLocalizations.of(context)!.today(dateStr);
    } else if (targetDate == today.add(const Duration(days: 1))) {
      return AppLocalizations.of(context)!.tomorrow(dateStr);
    } else if (targetDate == today.subtract(const Duration(days: 1))) {
      return AppLocalizations.of(context)!.yesterday(dateStr);
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
}
