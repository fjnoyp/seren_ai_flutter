abstract class ProjectQueries {
  /// Params:
  /// - user_id: String
  /// - org_id: String
  ///
  /// Used to fetch projects belonging to an organization where the user is either:
  /// 1. Directly assigned to the project
  /// 2. Assigned via team membership
  /// 3. An admin of the organization
  static const String userViewableProjectsQuery = '''
    SELECT DISTINCT p.*
    FROM projects p
    LEFT JOIN user_org_roles uor ON (
        uor.user_id = :user_id 
        AND uor.org_id = :org_id
    )
    WHERE p.parent_org_id = :org_id
    AND (
        uor.org_role = 'admin'  -- Admin check
        OR p.id IN (
            -- Direct project assignments
            SELECT project_id 
            FROM user_project_assignments 
            WHERE user_id = :user_id
            UNION
            -- Team-based project assignments
            SELECT tpa.project_id 
            FROM team_project_assignments tpa
            INNER JOIN user_team_assignments uta ON uta.team_id = tpa.team_id
            WHERE uta.user_id = :user_id
        )
    )
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
