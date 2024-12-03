import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/org_model.dart';

class JoinedUserOrgRoleModel {
  final UserOrgRoleModel orgRole;
  final UserModel? user;
  final OrgModel? org;

  JoinedUserOrgRoleModel({
    required this.orgRole,
    required this.user,
    required this.org,
  });

  factory JoinedUserOrgRoleModel.fromJson(Map<String, dynamic> json) {
    final orgRole = UserOrgRoleModel.fromJson(json['org_role']);
    final user = UserModel.fromJson(json['user']);
    final org = OrgModel.fromJson(json['org']);

    return JoinedUserOrgRoleModel(orgRole: orgRole, user: user, org: org);
  }
}
