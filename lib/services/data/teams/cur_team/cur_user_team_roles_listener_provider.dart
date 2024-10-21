import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/auth_states.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/models/user_team_role_model.dart';

// Provide all team roles for current user
final curUserTeamRolesListenerProvider = NotifierProvider<
    CurUserTeamRolesListenerNotifier,
    List<UserTeamRoleModel>?>(CurUserTeamRolesListenerNotifier.new);

/// Get the current user's team roles
class CurUserTeamRolesListenerNotifier
    extends Notifier<List<UserTeamRoleModel>?> {
  @override
  List<UserTeamRoleModel>? build() {
    final curAuthUserState = ref.read(curAuthStateProvider);
    final watchedCurAuthUser = switch (curAuthUserState) {
      LoggedInAuthState() => curAuthUserState.user,
      _ => null,
    };

    if (watchedCurAuthUser == null) {
      return null;
    }

    final db = ref.read(dbProvider);

    final query =
        "SELECT * FROM user_team_roles WHERE user_id = '${watchedCurAuthUser.id}'";

    final subscription = db.watch(query).listen((results) {
      List<UserTeamRoleModel> items =
          results.map((e) => UserTeamRoleModel.fromJson(e)).toList();
      state = items;
    });

    ref.onDispose(() {
      subscription.cancel();
    });
  }
}
