import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/teams/models/user_team_role_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_cacher_database_notifier.dart';

final userTeamRolesCacherDatabaseProvider = Provider.family<BaseLoaderCacheDatabaseNotifier<UserTeamRoleModel>, String>((ref, teamId) {
  return BaseLoaderCacheDatabaseNotifier<UserTeamRoleModel>(
    tableName: 'user_team_roles',
    fromJson: (json) => UserTeamRoleModel.fromJson(json),
    toJson: (item) => item.toJson(),
  );
});

/*
Need:

  Future<void> _loadData(String teamId) async {
    final response = await client
        .from(tableName)
        .select()
        .eq('team_id', teamId);

    final data = response as List<dynamic>;
    final userTeamRoles = data.map((json) => fromJson(json)).toList();
    state = userTeamRoles;
  }
  */
