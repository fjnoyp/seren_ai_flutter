import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';
import 'package:seren_ai_flutter/services/data/common/z_base_table_read_db.dart';

final teamsReadProvider = Provider<BaseTableReadDb<TeamModel>>((ref) {
  return BaseTableReadDb<TeamModel>(
    db: ref.watch(dbProvider),
    tableName: 'teams',
    fromJson: (json) => TeamModel.fromJson(json),
    toJson: (item) => item.toJson(),
  );
});
