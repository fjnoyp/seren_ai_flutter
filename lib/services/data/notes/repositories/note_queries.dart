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
}
