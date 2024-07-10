import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/base_listener_database_notifier.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';

final teamsListenerDatabaseProvider = StateNotifierProvider.family<BaseListenerDatabaseNotifier<TeamModel>, List<TeamModel>, String>((ref, parentOrgId) {
  return BaseListenerDatabaseNotifier<TeamModel>(
    tableName: 'teams',
    eqFilters: [
      {'key': 'parent_org_id', 'value': parentOrgId},
    ],
    fromJson: (json) => TeamModel.fromJson(json),
  );
});
