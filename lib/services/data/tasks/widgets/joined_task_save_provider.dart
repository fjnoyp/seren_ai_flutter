import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/cur_task_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/tasks_db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_user_assignments_db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_user_assignments_model.dart';

final joinedTaskSaveProvider = Provider((ref) {
  return JoinedTaskSaveService(ref);
});

class JoinedTaskSaveService {
  Ref ref; 

  JoinedTaskSaveService(this.ref);
  
  Future<void> saveTask(JoinedTaskModel task) async {

    // TODO p1: broken task save - task name is not saved 
    // Also if project changes user assigness is not resolved properly ... 

      ref.read(tasksDbProvider).upsertItem(task.task);

      if (task.assignees.isNotEmpty) {
        final taskUserAssignments = task.assignees
            .map((user) => TaskUserAssignmentsModel(
                  taskId: task.task.id,
                  userId: user.id,
                ))
            .toList();
        ref.read(taskUserAssignmentsDbProvider).upsertItems(taskUserAssignments);
      }
    
  }
}
