import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DateGroupedItems {
  final DateTime? date;
  final List<dynamic> items;

  const DateGroupedItems(this.date, this.items);

  /// Returns true if the date is today
  bool get isToday {
    if (date == null) return false;
    final now = DateTime.now();
    return date!.year == now.year &&
        date!.month == now.month &&
        date!.day == now.day;
  }

  /// Returns true if the date was yesterday
  bool get isYesterday {
    if (date == null) return false;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date!.year == yesterday.year &&
        date!.month == yesterday.month &&
        date!.day == yesterday.day;
  }

  /// Returns true if the date was within the last week
  bool get isLastWeek {
    if (date == null) return false;
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return date!.isAfter(weekAgo) && !isToday && !isYesterday;
  }

  String getDateHeader(BuildContext context) {
    if (date == null) {
      return AppLocalizations.of(context)?.unscheduled ?? 'Unscheduled';
    }
    if (isToday) {
      return AppLocalizations.of(context)?.today ?? 'Today';
    }
    if (isYesterday) {
      return AppLocalizations.of(context)?.yesterday ?? 'Yesterday';
    }
    if (isLastWeek) {
      return DateFormat.EEEE(AppLocalizations.of(context)?.localeName)
          .format(date!);
    }
    return DateFormat.yMMMd(AppLocalizations.of(context)?.localeName)
        .format(date!);
  }
}
