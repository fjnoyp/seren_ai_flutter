abstract class OrgQueries {
  /// Params:
  /// - user_id: String
  static const userOrgsQuery = '''
      SELECT o.* FROM orgs o
      INNER JOIN user_org_roles uor ON uor.org_id = o.id 
      WHERE uor.user_id = @user_id
      AND o.is_enabled = 1
      ''';

  /// Params:
  /// - user_id: String
  static const userOrgRolesQuery = '''
      SELECT uor.* FROM user_org_roles uor
      INNER JOIN orgs o ON uor.org_id = o.id
      WHERE uor.user_id = @user_id
      AND o.is_enabled = 1
      ''';

  /// Params:
  /// - org_id: String
  static const userOrgRolesByOrgQuery = '''
    SELECT uor.* FROM user_org_roles uor
    INNER JOIN orgs o ON uor.org_id = o.id
    WHERE uor.org_id = @org_id
    AND o.is_enabled = 1;
  ''';

  /// Params:
  /// - org_id: String
  static const String pendingInvitesByOrgQuery = '''
    SELECT i.* FROM invites i
    INNER JOIN orgs o ON i.org_id = o.id
    WHERE i.org_id = @org_id
    AND i.status = 'pending'
    AND o.is_enabled = 1
    ORDER BY i.created_at DESC;
  ''';
}
