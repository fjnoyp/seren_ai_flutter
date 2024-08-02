import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/base_table_db.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_comments_model.dart';

final taskCommentsDbProvider = Provider<BaseTableDb<TaskCommentsModel>>((ref) {
  return BaseTableDb<TaskCommentsModel>(
    db: ref.watch(dbProvider),
    tableName: 'task_comments',
    fromJson: (json) => TaskCommentsModel.fromJson(json),
    toJson: (item) => item.toJson(),
  );
});
