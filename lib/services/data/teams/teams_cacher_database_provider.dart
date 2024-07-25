import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_cacher_db.dart';

final teamsCacherDatabaseProvider = Provider<BaseCacherDb<TeamModel>>((ref) {
  return BaseCacherDb<TeamModel>(
    db: ref.watch(dbProvider),
    tableName: 'teams',
    fromJson: (json) => TeamModel.fromJson(json),
    toJson: (item) => item.toJson(),
  );
});
