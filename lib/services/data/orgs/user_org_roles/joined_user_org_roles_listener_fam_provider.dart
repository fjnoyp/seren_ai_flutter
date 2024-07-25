import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/joined_user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/user_org_roles/user_org_roles_listener_fam_provider.dart';
import 'package:seren_ai_flutter/services/data/users/users_cacher_database_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/orgs_cacher_db_provider.dart';

final joinedUserOrgRolesListenerFamProvider = NotifierProvider.family<
    JoinedUserOrgRolesListenerFamNotifier,
    List<JoinedUserOrgRoleModel>?,
    String>( 
  JoinedUserOrgRolesListenerFamNotifier.new
);

class JoinedUserOrgRolesListenerFamNotifier
    extends FamilyNotifier<List<JoinedUserOrgRoleModel>?, String> {  

  @override
  List<JoinedUserOrgRoleModel>? build(String arg) {
    _listen();
    return null;
  }

  Future<void> _listen() async {
    final orgId = arg; 

    final userOrgRoles = ref
        .watch(userOrgRolesListenerFamProvider(orgId));

    if (userOrgRoles == null) {
      return;
    }

    final userIds = userOrgRoles.map((role) => role.userId).toList();
    final authUsers =
        await ref.read(usersCacherDatabaseProvider).getItems(ids: userIds);

    final org = (await ref
        .read(orgsCacherDatabaseProvider)
        .getItem(id: orgId))!;

    final joinedRoles = userOrgRoles.map((role) {
      final authUser =
          authUsers.firstWhere((user) => user.id == role.userId);
      return JoinedUserOrgRoleModel(
        orgRole: role,
        user: authUser,
        org: org,
      );
    }).toList();

    state = joinedRoles;
  }
}
