import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/joined_user_org_role_model.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/repositories/user_org_roles_repository.dart';
import 'package:seren_ai_flutter/services/data/orgs/repositories/orgs_repository.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';

final joinedUserOrgRolesByOrgStreamProvider = StreamProvider.autoDispose
    .family<List<JoinedUserOrgRoleModel>, String>((ref, orgId) {
  // Why do we need CurAuthDependencyProvider if we're not using userId?
  return CurAuthDependencyProvider.watchStream<List<JoinedUserOrgRoleModel>>(
    ref: ref,
    builder: (_) {
      // Get the base stream of org roles
      return ref
          .watch(userOrgRolesRepositoryProvider)
          .watchOrgRolesByOrg(orgId)
          .asyncMap((roles) async {
        final org = await ref.read(orgsRepositoryProvider).getById(orgId);

        // For each role, load its related user
        final joinedRoles = (await Future.wait(
          roles.map((role) async {
            final user =
                await ref.read(usersRepositoryProvider).getById(role.userId);

            return JoinedUserOrgRoleModel(
              orgRole: role,
              user: user,
              org: org,
            );
          }),
        ))
            .toList();

        return joinedRoles;
      });
    },
  );
});
