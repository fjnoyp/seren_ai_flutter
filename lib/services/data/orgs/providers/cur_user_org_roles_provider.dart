import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/joined_user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_org_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/repositories/joined_user_org_roles_repository.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';

final joinedCurUserRolesProvider =
    StreamProvider.autoDispose<List<JoinedUserOrgRoleModel>>(
  (ref) {
    return CurAuthDependencyProvider.watchStream<List<JoinedUserOrgRoleModel>>(
        ref: ref,
        builder: (userId) {
          return ref
              .watch(joinedUserOrgRolesRepositoryProvider)
              .watchJoinedUserOrgRolesByUser(userId);
        });
  },
);

final joinedCurOrgRolesProvider =
    StreamProvider.autoDispose<List<JoinedUserOrgRoleModel>>(
  (ref) {
    final orgId = ref.watch(curOrgIdProvider);
    return ref
        .watch(joinedUserOrgRolesRepositoryProvider)
        .watchJoinedUserOrgRolesByOrg(orgId ?? '');
  },
);
