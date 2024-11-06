import 'dart:convert';

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
    final orgRoleJson = jsonDecode(json['org_role']);
    final userJson = jsonDecode(json['user']);
    final orgJson = jsonDecode(json['org']);

    final orgRole = UserOrgRoleModel.fromJson(orgRoleJson);
    final user = UserModel.fromJson(userJson);
    final org = OrgModel.fromJson(orgJson);

    return JoinedUserOrgRoleModel(orgRole: orgRole, user: user, org: org);
  }
}
