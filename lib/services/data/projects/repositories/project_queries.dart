abstract class ProjectQueries {
  /// Params:
  /// - user_id: String
  /// Used to fetch projects where the user is either:
  /// 1. Directly assigned to the project
  /// 2. Assigned via team membership
  static const String userViewableProjectsQuery = '''
    SELECT DISTINCT p.*
    FROM projects p
    WHERE p.id IN (
        -- Direct project assignments
        SELECT project_id 
        FROM user_project_assignments 
        WHERE user_id = :user_id
        UNION
        -- Team-based project assignments
        SELECT project_id 
        FROM team_project_assignments tpa
        INNER JOIN user_team_assignments uta ON uta.team_id = tpa.team_id
        WHERE uta.user_id = :user_id
    )
    ''';

  /// Params:
  /// - org_id: String
  /// Used to fetch all projects belonging to a specific organization
  static const String orgProjectsQuery = '''
    SELECT p.*
    FROM projects p
    WHERE p.parent_org_id = :org_id
  ''';

  /// Params:
  /// - project_id: String
  static const String projectByIdQuery = '''
    SELECT p.*
    FROM projects p
    WHERE p.id = :project_id
  ''';

  /// Params:
  /// - org_id: String
  static const String joinedOrgProjectsQuery = '''
    SELECT 
      json_object(
        'id', p.id,
        'name', p.name,
        'description', p.description,
        'address', p.address,
        'parent_org_id', p.parent_org_id,
        'created_at', p.created_at,
        'updated_at', p.updated_at
      ) as project,
      CASE WHEN o.id IS NOT NULL THEN json_object(
        'id', o.id,
        'name', o.name,
        'address', o.address
      ) END as org,
      json_group_array(
        CASE WHEN u.id IS NOT NULL THEN json_object(
          'id', u.id,
          'parent_auth_user_id', u.parent_auth_user_id,
          'email', u.email,
          'first_name', u.first_name,
          'last_name', u.last_name,
          'default_project_id', u.default_project_id,
          'default_team_id', u.default_team_id
        ) END
      ) as assignees
    FROM projects p
    LEFT JOIN orgs o ON p.parent_org_id = o.id
    LEFT JOIN user_project_assignments pa ON p.id = pa.project_id
    LEFT JOIN users u ON pa.user_id = u.id
    WHERE p.parent_org_id = :org_id
    GROUP BY p.id
  ''';

  /// Params:
  /// - project_id: String
  static const String joinedProjectByIdQuery = '''
    SELECT 
      json_object(
        'id', p.id,
        'name', p.name,
        'description', p.description,
        'address', p.address,
        'parent_org_id', p.parent_org_id,
        'created_at', p.created_at,
        'updated_at', p.updated_at
      ) as project,
      CASE WHEN o.id IS NOT NULL THEN json_object(
        'id', o.id,
        'name', o.name,
        'address', o.address
      ) END as org,
      json_group_array(
        CASE WHEN u.id IS NOT NULL THEN json_object(
          'id', u.id,
          'parent_auth_user_id', u.parent_auth_user_id,
          'email', u.email,
          'first_name', u.first_name,
          'last_name', u.last_name,
          'default_project_id', u.default_project_id,
          'default_team_id', u.default_team_id
        ) END
      ) as assignees
    FROM projects p
    LEFT JOIN orgs o ON p.parent_org_id = o.id
    LEFT JOIN user_project_assignments pa ON p.id = pa.project_id
    LEFT JOIN users u ON pa.user_id = u.id
    WHERE p.id = :project_id
    GROUP BY p.id
  ''';

  
  /// Params:
  /// - project_id: String
  static const String userProjectAssignmentsQuery = '''
    SELECT DISTINCT upa.*
    FROM user_project_assignments upa
    LEFT JOIN projects p ON p.id = upa.project_id 
    WHERE upa.project_id = :project_id
    ''';
}
