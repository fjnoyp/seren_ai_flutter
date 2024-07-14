import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_watch_cur_auth_user_notifier.dart';
import 'package:seren_ai_flutter/services/data/common/base_listener_database_notifier.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final curUserOrgRolesListListenerDatabaseProvider = StateNotifierProvider<CurUserOrgRolesListNotifier, List<UserOrgRoleModel>?>((ref) {
  return CurUserOrgRolesListNotifier(ref);
});

class CurUserOrgRolesListNotifier extends BaseWatchCurAuthUserNotifier<UserOrgRoleModel> {
  CurUserOrgRolesListNotifier(super.ref)
      : super(
          createWatchingNotifier: (UserModel curUserModel) {
            return BaseListenerDatabaseNotifier<UserOrgRoleModel>(
              tableName: 'user_org_roles',
              eqFilters: [
                {'key': 'user_id', 'value': curUserModel.id},
              ],
              fromJson: (json) => UserOrgRoleModel.fromJson(json),
            );
          },
        );
}
