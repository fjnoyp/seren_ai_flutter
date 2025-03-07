abstract class NotificationsQueries {
  /// Params:
  /// - user_id: String
  ///
  /// Used to fetch all push notifications for a user
  static const String pushNotificationsByUserQuery = '''
    SELECT * FROM push_notifications
    WHERE user_ids LIKE '%' || :user_id || '%'
    ORDER BY send_at DESC
  ''';

  /// Params:
  /// - start_date: String (ISO8601 format)
  /// - end_date: String (ISO8601 format)
  ///
  /// Used to fetch all push notifications in a specific date range
  static const String pushNotificationsByDateRangeQuery = '''
    SELECT * FROM push_notifications
    WHERE datetime(send_at) >= datetime(:start_date) AND datetime(send_at) < datetime(:end_date)
    ORDER BY send_at DESC
  ''';
}
