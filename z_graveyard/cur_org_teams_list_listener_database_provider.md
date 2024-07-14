import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_watch_cur_org_notifier.dart';
import 'package:seren_ai_flutter/services/data/common/base_listener_database_notifier.dart';

final curOrgTeamsListListenerDatabaseProvider = StateNotifierProvider<CurOrgTeamsListNotifier, List<TeamModel>?>((ref) {
  return CurOrgTeamsListNotifier(ref);
});

class CurOrgTeamsListNotifier extends BaseWatchCurOrgNotifier<TeamModel> {
  CurOrgTeamsListNotifier(super.ref)
      : super(
          createWatchingNotifier: (String? curOrgId) {
            if(curOrgId == null) throw Exception('curOrgId is null');
            return BaseListenerDatabaseNotifier<TeamModel>(
              tableName: 'teams',
              eqFilters: [
                {'key': 'parent_org_id', 'value': curOrgId},
              ],
              fromJson: (json) => TeamModel.fromJson(json),
            );
          },
        );
}
