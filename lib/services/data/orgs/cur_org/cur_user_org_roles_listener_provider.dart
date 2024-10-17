import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/auth_states.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';

final curUserOrgRolesListenerProvider = NotifierProvider<CurUserOrgRolesListenerNotifier, List<UserOrgRoleModel>?>(
  CurUserOrgRolesListenerNotifier.new
);

class CurUserOrgRolesListenerNotifier extends Notifier<List<UserOrgRoleModel>?> {
  
  CurUserOrgRolesListenerNotifier(); 

  @override
  List<UserOrgRoleModel>? build() {
    final curAuthUserState = ref.watch(curAuthUserProvider);
    final watchedCurAuthUser = switch (curAuthUserState) {
      LoggedInAuthState() => curAuthUserState.user,
      _ => null,
    };

    if(watchedCurAuthUser == null) {
      return null;
    }

    // TODO p1: auth token refresh causes this to glitch out and cause @cur_org_id_provider to be null and log out user from org ... 

    final db = ref.read(dbProvider);
    final query = "SELECT * FROM user_org_roles WHERE user_id = '${watchedCurAuthUser.id}'";

    final subscription = db.watch(query).listen((results) {
      List<UserOrgRoleModel> items = results.map((e) => UserOrgRoleModel.fromJson(e)).toList();
      state = items;
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return null;
  }
}