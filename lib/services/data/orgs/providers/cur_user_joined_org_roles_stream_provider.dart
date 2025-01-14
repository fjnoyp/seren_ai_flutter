import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/joined_user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/repositories/orgs_repository.dart';
import 'package:seren_ai_flutter/services/data/orgs/repositories/user_org_roles_repository.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';

final curUserJoinedOrgRolesStreamProvider =
    StreamProvider.autoDispose<List<JoinedUserOrgRoleModel>>((ref) {
  return CurAuthDependencyProvider.watchStream<List<JoinedUserOrgRoleModel>>(
    ref: ref,
    builder: (userId) {
      // Get the base stream of org roles
      return ref
          .read(userOrgRolesRepositoryProvider)
          .watchOrgRolesByUser(userId)
          .asyncMap((roles) async {
        final user = await ref.read(usersRepositoryProvider).getById(userId);

        final joinedRoles = await Future.wait(
          roles.map((role) async => JoinedUserOrgRoleModel(
                orgRole: role,
                user: user,
                org: await ref.read(orgsRepositoryProvider).getById(role.orgId),
              )),
        );
        return joinedRoles;
      });
    },
  );
});
