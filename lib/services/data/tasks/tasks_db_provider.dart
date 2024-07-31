import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_user_assignments.dart';
import 'package:seren_ai_flutter/services/data/common/base_read_db.dart';

final tasksDbProvider = Provider<TasksDbProvider>((ref) {
  final db = ref.watch(dbProvider);
  return TasksDbProvider(db);
});

class TasksDbProvider {
  final BaseReadDb<TaskModel> _tasksDb;
  final BaseReadDb<TaskUserAssignments> _taskUserAssignmentsDb;

  TasksDbProvider(db)
      : _tasksDb = BaseReadDb<TaskModel>(
          db: db,
          tableName: 'tasks',
          fromJson: TaskModel.fromJson,
          toJson: (task) => task.toJson(),
        ),
        _taskUserAssignmentsDb = BaseReadDb<TaskUserAssignments>(
          db: db,
          tableName: 'task_user_assignments',
          fromJson: TaskUserAssignments.fromJson,
          toJson: (assignment) => assignment.toJson(),
        );

  Future<TaskModel> insertTask(TaskModel task, List<TaskUserAssignments> assignments) async {
    final insertedTask = await _tasksDb.insertItem(task);
    for (var assignment in assignments) {
      await _taskUserAssignmentsDb.insertItem(assignment);
    }
    return insertedTask;
  }

  Future<void> updateTask(TaskModel task, List<TaskUserAssignments> assignments) async {
    await _tasksDb.updateItem(task);
    
    // Delete existing assignments and insert new ones
    await _taskUserAssignmentsDb.deleteItem(task.id);
    for (var assignment in assignments) {
      await _taskUserAssignmentsDb.insertItem(assignment);
    }
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksDb.deleteItem(taskId);
    // This will cascade delete the assignments due to foreign key constraint
  }

  /*
  Future<TaskModel?> getTask(String taskId) async {
    return await _tasksDb.getItem(id: taskId);
  }

  Future<List<TaskModel>> getTasks({List<String>? ids}) async {
    return await _tasksDb.getItems(ids: ids);
  }

  Future<List<TaskUserAssignments>> getTaskAssignments(String taskId) async {
    return await _taskUserAssignmentsDb.getItems(
      eqFilters: [{'key': 'task_id', 'value': taskId}],
    );
  }
  */
}