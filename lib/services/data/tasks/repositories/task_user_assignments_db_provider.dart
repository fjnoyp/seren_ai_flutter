1import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/z_base_table_read_db.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_user_assignment_model.dart';

final taskUserAssignmentsReadDbProvider =
    Provider<BaseTableReadDb<TaskUserAssignmentModel>>((ref) {
  return BaseTableReadDb<TaskUserAssignmentModel>(
    db: ref.watch(dbProvider),
    tableName: 'task_user_assignments',
    fromJson: (json) => TaskUserAssignmentModel.fromJson(json),
    toJson: (item) => item.toJson(),
  );
});
