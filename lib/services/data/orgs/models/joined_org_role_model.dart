import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/authUsers/models/auth_user_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/org_model.dart';

class JoinedOrgRoleModel {
  final UserOrgRoleModel orgRole;
  final AuthUserModel authUser;
  final OrgModel org;

  JoinedOrgRoleModel({
    required this.orgRole,
    required this.authUser,
    required this.org,
  });

  /*
  factory JoinedOrgRoleModel.fromJson(Map<String, dynamic> json) => JoinedOrgRoleModel(
    orgRole: UserOrgRoleModel.fromJson(json['orgRole'] as Map<String, dynamic>),
    authUser: AuthUserModel.fromJson(json['authUser'] as Map<String, dynamic>),
    org: OrgModel.fromJson(json['org'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'orgRole': orgRole.toJson(),
    'authUser': authUser.toJson(),
  };
  */
}
