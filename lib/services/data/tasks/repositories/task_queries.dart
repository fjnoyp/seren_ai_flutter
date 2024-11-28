abstract class TaskQueries {
  /// Params:
  /// - user_id: String
  /// - author_user_id: String
  static const String userViewableTasksQuery = '''
    SELECT DISTINCT t.*
    FROM tasks t
    LEFT JOIN user_project_assignments pua ON t.parent_project_id = pua.project_id
    LEFT JOIN team_project_assignments tpa ON t.parent_project_id = tpa.project_id
    LEFT JOIN user_team_assignments uta ON tpa.team_id = uta.team_id
    WHERE pua.user_id = :user_id
    OR uta.user_id = :user_id
    OR t.author_user_id = :author_user_id;
    ''';

  /// Params:
  /// - user_id: String
  static const String userTaskAssignmentsQuery = '''
    SELECT DISTINCT tua.*
    FROM task_user_assignments tua
    LEFT JOIN tasks t ON t.id = tua.task_id 
    WHERE tua.user_id = :user_id
    OR t.author_user_id = :user_id
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
  /// - task_id: String
  static const String joinedTaskQuery = '''
    SELECT
      json_object(
        'id', t.id,
        'name', t.name,
        'description', t.description,
        'status', t.status,
        'priority', t.priority,
        'due_date', t.due_date,
        'created_date', t.created_date,
        'last_updated_date', t.last_updated_date,
        'author_user_id', t.author_user_id,
        'parent_project_id', t.parent_project_id,
        'estimated_duration_minutes', t.estimated_duration_minutes,
        'created_at', t.created_at,
        'updated_at', t.updated_at
      ) as task,
      CASE WHEN u.id IS NOT NULL THEN
        json_object(
          'id', u.id,
          'email', u.email,
          'first_name', u.first_name,
          'last_name', u.last_name,
          'parent_auth_user_id', u.parent_auth_user_id,
          'default_project_id', u.default_project_id,
          'default_team_id', u.default_team_id,
          'created_at', u.created_at,
          'updated_at', u.updated_at
        )
      ELSE NULL END as author_user,
      CASE WHEN p.id IS NOT NULL THEN
        json_object(
          'id', p.id,
          'name', p.name,
          'description', p.description,
          'address', p.address,
          'parent_org_id', p.parent_org_id,
          'created_at', p.created_at,
          'updated_at', p.updated_at
        )
      ELSE NULL END as project,
      (
        SELECT json_group_array(
          json_object(
            'id', au.id,
            'email', au.email,
            'first_name', au.first_name,
            'last_name', au.last_name,
            'parent_auth_user_id', au.parent_auth_user_id,
            'default_project_id', au.default_project_id,
            'default_team_id', au.default_team_id,
            'created_at', au.created_at,
            'updated_at', au.updated_at
          )
        )
        FROM task_user_assignments tua
        LEFT JOIN users au ON tua.user_id = au.id
        WHERE tua.task_id = t.id
      ) as assignees,
      (
        SELECT json_group_array(
          json_object(
            'id', tc.id,
            'content', tc.content,
            'author_user_id', tc.author_user_id,
            'parent_task_id', tc.parent_task_id,
            'created_date', tc.created_date,
            'start_datetime', tc.start_datetime,
            'end_datetime', tc.end_datetime,
            'created_at', tc.created_at,
            'updated_at', tc.updated_at
          )
        )
        FROM task_comments tc
        WHERE tc.parent_task_id = t.id
      ) as comments
    FROM tasks t
    LEFT JOIN users u ON t.author_user_id = u.id
    LEFT JOIN projects p ON t.parent_project_id = p.id
    WHERE t.id = :task_id
  ''';

  /// Params:
  /// - task_id: String
  static const String joinedTaskCommentsQuery = '''
    SELECT
      json_object(
        'id', tc.id,
        'content', tc.content,
        'author_user_id', tc.author_user_id,
        'parent_task_id', tc.parent_task_id,
        'created_date', tc.created_date,
        'start_datetime', tc.start_datetime,
        'end_datetime', tc.end_datetime,
        'created_at', tc.created_at,
        'updated_at', tc.updated_at
      ) as comment,
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
      CASE WHEN t.id IS NOT NULL THEN json_object(
        'id', t.id,
        'name', t.name,
        'description', t.description,
        'status', t.status,
        'priority', t.priority,
        'due_date', t.due_date,
        'created_date', t.created_date,
        'last_updated_date', t.last_updated_date,
        'author_user_id', t.author_user_id,
        'parent_project_id', t.parent_project_id,
        'estimated_duration_minutes', t.estimated_duration_minutes,
        'created_at', t.created_at,
        'updated_at', t.updated_at
      ) END as parent_task
    FROM task_comments tc
    LEFT JOIN users u ON tc.author_user_id = u.id
    LEFT JOIN tasks t ON tc.parent_task_id = t.id
    WHERE tc.parent_task_id = :task_id
  ''';

  /// Params:
  /// - task_id: String
  static const String joinedTaskUserAssignmentsQuery = '''
    SELECT
      json_object(
        'id', tua.id,
        'task_id', tua.task_id,
        'user_id', tua.user_id,
        'created_at', tua.created_at,
        'updated_at', tua.updated_at
      ) as assignment,
      json_object(
        'id', u.id,
        'email', u.email,
        'first_name', u.first_name,
        'last_name', u.last_name,
        'parent_auth_user_id', u.parent_auth_user_id,
        'default_project_id', u.default_project_id,
        'default_team_id', u.default_team_id,
        'created_at', u.created_at,
        'updated_at', u.updated_at
      ) as user,
      CASE WHEN t.id IS NOT NULL THEN json_object(
        'id', t.id,
        'name', t.name,
        'description', t.description,
        'status', t.status,
        'priority', t.priority,
        'due_date', t.due_date,
        'created_date', t.created_date,
        'last_updated_date', t.last_updated_date,
        'author_user_id', t.author_user_id,
        'parent_project_id', t.parent_project_id,
        'estimated_duration_minutes', t.estimated_duration_minutes,
        'created_at', t.created_at,
        'updated_at', t.updated_at
      ) ELSE NULL END as task
    FROM task_user_assignments tua
    LEFT JOIN users u ON tua.user_id = u.id
    LEFT JOIN tasks t ON tua.task_id = t.id
    WHERE tua.task_id = :task_id
  ''';

  /// Params:
  /// - user_id: String
  static const String joinedTaskUserAssignmentsByUserQuery = '''
    SELECT
      json_object(
        'id', tua.id,
        'task_id', tua.task_id,
        'user_id', tua.user_id,
        'created_at', tua.created_at,
        'updated_at', tua.updated_at
      ) as assignment,
      json_object(
        'id', u.id,
        'email', u.email,
        'first_name', u.first_name,
        'last_name', u.last_name,
        'parent_auth_user_id', u.parent_auth_user_id,
        'default_project_id', u.default_project_id,
        'default_team_id', u.default_team_id,
        'created_at', u.created_at,
        'updated_at', u.updated_at
      ) as user,
      CASE WHEN t.id IS NOT NULL THEN json_object(
        'id', t.id,
          'name', t.name,
          'description', t.description,
          'status', t.status,
          'priority', t.priority,
          'due_date', t.due_date,
          'created_date', t.created_date,
          'last_updated_date', t.last_updated_date,
          'author_user_id', t.author_user_id,
          'parent_project_id', t.parent_project_id,
          'estimated_duration_minutes', t.estimated_duration_minutes,
          'created_at', t.created_at,
          'updated_at', t.updated_at
        ) ELSE NULL END as task
    FROM task_user_assignments tua
    LEFT JOIN users u ON tua.user_id = u.id
    LEFT JOIN tasks t ON tua.task_id = t.id
    WHERE tua.user_id = :user_id
  ''';

  /// Params:
  /// - user_id: String - The ID of the user to fetch viewable tasks for
  /// Used to fetch tasks where the user is either:
  /// 1. Assigned to the project containing the task
  /// 2. The author of the task
  static const String userViewableJoinedTasksQuery = '''
    SELECT 
      json_object(
        'id', t.id,
        'name', t.name,
        'description', t.description,
        'status', t.status,
        'priority', t.priority,
        'due_date', t.due_date,
        'created_date', t.created_date,
        'last_updated_date', t.last_updated_date,
        'author_user_id', t.author_user_id,
        'parent_project_id', t.parent_project_id,
        'estimated_duration_minutes', t.estimated_duration_minutes,
        'created_at', t.created_at,
        'updated_at', t.updated_at
      ) as task,
      CASE WHEN au.id IS NOT NULL THEN json_object(
        'id', au.id,
        'email', au.email,
        'first_name', au.first_name,
        'last_name', au.last_name,
        'parent_auth_user_id', au.parent_auth_user_id,
        'default_project_id', au.default_project_id,
        'default_team_id', au.default_team_id,
        'created_at', au.created_at,
        'updated_at', au.updated_at
      ) END as author_user,
      CASE WHEN p.id IS NOT NULL THEN json_object(
        'id', p.id,
        'name', p.name,
        'description', p.description,
        'address', p.address,
        'parent_org_id', p.parent_org_id,
        'created_at', p.created_at,
        'updated_at', p.updated_at
      ) END as project,
      json_group_array(
        CASE WHEN a.id IS NOT NULL THEN json_object(
          'id', a.id,
          'email', a.email,
          'first_name', a.first_name,
          'last_name', a.last_name,
          'parent_auth_user_id', a.parent_auth_user_id,
          'default_project_id', a.default_project_id,
          'default_team_id', a.default_team_id,
          'created_at', a.created_at,
          'updated_at', a.updated_at
        ) END
      ) as assignees,
      json_group_array(
        CASE WHEN tc.id IS NOT NULL THEN json_object(
          'id', tc.id,
          'author_user_id', tc.author_user_id,
          'parent_task_id', tc.parent_task_id,
          'created_date', tc.created_date,
          'content', tc.content,
          'start_datetime', tc.start_datetime,
          'end_datetime', tc.end_datetime,
          'created_at', tc.created_at,
          'updated_at', tc.updated_at
        ) END
      ) as comments
    FROM tasks t
    LEFT JOIN users au ON t.author_user_id = au.id
    LEFT JOIN projects p ON t.parent_project_id = p.id
    LEFT JOIN task_user_assignments tua ON t.id = tua.task_id
    LEFT JOIN users a ON tua.user_id = a.id
    LEFT JOIN task_comments tc ON t.id = tc.parent_task_id
    LEFT JOIN user_project_assignments upa ON t.parent_project_id = upa.project_id
    LEFT JOIN team_project_assignments tpa ON t.parent_project_id = tpa.project_id
    LEFT JOIN user_team_assignments uta ON tpa.team_id = uta.team_id
    WHERE upa.user_id = :user_id 
    OR uta.user_id = :user_id 
    OR t.author_user_id = :user_id
    GROUP BY t.id;
  ''';

  /// Params:
  /// - user_id: String - The ID of the user to fetch assigned tasks for
  /// Used to fetch tasks where the user is either:
  /// 1. Assigned to the task directly
  /// 2. The author of the task
  static const String userAssignedJoinedTasksQuery = '''
    SELECT 
      json_object(
        'id', t.id,
        'name', t.name,
        'description', t.description,
        'status', t.status,
        'priority', t.priority,
        'due_date', t.due_date,
        'created_date', t.created_date,
        'last_updated_date', t.last_updated_date,
        'author_user_id', t.author_user_id,
        'parent_project_id', t.parent_project_id,
        'estimated_duration_minutes', t.estimated_duration_minutes,
        'created_at', t.created_at,
        'updated_at', t.updated_at
      ) as task,
      CASE WHEN au.id IS NOT NULL THEN json_object(
        'id', au.id,
        'email', au.email,
        'first_name', au.first_name,
        'last_name', au.last_name,
        'parent_auth_user_id', au.parent_auth_user_id,
        'default_project_id', au.default_project_id,
        'default_team_id', au.default_team_id,
        'created_at', au.created_at,
        'updated_at', au.updated_at
      ) END as author_user,
      CASE WHEN p.id IS NOT NULL THEN json_object(
        'id', p.id,
        'name', p.name,
        'description', p.description,
        'address', p.address,
        'parent_org_id', p.parent_org_id,
        'created_at', p.created_at,
        'updated_at', p.updated_at
      ) END as project,
      json_group_array(
        CASE WHEN a.id IS NOT NULL THEN json_object(
          'id', a.id,
          'email', a.email,
          'first_name', a.first_name,
          'last_name', a.last_name,
          'parent_auth_user_id', a.parent_auth_user_id,
          'default_project_id', a.default_project_id,
          'default_team_id', a.default_team_id,
          'created_at', a.created_at,
          'updated_at', a.updated_at
        ) END
      ) as assignees,
      json_group_array(
        CASE WHEN tc.id IS NOT NULL THEN json_object(
          'id', tc.id,
          'author_user_id', tc.author_user_id,
          'parent_task_id', tc.parent_task_id,
          'created_date', tc.created_date,
          'content', tc.content,
          'start_datetime', tc.start_datetime,
          'end_datetime', tc.end_datetime,
          'created_at', tc.created_at,
          'updated_at', tc.updated_at
        ) END
      ) as comments
    FROM tasks t
    LEFT JOIN users au ON t.author_user_id = au.id
    LEFT JOIN projects p ON t.parent_project_id = p.id
    LEFT JOIN task_user_assignments tua ON t.id = tua.task_id
    LEFT JOIN users a ON tua.user_id = a.id
    LEFT JOIN task_comments tc ON t.id = tc.parent_task_id
    WHERE tua.user_id = :user_id 
    OR t.author_user_id = :user_id
    GROUP BY t.id;
  ''';

  /// Params:
  /// - task_id: String
  /// Used to fetch a single task by its ID, including all related data
  static const String joinedTaskByIdQuery = '''
    SELECT 
      json_object(
        'id', t.id,
        'name', t.name,
        'description', t.description,
        'status', t.status,
        'priority', t.priority,
        'due_date', t.due_date,
        'created_date', t.created_date,
        'last_updated_date', t.last_updated_date,
        'author_user_id', t.author_user_id,
        'parent_project_id', t.parent_project_id,
        'estimated_duration_minutes', t.estimated_duration_minutes,
        'created_at', t.created_at,
        'updated_at', t.updated_at
      ) as task,
      CASE WHEN au.id IS NOT NULL THEN json_object(
        'id', au.id,
        'email', au.email,
        'first_name', au.first_name,
        'last_name', au.last_name,
        'parent_auth_user_id', au.parent_auth_user_id,
        'default_project_id', au.default_project_id,
        'default_team_id', au.default_team_id,
        'created_at', au.created_at,
        'updated_at', au.updated_at
      ) END as author_user,
      CASE WHEN p.id IS NOT NULL THEN json_object(
        'id', p.id,
        'name', p.name,
        'description', p.description,
        'address', p.address,
        'parent_org_id', p.parent_org_id,
        'created_at', p.created_at,
        'updated_at', p.updated_at
      ) END as project,
      json_group_array(
        CASE WHEN a.id IS NOT NULL THEN json_object(
          'id', a.id,
          'email', a.email,
          'first_name', a.first_name,
          'last_name', a.last_name,
          'parent_auth_user_id', a.parent_auth_user_id,
          'default_project_id', a.default_project_id,
          'default_team_id', a.default_team_id,
          'created_at', a.created_at,
          'updated_at', a.updated_at
        ) END
      ) as assignees,
      json_group_array(
        CASE WHEN tc.id IS NOT NULL THEN json_object(
          'id', tc.id,
          'author_user_id', tc.author_user_id,
          'parent_task_id', tc.parent_task_id,
          'created_date', tc.created_date,
          'content', tc.content,
          'start_datetime', tc.start_datetime,
          'end_datetime', tc.end_datetime,
          'created_at', tc.created_at,
          'updated_at', tc.updated_at
        ) END
      ) as comments
    FROM tasks t
    LEFT JOIN users au ON t.author_user_id = au.id
    LEFT JOIN projects p ON t.parent_project_id = p.id
    LEFT JOIN task_user_assignments tua ON t.id = tua.task_id
    LEFT JOIN users a ON tua.user_id = a.id
    LEFT JOIN task_comments tc ON t.id = tc.parent_task_id
    WHERE t.id = :task_id
    GROUP BY t.id;
  ''';
}
