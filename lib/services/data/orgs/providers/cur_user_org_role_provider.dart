import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/joined_user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/repositories/user_org_roles_repository.dart';

/// Provider that returns the current user's role in the current organization.
final curUserOrgRoleProvider = StreamProvider<OrgRole>(
  (ref) {
    return CurAuthDependencyProvider.watchStream(
      ref: ref,
      builder: (userId) {
        final repository = ref.watch(userOrgRolesRepositoryProvider);
        final curOrgId = ref.watch(curSelectedOrgIdNotifierProvider);

        return repository.watchCurrentUserOrgRoles(userId).map(
          (roles) {
            return roles.firstWhere((role) => role.orgId == curOrgId).orgRole;
          },
        );
      },
    );
  },
);
