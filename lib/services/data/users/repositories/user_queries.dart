abstract class UserQueries {
  /// Params:
  /// - user_ids: List<String>
  /// Used to fetch specific users by their IDs
  static const String usersByIdQuery = '''
    SELECT *
    FROM users
    WHERE id IN (:user_ids)
  ''';

  /// Params:
  /// - project_id: String
  /// Used to fetch all users that are assigned to a specific project
  /// either directly or through a team assignment
  static const String usersInProjectQuery = '''
    SELECT DISTINCT u.*
    FROM users u
    LEFT JOIN user_project_assignments upa ON u.id = upa.user_id
    LEFT JOIN user_team_assignments uta ON u.id = uta.user_id
    LEFT JOIN team_project_assignments tpa ON uta.team_id = tpa.team_id
    WHERE upa.project_id = :project_id
    OR tpa.project_id = :project_id
  ''';

  /// Params:
  /// - user_email: String
  static const String invitesByEmailQuery = '''
    SELECT *
    FROM invites
    WHERE email = :user_email
    ORDER BY created_at DESC;
  ''';

  /// Params:
  /// - task_id: String
  ///
  /// Used to fetch all users that are assigned to a specific task
  static const String getTaskAssignedUsersQuery = '''
    SELECT DISTINCT u.*
    FROM users u
    INNER JOIN task_user_assignments tua ON u.id = tua.user_id
    WHERE tua.task_id = :task_id;
  ''';

  /// Params:
  /// - task_id: String
  ///
  /// Used to fetch all user IDs that are assigned to a specific task
  static const String getTaskAssignedUserIdsQuery = '''
    SELECT u.id
    FROM users u  
    INNER JOIN task_user_assignments tua ON u.id = tua.user_id
    WHERE tua.task_id = :task_id;
  ''';
}
