import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_read_db.dart';

final teamsReadProvider = Provider<BaseReadDb<TeamModel>>((ref) {
  return BaseReadDb<TeamModel>(
    db: ref.watch(dbProvider),
    tableName: 'teams',
    fromJson: (json) => TeamModel.fromJson(json),
    toJson: (item) => item.toJson(),
  );
});
