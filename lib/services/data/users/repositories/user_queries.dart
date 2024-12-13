abstract class UserQueries {
  /// Params:
  /// - user_id: String
  /// Used to fetch a specific user by their ID
  static const String userByIdQuery = '''
    SELECT *
    FROM users
    WHERE id = :user_id
  ''';

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
  /// - user_id: String
  static const String pendingInvitesByEmailQuery = '''
    SELECT 
      json_object(
        'id', i.id,
        'email', i.email,
        'org_id', i.org_id,
        'org_role', i.org_role,
        'author_user_id', i.author_user_id,
        'status', i.status,
        'created_at', i.created_at,
        'updated_at', i.updated_at
      ) as invite,
      CASE WHEN o.id IS NOT NULL THEN json_object(
        'id', o.id,
        'name', o.name,
        'address', o.address
      ) END as organization,
      CASE WHEN u.id IS NOT NULL THEN json_object(
        'id', u.id,
        'email', u.email,
        'first_name', u.first_name,
        'last_name', u.last_name
      ) END as author_user
    FROM invites i
    LEFT JOIN orgs o ON i.org_id = o.id
    LEFT JOIN users u ON i.author_user_id = u.id
    LEFT JOIN users target_user ON target_user.id = :user_id
    WHERE i.email = target_user.email
    AND i.status = 'pending'
    GROUP BY i.id;
  ''';
}
