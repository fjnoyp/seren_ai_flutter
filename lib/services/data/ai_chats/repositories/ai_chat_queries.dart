abstract class AiChatQueries {
  /// Params:
  /// - thread_id: String
  static const getThreadMessages = '''
  SELECT *
  FROM ai_chat_messages
  WHERE parent_chat_thread_id = :thread_id
  ORDER BY 
    created_at IS NULL DESC,
    created_at DESC
  LIMIT :limit
  OFFSET :offset;
  ''';

  /// Params:
  /// - user_id: String
  /// - org_id: String
  static const getUserThread = '''
    SELECT *
    FROM ai_chat_threads
    WHERE author_user_id = :user_id
    AND parent_org_id = :org_id
    LIMIT 1;
  ''';
}
