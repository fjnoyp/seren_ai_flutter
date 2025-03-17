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
  static const getDefaultProjectNotesAndPersonalNotes = '''
      SELECT notes.* 
      FROM notes
      INNER JOIN users ON users.id = :user_id
      WHERE (notes.parent_project_id = users.default_project_id
            OR (notes.parent_project_id IS NULL AND notes.author_user_id = :user_id))
      ORDER BY notes.created_at DESC
    ''';

  static const recentlyUpdatedNotesQuery = '''
    SELECT DISTINCT n.*
    FROM notes n
    LEFT JOIN projects p ON n.parent_project_id = p.id
    LEFT JOIN user_project_assignments pua ON p.id = pua.project_id AND pua.user_id = :user_id
    LEFT JOIN user_org_roles uor ON uor.org_id = p.parent_org_id AND uor.user_id = :user_id AND uor.org_role = 'admin'
    WHERE (
      n.parent_project_id IS NULL AND n.author_user_id = :user_id
      OR (
        n.parent_project_id IS NOT NULL
        AND (
          pua.user_id IS NOT NULL
          OR uor.user_id IS NOT NULL
          OR n.author_user_id = :user_id
        )
      )
    )
    ORDER BY n.updated_at DESC
    LIMIT :limit
  ''';

  /// Params:
  /// - user_id: String
  /// - org_id: String
  static const getAllNotesByUserAndOrg = '''
    SELECT DISTINCT n.*
    FROM notes n
    LEFT JOIN user_project_assignments upa ON n.parent_project_id = upa.project_id AND upa.user_id = :user_id
    LEFT JOIN projects p ON n.parent_project_id = p.id AND p.parent_org_id = :org_id
    LEFT JOIN user_org_roles uor ON p.parent_org_id = uor.org_id AND uor.user_id = :user_id AND uor.org_role = 'admin'
    WHERE (
      (n.parent_project_id IS NULL AND n.author_user_id = :user_id) -- Personal notes
      OR upa.user_id IS NOT NULL -- Notes from projects the user is assigned to
      OR uor.user_id IS NOT NULL -- Notes from projects where user has org admin access
      OR n.author_user_id = :user_id -- Notes authored by the user (in any project)
    )
    ORDER BY n.created_at DESC
  ''';
}
