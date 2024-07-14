import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/joined_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/cur_user_org_roles_list_listener_database_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/orgs_cacher_database_provider.dart';

final joinedCurUserOrgRolesCompProvider = StateNotifierProvider<JoinedCurUserOrgRolesCompNotifier, List<JoinedOrgRoleModel>?>((ref) {
  return JoinedCurUserOrgRolesCompNotifier(ref);
});

class JoinedCurUserOrgRolesCompNotifier extends StateNotifier<List<JoinedOrgRoleModel>?> {
  final Ref ref;

  JoinedCurUserOrgRolesCompNotifier(this.ref) : super([]) {
    _init();
  }

  Future<void> _init() async {
    
        // Listen to changes in the current user's org roles
    
      final watchedCurUserOrgRoles = ref.watch(curUserOrgRolesListListenerDatabaseProvider);

      final watchedCurUser = ref.watch(curAuthUserProvider);
            
      if(watchedCurUser == null || watchedCurUserOrgRoles == null){
        state = null; 
        return;
      }

      if (watchedCurUserOrgRoles.isEmpty) {
        state = [];
        return;
      }

      // Get the orgs associated with the user's roles
      final orgIds = watchedCurUserOrgRoles.map((role) => role.orgId).toList();
      final orgs = await ref.read(orgsCacherDatabaseProvider).getItems(ids: orgIds);

      if (orgs.isEmpty) {
        state = [];
        return;
      }

      // Join the org roles with the orgs
      final joinedRoles = watchedCurUserOrgRoles.map((role) {
        final org = orgs.firstWhere((org) => org.id == role.orgId);
        return JoinedOrgRoleModel(
          orgRole: role,
          org: org,
          user: watchedCurUser,
        );
      }).toList();

      state = joinedRoles;
    
  }
}
