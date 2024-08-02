import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/base_table_db.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

final tasksDbProvider = Provider<BaseTableDb<TaskModel>>((ref) {
  return BaseTableDb<TaskModel>(
    db: ref.watch(dbProvider),
    tableName: 'tasks',
    fromJson: (json) => TaskModel.fromJson(json),
    toJson: (item) => item.toJson(),
  );
});
