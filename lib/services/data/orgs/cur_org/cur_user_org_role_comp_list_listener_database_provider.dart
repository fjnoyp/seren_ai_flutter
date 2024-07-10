import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/base_listener_database_notifier.dart';

final curUserOrgRoleCompListListenerDatabaseProvider = StateNotifierProvider<CurUserOrgRoleCompListNotifier, List<UserOrgRoleModel>>((ref) {
  return CurUserOrgRoleCompListNotifier(ref);
});

class CurUserOrgRoleCompListNotifier extends StateNotifier<List<UserOrgRoleModel>>{
  final Ref ref;
  BaseListenerDatabaseNotifier<UserOrgRoleModel>? _databaseNotifier;

  CurUserOrgRoleCompListNotifier(this.ref) : super([]) {
    _init();
  }

  void _init() {
    ref.listen(curAuthUserProvider, (previous, next) {
      if (next == null) {
        state = [];
        _databaseNotifier = null;
      } else {
        _setupDatabaseNotifier(next.id);
      }
    });
  }

  void _setupDatabaseNotifier(String userId) {
    _databaseNotifier = BaseListenerDatabaseNotifier<UserOrgRoleModel>(
      tableName: 'user_org_roles',
      eqFilters: [
        {'key': 'user_id', 'value': userId},
      ],
      fromJson: (json) => UserOrgRoleModel.fromJson(json),
    );

    _databaseNotifier!.addListener((roles) {
      state = roles;
    });
  }

}

