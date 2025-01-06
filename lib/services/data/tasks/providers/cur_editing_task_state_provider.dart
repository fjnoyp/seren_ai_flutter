import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/selected_project_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_comment_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_user_assignment_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_comments_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_user_assignments_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';

final curEditingTaskStateProvider =
    NotifierProvider<EditingTaskNotifier, AsyncValue<EditingTaskState>>(() {
  return EditingTaskNotifier();
});

class EditingTaskState {
  TaskModel taskModel;
  List<TaskCommentModel> comments;
  List<UserModel> assignees;

  EditingTaskState({
    required this.taskModel,
    required this.comments,
    required this.assignees,
  });

  EditingTaskState copyWith({
    TaskModel? taskModel,
    List<TaskCommentModel>? comments,
    List<UserModel>? assignees,
  }) {
    return EditingTaskState(
      taskModel: taskModel ?? this.taskModel,
      comments: comments ?? this.comments,
      assignees: assignees ?? this.assignees,
    );
  }
}

class EditingTaskNotifier extends Notifier<AsyncValue<EditingTaskState>> {
  @override
  AsyncValue<EditingTaskState> build() {
    return AsyncValue.data(EditingTaskState(
      taskModel: TaskModel.empty(),
      comments: [],
      assignees: [],
    ));
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

      state = AsyncValue.data(EditingTaskState(
        taskModel: newTask,
        comments: [],
        assignees: [],
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setTask(TaskModel task) async {
    state = const AsyncValue.loading();
    try {
      final comments =
          await ref.read(taskCommentsRepositoryProvider).getTaskComments(
                taskId: task.id,
              );

      final assignees =
          await ref.read(usersRepositoryProvider).getTaskAssignedUsers(
                taskId: task.id,
              );

      state = AsyncValue.data(EditingTaskState(
        taskModel: task,
        comments: comments,
        assignees: assignees,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Consolidated update method
  void updateTaskFields({
    String? name,
    String? description,
    StatusEnum? status,
    PriorityEnum? priority,
    DateTime? dueDate,
    String? parentProjectId,
    int? reminderOffsetMinutes,
  }) {
    state.whenData((currentState) {
      final currentTask = currentState.taskModel;
      final updatedTask = currentTask.copyWith(
          name: name ?? currentTask.name,
          description: description ?? currentTask.description,
          status: status ?? currentTask.status,
          priority: priority ?? currentTask.priority,
          dueDate: dueDate ?? currentTask.dueDate,
          parentProjectId: parentProjectId ?? currentTask.parentProjectId,
          reminderOffsetMinutes:
              reminderOffsetMinutes ?? currentTask.reminderOffsetMinutes);
      state = AsyncValue.data(currentState.copyWith(taskModel: updatedTask));
    });
  }

  Future<void> saveAndAddComment(TaskCommentModel comment) async {
    await ref.read(taskCommentsRepositoryProvider).upsertItem(comment);

    state.whenData((currentState) {
      final updatedState =
          currentState.copyWith(comments: [...currentState.comments, comment]);
      state = AsyncValue.data(updatedState);
    });
  }

  void updateAssignees({required List<UserModel> assignees}) {
    state.whenData((currentState) {
      final updatedState = currentState.copyWith(assignees: assignees);
      state = AsyncValue.data(updatedState);
    });
  }

  void addAssignee(UserModel assignee) {
    state.whenData((currentState) {
      final updatedState = currentState
          .copyWith(assignees: [...currentState.assignees, assignee]);
      state = AsyncValue.data(updatedState);
    });
  }

  void removeAssignee(UserModel assignee) {
    state.whenData((currentState) {
      final updatedState = currentState.copyWith(
          assignees: currentState.assignees
              .where((e) => e.id != assignee.id)
              .toList());
      state = AsyncValue.data(updatedState);
    });
  }

  Future<void> saveChanges() async {
    state.whenData((currentState) async {
      // === Save task ===
      await ref
          .read(tasksRepositoryProvider)
          .upsertItem(currentState.taskModel);

      // === Comments are saved immediately ===

      // === Save assignees ===
      final currentTask = currentState.taskModel;

      final assignments = currentState.assignees
          .map((user) => TaskUserAssignmentModel(
                taskId: currentTask.id,
                userId: user.id,
              ))
          .toList();

      final assignmentsDb = ref.read(taskUserAssignmentsRepositoryProvider);

      // Delete removed assignments
      final previousAssignments =
          await assignmentsDb.getTaskAssignments(taskId: currentTask.id);

      for (var assignment in previousAssignments) {
        if (!assignments.any((e) => e.userId == assignment.userId)) {
          await assignmentsDb.deleteItem(assignment.id);
        }
      }

      //Add new assignments
      await assignmentsDb.upsertItems(assignments);
    });
  }

  bool get isValid => state.valueOrNull?.taskModel.name.isNotEmpty ?? false;
}
