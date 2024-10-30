import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/auth_states.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/models/user_team_assignment_model.dart';

// Provide all team roles for current user
final curUserTeamRolesListenerProvider = NotifierProvider<
    CurUserTeamRolesListenerNotifier,
    List<UserTeamAssignmentModel>?>(CurUserTeamRolesListenerNotifier.new);

/// Get the current user's team roles
class CurUserTeamRolesListenerNotifier
    extends Notifier<List<UserTeamAssignmentModel>?> {
  @override
  List<UserTeamAssignmentModel>? build() {
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
      List<UserTeamAssignmentModel> items =
          results.map((e) => UserTeamAssignmentModel.fromJson(e)).toList();
      state = items;
    });

    ref.onDispose(() {
      subscription.cancel();
    });
  }
}
