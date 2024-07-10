import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/joined_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/user_org_roles/org_roles_cacher_database_provider.dart';
import 'package:seren_ai_flutter/services/data/users/users_cacher_database_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/orgs_cacher_database_provider.dart';

final joinedUserOrgRolesCompProvider = StateNotifierProvider.family<
    JoinedUserOrgRolesCompNotifier,
    List<JoinedOrgRoleModel>,
    String>((ref, org) {
  return JoinedUserOrgRolesCompNotifier(ref, org);
});

class JoinedUserOrgRolesCompNotifier
    extends StateNotifier<List<JoinedOrgRoleModel>> {
  final Ref ref;
  final String orgId;

  JoinedUserOrgRolesCompNotifier(this.ref, this.orgId) : super([]) {
    refresh();
  }

  Future<void> refresh() async {
    final userOrgRoles = await ref
        .read(userOrgRolesCacherDatabaseProvider(orgId))
        .getItems(eqFilters: [
      {'key': 'org_id', 'value': orgId}
    ]);

    final userIds = userOrgRoles.map((role) => role.userId).toList();
    final authUsers =
        await ref.read(usersCacherDatabaseProvider).getItems(ids: userIds);

    final org = (await ref
        .read(orgsCacherDatabaseProvider)
        .getItem(id: orgId))!;

    final joinedRoles = userOrgRoles.map((role) {
      final authUser =
          authUsers.firstWhere((user) => user.id == role.userId);
      return JoinedOrgRoleModel(
        orgRole: role,
        user: authUser,
        org: org,
      );
    }).toList();

    state = joinedRoles;
  }
}
