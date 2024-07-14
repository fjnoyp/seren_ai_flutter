import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_listener_database_notifier.dart';

final tasksListenerDatabaseProvider = StateNotifierProvider.family<BaseListenerDatabaseNotifier<TaskModel>, List<TaskModel>, String>((ref, parentProjectId) {
  return BaseListenerDatabaseNotifier<TaskModel>(
    tableName: 'tasks',
    eqFilters: [
      {'key': 'parent_project_id', 'value': parentProjectId},
      // Add more filters if needed
    ],
    fromJson: (json) => TaskModel.fromJson(json),
  );
});
