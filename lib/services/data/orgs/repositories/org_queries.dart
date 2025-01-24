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
  /// - org_id: String
  static const userOrgRolesByOrgQuery = '''
    SELECT * FROM user_org_roles 
    WHERE org_id = @org_id;
  ''';

  /// Params:
  /// - org_id: String
  static const String pendingInvitesByOrgQuery = '''
    SELECT *
    FROM invites
    WHERE org_id = @org_id
    AND status = 'pending'
    ORDER BY created_at DESC;
  ''';
}
