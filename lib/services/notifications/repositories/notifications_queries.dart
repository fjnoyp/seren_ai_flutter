abstract class NotificationsQueries {
  /// Params:
  /// - user_id: String
  ///
  /// Used to fetch all push notifications for a user
  static const String pushNotificationsByUserQuery = '''
    SELECT * FROM push_notifications
    WHERE user_ids LIKE '%' || :user_id || '%'
    ORDER BY created_at DESC
  ''';
}
