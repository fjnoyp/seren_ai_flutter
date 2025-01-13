import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';

final teamsRepositoryProvider = Provider<TeamsRepository>((ref) {
  return TeamsRepository(ref.watch(dbProvider));
});

class TeamsRepository extends BaseRepository<TeamModel> {
  const TeamsRepository(super.db, {super.primaryTable = 'teams'});

  @override
  TeamModel fromJson(Map<String, dynamic> json) {
    return TeamModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(TeamModel item) {
    return item.toJson();
  }
}
