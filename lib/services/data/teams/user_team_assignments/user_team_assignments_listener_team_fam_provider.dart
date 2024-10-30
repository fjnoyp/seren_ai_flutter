import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/teams/models/user_team_assignment_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_listener_db_notifier.dart';

final userTeamAssignmentsListenerTeamFamProvider =
    Provider.family<List<UserTeamAssignmentModel>?, String>(
  (ref, userId) {
    final params = ref.read(_userTeamAssignmentsListenerFamParamsProvider(userId));
    return ref.watch(_userTeamAssignmentsListenerFamProvider(params));
  },
);

final _userTeamAssignmentsListenerFamParamsProvider =
    Provider.family<BaseListenerDbParams<UserTeamAssignmentModel>, String>(
  (ref, userId) => BaseListenerDbParams(
    tableName: 'user_team_assignments',
    filters: [
      {'key': 'user_id', 'value': userId}
    ],
    fromJson: (json) => UserTeamAssignmentModel.fromJson(json),
  ),
);

final _userTeamAssignmentsListenerFamProvider = NotifierProvider.family<
        BaseListenerDbNotifier<UserTeamAssignmentModel>,
        List<UserTeamAssignmentModel>?,
        BaseListenerDbParams<UserTeamAssignmentModel>>(
    BaseListenerDbNotifier<UserTeamAssignmentModel>.new);

/*
return BaseListenerDbNotifier<UserTeamAssignmentModel>(
    tableName: 'user_team_assignments',
    eqFilters: [
      {'key': 'user_id', 'value': userId},
      // Add more filters if needed
    ],
    fromJson: (json) => UserTeamAssignmentModel.fromJson(json),
  );
  */