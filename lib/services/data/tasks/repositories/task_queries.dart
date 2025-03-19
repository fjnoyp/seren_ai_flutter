abstract class TaskQueries {
  /// Params:
  /// - user_id: String
  /// - org_id: String
  ///
  /// Used to fetch tasks of an organization where the user is either:
  /// 1. Assigned to the project containing the task
  /// 2. The author of the task
  /// 3. An admin of the organization that owns the project
  static const String userViewableTasksQuery = '''
  SELECT DISTINCT t.*
  FROM tasks t
  INNER JOIN projects p ON t.parent_project_id = p.id
  LEFT JOIN user_project_assignments pua ON t.parent_project_id = pua.project_id AND pua.user_id = :user_id
  LEFT JOIN user_org_roles uor ON uor.org_id = p.parent_org_id AND uor.user_id = :user_id AND uor.org_role = 'admin'
  WHERE p.parent_org_id = :org_id
  AND (
    pua.user_id IS NOT NULL
    OR uor.user_id IS NOT NULL
  )
  ORDER BY 
    CASE 
      WHEN t.due_date IS NULL THEN 1 
      ELSE 0 
    END,
    t.due_date ASC,
    t.priority DESC,
    t.created_at DESC;
''';

  // Suddenly stopped working
  // TODO p3: support team based access control
  // '''
  //   SELECT DISTINCT t.*
  //   FROM tasks t
  //   LEFT JOIN user_project_assignments pua ON t.parent_project_id = pua.project_id
  //   LEFT JOIN team_project_assignments tpa ON t.parent_project_id = tpa.project_id
  //   LEFT JOIN user_team_assignments uta ON tpa.team_id = uta.team_id
  //   LEFT JOIN projects p ON t.parent_project_id = p.id AND p.parent_org_id = :org_id
  //   LEFT JOIN user_org_roles uor ON uor.org_id = :org_id AND uor.user_id = :user_id
  //   WHERE pua.user_id = :user_id
  //   OR uta.user_id = :user_id
  //   OR t.author_user_id = :user_id
  //   OR uor.org_role = 'admin';
  //   ''';

  /// Params:
  /// - user_id: String
  /// - org_id: String
  ///
  /// Used to fetch tasks where the user is directly assigned to the task
  /// and the task belongs to the specified organization
  static const String userAssignedTasksQuery = '''
    SELECT DISTINCT t.*
    FROM tasks t
    INNER JOIN projects p ON t.parent_project_id = p.id
    INNER JOIN task_user_assignments tua ON t.id = tua.task_id
    WHERE tua.user_id = :user_id
    AND p.parent_org_id = :org_id
    ORDER BY 
      CASE 
        WHEN t.due_date IS NULL THEN 1 
        ELSE 0 
      END,
      t.due_date ASC,
      t.priority DESC,
      t.created_at DESC;
  ''';

  /// Params:
  /// - task_id: String
  static const String taskCommentsQuery = '''
    SELECT * 
    FROM task_comments 
    WHERE parent_task_id = :task_id
    ORDER BY created_at DESC
  ''';

  /// Params:
  /// - parent_task_id: String
  static const String getTasksByParentIdQuery = '''
    SELECT * FROM tasks WHERE parent_task_id = :parent_task_id;
  ''';

  /// Params:
  /// - task_id: String
  static const String getTaskUserAssignmentsQuery = '''
    SELECT * FROM task_user_assignments WHERE task_id = :task_id;
  ''';

  /// Params:
  /// - task_id: String
  /// - user_id: String
  static const String getTaskUserAssignmentIdQuery = '''
    SELECT id FROM task_user_assignments WHERE task_id = :task_id AND user_id = :user_id;
  ''';

  /// Params:
  /// - project_id: String
  static const String getTasksByProjectIdQuery = '''
    SELECT * FROM tasks WHERE parent_project_id = :project_id;
  ''';

  /// Params:
  /// - project_id: String
  static const String getParentTasksByProjectIdQuery = '''
    SELECT * FROM tasks WHERE parent_project_id = :project_id AND type = 'phase';
  ''';

  static const recentlyUpdatedTasksQuery = '''
    SELECT DISTINCT t.*
    FROM tasks t
    INNER JOIN projects p ON t.parent_project_id = p.id
    LEFT JOIN user_project_assignments pua ON t.parent_project_id = pua.project_id AND pua.user_id = :user_id
    LEFT JOIN user_org_roles uor ON uor.org_id = p.parent_org_id AND uor.user_id = :user_id AND uor.org_role = 'admin'
    WHERE p.parent_org_id = :org_id
    AND (
      pua.user_id IS NOT NULL
      OR uor.user_id IS NOT NULL
      OR t.author_user_id = :user_id
    )
    ORDER BY t.updated_at DESC
    LIMIT :limit
  ''';

  /// Params:
  /// - task_id: String
  static const String getTaskParentOrgIdQuery = '''
    SELECT p.parent_org_id
    FROM tasks t
    JOIN projects p ON t.parent_project_id = p.id
    WHERE t.id = :task_id
    ''';
}
