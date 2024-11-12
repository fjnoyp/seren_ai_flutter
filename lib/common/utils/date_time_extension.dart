extension DateTimeExtension on DateTime {
  DateTime dateOnlyUTC() {
    return toUtc().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  }

  String getReadableDayOnly() {
    final now = DateTime.now();
    final today = now.dateOnlyUTC();
    final targetDate = dateOnlyUTC();
    
    final dateStr = '${month.toString().padLeft(2)}/${day.toString().padLeft(2)}/${year.toString().substring(2)}';
    
    if (targetDate == today) {
      return 'Today ($dateStr)';
    } else if (targetDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow ($dateStr)';
    } else if (targetDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ($dateStr)';
    }
    
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekdayString = weekdays[weekday - 1];
    return '$weekdayString ($dateStr)';
  }

  String getReadableTimeOnly() {
    return '$hour:$minute';
  }
}
