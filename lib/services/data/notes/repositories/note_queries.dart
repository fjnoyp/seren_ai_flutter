abstract class NoteQueries {
  /// Params:
  /// - user_id: String
  static const getUserPersonalNotes = '''
      SELECT * 
      FROM notes
      WHERE parent_project_id IS NULL
      AND author_user_id = :user_id
      ORDER BY created_at DESC
    ''';

  /// Params:
  /// - project_id: String
  static const getProjectNotes = '''
      SELECT * 
      FROM notes
      WHERE parent_project_id = :project_id
      ORDER BY created_at DESC
    ''';

  /// Params:
  /// - user_id: String
  static const String getUserPersonalJoinedNotes = '''
    SELECT 
      json_object(
        'id', n.id,
        'name', n.name,
        'date', n.date,
        'address', n.address,
        'description', n.description,
        'action_required', n.action_required,
        'status', n.status,
        'author_user_id', n.author_user_id,
        'parent_project_id', n.parent_project_id,
        'created_at', n.created_at,
        'updated_at', n.updated_at
      ) as note,
      CASE WHEN u.id IS NOT NULL THEN json_object(
        'id', u.id,
        'email', u.email,
        'first_name', u.first_name,
        'last_name', u.last_name,
        'parent_auth_user_id', u.parent_auth_user_id,
        'default_project_id', u.default_project_id,
        'default_team_id', u.default_team_id,
        'created_at', u.created_at,
        'updated_at', u.updated_at
      ) END as author_user,
      CASE WHEN p.id IS NOT NULL THEN json_object(
        'id', p.id,
        'name', p.name,
        'description', p.description,
        'address', p.address,
        'parent_org_id', p.parent_org_id,
        'created_at', p.created_at,
        'updated_at', p.updated_at
      ) END as project
    FROM notes n
    LEFT JOIN users u ON n.author_user_id = u.id
    LEFT JOIN projects p ON n.parent_project_id = p.id
    WHERE n.parent_project_id IS NULL
    AND n.author_user_id = :user_id
    ORDER BY n.created_at DESC;
  ''';

  /// Params:
  /// - project_id: String
  static const String getProjectJoinedNotes = '''
    SELECT 
      json_object(
        'id', n.id,
        'name', n.name,
        'date', n.date,
        'address', n.address,
        'description', n.description,
        'action_required', n.action_required,
        'status', n.status,
        'author_user_id', n.author_user_id,
        'parent_project_id', n.parent_project_id,
        'created_at', n.created_at,
        'updated_at', n.updated_at
      ) as note,
      CASE WHEN u.id IS NOT NULL THEN json_object(
        'id', u.id,
        'email', u.email,
        'first_name', u.first_name,
        'last_name', u.last_name,
        'parent_auth_user_id', u.parent_auth_user_id,
        'default_project_id', u.default_project_id,
        'default_team_id', u.default_team_id,
        'created_at', u.created_at,
        'updated_at', u.updated_at
      ) END as author_user,
      CASE WHEN p.id IS NOT NULL THEN json_object(
        'id', p.id,
        'name', p.name,
        'description', p.description,
        'address', p.address,
        'parent_org_id', p.parent_org_id,
        'created_at', p.created_at,
        'updated_at', p.updated_at
      ) END as project
    FROM notes n
    LEFT JOIN users u ON n.author_user_id = u.id
    LEFT JOIN projects p ON n.parent_project_id = p.id
    WHERE n.parent_project_id = :project_id
    ORDER BY n.created_at DESC;
  ''';

  /// Params:
  /// - note_id: String
  static const String getJoinedNote = '''
    SELECT 
      json_object(
        'id', n.id,
        'name', n.name,
        'date', n.date,
        'address', n.address,
        'description', n.description,
        'action_required', n.action_required,
        'status', n.status,
        'author_user_id', n.author_user_id,
        'parent_project_id', n.parent_project_id,
        'created_at', n.created_at,
        'updated_at', n.updated_at
      ) as note,
      CASE WHEN u.id IS NOT NULL THEN json_object(
        'id', u.id,
        'email', u.email,
        'first_name', u.first_name,
        'last_name', u.last_name,
        'parent_auth_user_id', u.parent_auth_user_id,
        'default_project_id', u.default_project_id,
        'default_team_id', u.default_team_id,
        'created_at', u.created_at,
        'updated_at', u.updated_at
      ) END as author_user,
      CASE WHEN p.id IS NOT NULL THEN json_object(
        'id', p.id,
        'name', p.name,
        'description', p.description,
        'address', p.address,
        'parent_org_id', p.parent_org_id,
        'created_at', p.created_at,
        'updated_at', p.updated_at
      ) END as project
    FROM notes n
    LEFT JOIN users u ON n.author_user_id = u.id
    LEFT JOIN projects p ON n.parent_project_id = p.id
    WHERE n.id = :note_id
    LIMIT 1;
  ''';
}
