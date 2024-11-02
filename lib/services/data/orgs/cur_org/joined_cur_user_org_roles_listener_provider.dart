import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/cur_user_org_roles_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/joined_user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/orgs_read_provider.dart';

final joinedCurUserOrgRolesListenerProvider = NotifierProvider<
    JoinedCurUserOrgRolesListenerNotifier,
    List<JoinedUserOrgRoleModel>?>(JoinedCurUserOrgRolesListenerNotifier.new);

class JoinedCurUserOrgRolesListenerNotifier
    extends Notifier<List<JoinedUserOrgRoleModel>?> {
  @override
  List<JoinedUserOrgRoleModel>? build() {
    _init();
    return null;
  }

  Future<void> _init() async {
    // Listen to changes in the current user's org roles

    final watchedCurUserOrgRoles = ref.watch(curUserOrgRolesListenerProvider);

    final curAuthUserState = ref.watch(curAuthStateProvider);
    final watchedCurAuthUser = switch (curAuthUserState) {
      LoggedInAuthState() => curAuthUserState.user,
      _ => null,
    };

    if (watchedCurAuthUser == null || watchedCurUserOrgRoles == null) {
      state = null;
      return;
    }

    if (watchedCurUserOrgRoles.isEmpty) {
      state = [];
      return;
    }

    // Get the orgs associated with the user's roles
    final orgIds = watchedCurUserOrgRoles.map((role) => role.orgId).toList();
    final orgs = await ref.read(orgsReadProvider).getItems(ids: orgIds);

    if (orgs.isEmpty) {
      state = [];
      return;
    }

    // Join the org roles with the orgs
    final joinedRoles = watchedCurUserOrgRoles.map((role) {
      final org = orgs.firstWhere((org) => org.id == role.orgId);
      return JoinedUserOrgRoleModel(
        orgRole: role,
        org: org,
        user: watchedCurAuthUser,
      );
    }).toList();

    state = joinedRoles;
  }
}
