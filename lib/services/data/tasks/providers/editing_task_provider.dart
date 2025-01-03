import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/selected_project_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_comment_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_user_assignment_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_comments_db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_user_assignments_db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_db_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final editingTaskProvider =
    NotifierProvider<EditingTaskNotifier, AsyncValue<TaskModel>>(() {
  return EditingTaskNotifier();
});

class EditingTaskNotifier extends Notifier<AsyncValue<TaskModel>> {
  @override
  AsyncValue<TaskModel> build() {
    return const AsyncValue.data(TaskModel.empty());
  }

  Future<void> createNewTask() async {
    state = const AsyncValue.loading();
    try {
      final curUser = ref.read(curUserProvider).value;
      if (curUser == null) throw Exception('No current user');

      final selectedProjectAsync = ref.watch(selectedProjectProvider);

      final newTask = await selectedProjectAsync.when(
        data: (project) => TaskModel(
          name: 'New Task',
          description: '',
          status: StatusEnum.open,
          authorUserId: curUser.id,
          parentProjectId: project.id,
        ),
        loading: () => throw Exception('Project is still loading'),
        error: (err, stack) => throw Exception('Failed to load project: $err'),
      );

      state = AsyncValue.data(newTask);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void loadExistingTask(TaskModel task) {
    state = AsyncValue.data(task);
  }

  // Consolidated update method
  void update({
    String? name,
    String? description,
    StatusEnum? status,
    PriorityEnum? priority,
    DateTime? dueDate,
    List<UserModel>? assignees,
    ProjectModel? project,
  }) {
    state.whenData((currentTask) {
      final updatedTask = currentTask.copyWith(
        name: name ?? currentTask.name,
        description: description ?? currentTask.description,
        status: status ?? currentTask.status,
        priority: priority ?? currentTask.priority,
        dueDate: dueDate ?? currentTask.dueDate,
        assignees: assignees ?? currentTask.assignees,
        project: project ?? currentTask.project,
        parentProjectId: project?.id ?? currentTask.parentProjectId,
      );
      state = AsyncValue.data(updatedTask);
    });
  }

  // how will comments and assignees, children tasks be handled?
  // since those are fields not on the current task we're editing

  // we should just be updating everything in real time any way ....
  // so we don't need to cache all the changes and then save them out
  // later ...

  // so one to many relationships, those updates should be handled in a separate repo with separate providers for listening to those values too ...

  // Future<void> addComment(String text) async {
  //   final curUser = ref.read(curUserProvider).value;
  //   if (curUser == null) return;

  //   state.whenData((currentTask) async {
  //     final comment = TaskCommentModel(
  //       authorUserId: curUser.id,
  //       parentTaskId: currentTask.id,
  //       content: text,
  //       createdAt: DateTime.now().toUtc(),
  //       updatedAt: DateTime.now().toUtc(),
  //     );

  //     await ref.read(taskCommentsDbProvider).upsertItem(comment);

  //     final updatedTask = currentTask.copyWith(
  //       comments: [...currentTask.comments, comment],
  //     );
  //     state = AsyncValue.data(updatedTask);
  //   });
  // }

  Future<void> saveChanges() async {
    state.whenData((task) async {
      // Save task
      await ref.read(tasksDbProvider).upsertItem(task);

      // Save assignees
      final assignments = task.assignees
          .map((user) => TaskUserAssignmentModel(
                taskId: task.id,
                userId: user.id,
              ))
          .toList();

      final assignmentsDb = ref.read(taskUserAssignmentsReadDbProvider);

      // Delete removed assignments
      final previousAssignments = await assignmentsDb.getItems(eqFilters: [
        {'key': 'task_id', 'value': task.id}
      ]);

      for (var assignment in previousAssignments) {
        if (!assignments.any((e) => e.userId == assignment.userId)) {
          await assignmentsDb.deleteItem(assignment.id);
        }
      }

      // Add new assignments
      await assignmentsDb.upsertItems(assignments);
    });
  }

  bool get isValid => state.valueOrNull?.name.isNotEmpty ?? false;
}
