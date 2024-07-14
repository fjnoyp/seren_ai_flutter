import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/teams/models/user_team_role_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_listener_database_notifier.dart';

final userTeamRolesListenerDatabaseProvider = StateNotifierProvider.family<BaseListenerDatabaseNotifier<UserTeamRoleModel>, List<UserTeamRoleModel>, String>((ref, userId) {
  return BaseListenerDatabaseNotifier<UserTeamRoleModel>(
    tableName: 'user_team_roles',
    eqFilters: [
      {'key': 'user_id', 'value': userId},
      // Add more filters if needed
    ],
    fromJson: (json) => UserTeamRoleModel.fromJson(json),
  );
});
