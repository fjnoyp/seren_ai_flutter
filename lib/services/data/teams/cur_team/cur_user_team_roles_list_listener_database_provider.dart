import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/teams/models/user_team_role_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_watch_cur_auth_user_notifier.dart';
import 'package:seren_ai_flutter/services/data/common/base_listener_database_notifier.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final curUserTeamRolesListListenerDatabaseProvider = StateNotifierProvider<CurUserTeamRolesListNotifier, List<UserTeamRoleModel>?>((ref) {
  return CurUserTeamRolesListNotifier(ref);
});

/// Get the current user's team roles
class CurUserTeamRolesListNotifier extends BaseWatchCurAuthUserNotifier<UserTeamRoleModel> {
  CurUserTeamRolesListNotifier(super.ref)
      : super(
          createWatchingNotifier: (UserModel curUserModel) {
            return BaseListenerDatabaseNotifier<UserTeamRoleModel>(
              tableName: 'user_team_roles',
              eqFilters: [
                {'key': 'user_id', 'value': curUserModel.id},
              ],
              fromJson: (json) => UserTeamRoleModel.fromJson(json),
            );
          },
        );
}
