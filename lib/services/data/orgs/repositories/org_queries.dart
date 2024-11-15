abstract class OrgQueries {
  /// Params:
  /// - user_id: String
  static const userOrgsQuery = '''
      SELECT o.* FROM orgs o
      INNER JOIN user_org_roles uor ON uor.org_id = o.id 
      WHERE uor.user_id = @user_id
      ''';

  /// Params:
  /// - user_id: String
  static const userOrgRolesQuery = '''
      SELECT * FROM user_org_roles 
      WHERE user_id = @user_id
      ''';

  /// Params:
  /// - user_id: String
  static const joinedUserOrgRolesQueryByUser = '''
    SELECT 
      json_object(
        'user_id', uor.user_id,
        'org_id', uor.org_id,
        'org_role', uor.org_role,
        'created_at', uor.created_at,
        'updated_at', uor.updated_at
      ) as org_role,
      CASE 
        WHEN u.id IS NOT NULL THEN
          json_object(
            'id', u.id,
            'parent_auth_user_id', u.parent_auth_user_id,
            'email', u.email,
            'first_name', u.first_name,
            'last_name', u.last_name,
            'default_project_id', u.default_project_id,
            'default_team_id', u.default_team_id,
            'created_at', u.created_at,
            'updated_at', u.updated_at
          )
        ELSE NULL
      END as user,
      CASE 
        WHEN o.id IS NOT NULL THEN
          json_object(
            'id', o.id,
            'name', o.name,
            'address', o.address,
            'created_at', o.created_at,
            'updated_at', o.updated_at
          )
        ELSE NULL
      END as org
    FROM user_org_roles uor
    LEFT JOIN users u ON u.id = uor.user_id
    LEFT JOIN orgs o ON o.id = uor.org_id
    WHERE uor.user_id = @user_id;
  ''';

  /// Params:
  /// - org_id: String
  static const joinedUserOrgRolesQueryByOrg = '''
    SELECT 
      json_object(
        'user_id', uor.user_id,
        'org_id', uor.org_id,
        'org_role', uor.org_role,
        'created_at', uor.created_at,
        'updated_at', uor.updated_at
      ) as org_role,
      CASE 
        WHEN u.id IS NOT NULL THEN
          json_object(
            'id', u.id,
            'parent_auth_user_id', u.parent_auth_user_id,
            'email', u.email,
            'first_name', u.first_name,
            'last_name', u.last_name,
            'default_project_id', u.default_project_id,
            'default_team_id', u.default_team_id,
            'created_at', u.created_at,
            'updated_at', u.updated_at
          )
        ELSE NULL
      END as user,
      CASE 
        WHEN o.id IS NOT NULL THEN
          json_object(
            'id', o.id,
            'name', o.name,
            'address', o.address,
            'created_at', o.created_at,
            'updated_at', o.updated_at
          )
        ELSE NULL
      END as org
    FROM user_org_roles uor
    LEFT JOIN users u ON u.id = uor.user_id
    LEFT JOIN orgs o ON o.id = uor.org_id
    WHERE uor.org_id = @org_id;
  ''';
}
