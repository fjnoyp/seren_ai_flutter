import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/z_base_table_db.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_comment_model.dart';

final taskCommentsDbProvider = Provider<BaseTableDb<TaskCommentModel>>((ref) {
  return BaseTableDb<TaskCommentModel>(
    db: ref.watch(dbProvider),
    tableName: 'task_comments',
    fromJson: (json) => TaskCommentModel.fromJson(json),
    toJson: (item) => item.toJson(),
  );
});
