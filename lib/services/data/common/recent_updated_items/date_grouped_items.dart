class DateGroupedItems {
  final DateTime date;
  final List<dynamic> items;

  const DateGroupedItems(this.date, this.items);

  /// Returns true if the date is today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Returns true if the date was yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Returns true if the date was within the last week
  bool get isLastWeek {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return date.isAfter(weekAgo) && !isToday && !isYesterday;
  }
}
