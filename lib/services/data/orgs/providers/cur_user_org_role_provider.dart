import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_org_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/repositories/user_org_roles_repository.dart';

final curUserOrgRoleProvider = StreamProvider<String>(
  (ref) {
    return CurAuthDependencyProvider.watchStream(
      ref: ref,
      builder: (userId) {
        final repository = ref.watch(userOrgRolesRepositoryProvider);
        final curOrgId = ref.watch(curOrgIdProvider);

        return repository.watchCurrentUserOrgRoles(userId).map(
          (roles) {
            return roles.firstWhere((role) => role.orgId == curOrgId).orgRole;
          },
        );
      },
    );
  },
);
