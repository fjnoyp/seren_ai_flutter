abstract class NotificationsQueries {
  /// Params:
  /// - user_id: String
  ///
  /// Used to fetch all sent notifications for a user
  static const String sentNotificationsByUserQuery = '''
    SELECT * FROM push_notifications
    WHERE user_ids LIKE '%' || :user_id || '%'
    AND is_sent = 1
    ORDER BY created_at DESC
  ''';
}
