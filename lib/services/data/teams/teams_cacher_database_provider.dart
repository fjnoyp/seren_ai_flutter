import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_cacher_database_notifier.dart';

final teamsCacherDatabaseProvider = Provider<BaseLoaderCacheDatabaseNotifier<TeamModel>>((ref) {
  return BaseLoaderCacheDatabaseNotifier<TeamModel>(
    tableName: 'teams',
    fromJson: (json) => TeamModel.fromJson(json),
    toJson: (item) => item.toJson(),
  );
});
