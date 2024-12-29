import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/joined_user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/repositories/org_queries.dart';

final joinedUserOrgRolesRepositoryProvider =
    Provider<JoinedUserOrgRolesRepository>((ref) {
  return JoinedUserOrgRolesRepository(ref.watch(dbProvider));
});

class JoinedUserOrgRolesRepository
    extends BaseRepository<JoinedUserOrgRoleModel> {
  const JoinedUserOrgRolesRepository(super.db);

  @override
  Set<String> get REMOVEwatchTables => {'user_org_roles', 'users', 'orgs'};

  @override
  JoinedUserOrgRoleModel fromJson(Map<String, dynamic> json) {
    final decodedJson = json.map((key, value) =>
        (key == 'org_role' || key == 'user' || key == 'org') && value != null
            ? MapEntry(key, jsonDecode(value))
            : MapEntry(key, value));

    return JoinedUserOrgRoleModel.fromJson(decodedJson);
  }

  Stream<List<JoinedUserOrgRoleModel>> watchJoinedUserOrgRolesByUser(
      String userId) {
    return watch(OrgQueries.joinedUserOrgRolesQueryByUser, {
      'user_id': userId,
    });
  }

  Future<List<JoinedUserOrgRoleModel>> getJoinedUserOrgRolesByUser(
      String userId) async {
    return get(OrgQueries.joinedUserOrgRolesQueryByUser, {
      'user_id': userId,
    });
  }

  Stream<List<JoinedUserOrgRoleModel>> watchJoinedUserOrgRolesByOrg(
      String orgId) {
    return watch(OrgQueries.joinedUserOrgRolesQueryByOrg, {
      'org_id': orgId,
    });
  }

  Future<List<JoinedUserOrgRoleModel>> getJoinedUserOrgRolesByOrg(
      String orgId) async {
    return get(OrgQueries.joinedUserOrgRolesQueryByOrg, {
      'org_id': orgId,
    });
  }
}
