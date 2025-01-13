import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/joined_user_org_role_model.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/repositories/user_org_roles_repository.dart';
import 'package:seren_ai_flutter/services/data/orgs/repositories/orgs_repository.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';

final joinedUserOrgRolesByOrgStreamProvider = StreamProvider.autoDispose
    .family<List<JoinedUserOrgRoleModel>, String>((ref, orgId) {
  return CurAuthDependencyProvider.watchStream<List<JoinedUserOrgRoleModel>>(
    ref: ref,
    builder: (userId) {
      // Get the base stream of org roles
      return ref
          .watch(userOrgRolesRepositoryProvider)
          .watchOrgRolesByOrg(orgId)
          .asyncMap((roles) async {
        // For each role, load its related user and org
        final joinedRoles = await Future.wait(
          roles.map((role) async {
            final user =
                await ref.read(usersRepositoryProvider).getById(role.userId);
            final org =
                await ref.read(orgsRepositoryProvider).getById(role.orgId);

            return JoinedUserOrgRoleModel(
              orgRole: role,
              user: user,
              org: org,
            );
          }),
        );

        return joinedRoles;
      });
    },
  );
});
