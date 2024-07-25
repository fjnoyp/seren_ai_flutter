import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/teams/models/user_team_role_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_listener_db_notifier.dart';

final userTeamRolesListenerFamProvider = Provider.family<List<UserTeamRoleModel>?, String>(
  (ref, userId) {
    final params = ref.read(_userTeamRolesListenerFamParamsProvider(userId));
    return ref.watch(_userTeamRolesListenerFamProvider(params));
  },
);

final _userTeamRolesListenerFamParamsProvider = Provider.family<BaseListenerDbParams<UserTeamRoleModel>, String>(
  (ref, userId) => BaseListenerDbParams(
    tableName: 'user_team_roles',
    filters: [{'key': 'user_id', 'value': userId}],
    fromJson: (json) => UserTeamRoleModel.fromJson(json),
  ),
);

final _userTeamRolesListenerFamProvider = NotifierProvider.family<BaseListenerDbNotifier<UserTeamRoleModel>, List<UserTeamRoleModel>?, BaseListenerDbParams<UserTeamRoleModel>>(
  BaseListenerDbNotifier<UserTeamRoleModel>.new
);

/*
return BaseListenerDbNotifier<UserTeamRoleModel>(
    tableName: 'user_team_roles',
    eqFilters: [
      {'key': 'user_id', 'value': userId},
      // Add more filters if needed
    ],
    fromJson: (json) => UserTeamRoleModel.fromJson(json),
  );
  */