import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';

final curEditingTaskIdNotifierProvider =
    NotifierProvider<EditingTaskIdNotifier, String?>(() {
  return EditingTaskIdNotifier();
});

class EditingTaskIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setTaskId(String taskId) => state = taskId;

  void clearTaskId() => state = null;

  Future<void> createNewTask() async {
    try {
      final curUser = ref.read(curUserProvider).value;
      if (curUser == null) throw Exception('No current user');

      final selectedProjectId = ref.read(curSelectedProjectIdNotifierProvider);
      if (selectedProjectId == null) throw Exception('No selected project');

      final newTask = TaskModel(
          name: 'New Task',
          description: '',
          status: StatusEnum.open,
          authorUserId: curUser.id,
          parentProjectId: selectedProjectId,
      );

      await ref.read(tasksRepositoryProvider).upsertItem(newTask);

      state = newTask.id;
    } catch (e, __) {
      throw Exception('Failed to create new task: $e');
    }
  }
}
