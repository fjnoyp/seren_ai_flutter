import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/orgs/repositories/org_queries.dart';

final userOrgRolesRepositoryProvider = Provider<UserOrgRolesRepository>((ref) {
  return UserOrgRolesRepository(ref.watch(dbProvider), primaryTable: '');
});

class UserOrgRolesRepository extends BaseRepository<UserOrgRoleModel> {
  const UserOrgRolesRepository(super.db, {required super.primaryTable});

  @override
  UserOrgRoleModel fromJson(Map<String, dynamic> json) {
    return UserOrgRoleModel.fromJson(json);
  }

  Stream<List<UserOrgRoleModel>> watchOrgRolesByUser(String userId) {
    return watch(OrgQueries.userOrgRolesQuery, {
      'user_id': userId,
    });
  }

  Future<List<UserOrgRoleModel>> getOrgRolesByUser(String userId) async {
    return get(OrgQueries.userOrgRolesQuery, {
      'user_id': userId,
    });
  }

  Stream<List<UserOrgRoleModel>> watchOrgRolesByOrg(String orgId) {
    return watch(OrgQueries.userOrgRolesByOrgQuery, {
      'org_id': orgId,
    });
  }
}
