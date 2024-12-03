import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/base_table_db.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_reminder_model.dart';

final taskRemindersDbProvider = Provider<BaseTableDb<TaskReminderModel>>((ref) {
  return BaseTableDb<TaskReminderModel>(
    db: ref.watch(dbProvider),
    tableName: 'task_reminders',
    fromJson: (json) => TaskReminderModel.fromJson(json),
    toJson: (item) => item.toJson(),
  );
});
