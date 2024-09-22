import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/ui_state/cur_task_provider.dart';
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

      // TODO p4: optimize by running all futures in parallel 
      await ref.read(tasksDbProvider).upsertItem(task.task);


  // TODO p1: taskUserAssignments is not updated if assigness are removed
  // Need to read in all exisitng taskUserAssignments and remove the ones that are not in the current task assigness 
      if (task.assignees.isNotEmpty) {
        final taskUserAssignments = task.assignees
            .map((user) => TaskUserAssignmentsModel(
                  taskId: task.task.id,
                  userId: user.id,
                ))
            .toList();
        await ref.read(taskUserAssignmentsDbProvider).upsertItems(taskUserAssignments);
      }
    
  }
}
