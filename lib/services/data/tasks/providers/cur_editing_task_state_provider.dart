import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/selected_project_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_user_assignment_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_user_assignments_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';

// TODO p0: switch to immediate edit system
// The current code is inconsistent ...
// The assignees and other task fields are not changed immediately
// But the comments are
// And the comment changes are watched via the commentsProvider and not via the curEditingTaskStateProvider ...

// Ideally the ai editing of state will happen by ONLY knowing the current task id ...
// So even new tasks should be created immediately
// Then the ai just needs to make calls to the taskrepository
// And all UI code shoudl just show the watched data of taskrepository ...

final curEditingTaskStateProvider =
    NotifierProvider<EditingTaskNotifier, AsyncValue<EditingTaskState>>(() {
  return EditingTaskNotifier();
});

// Since comments are saved immediately, they aren't managed by this provider
class EditingTaskState {
  TaskModel taskModel;
  List<UserModel> assignees;

  EditingTaskState({
    required this.taskModel,
    required this.assignees,
  });

  EditingTaskState copyWith({
    TaskModel? taskModel,
    List<UserModel>? assignees,
  }) {
    return EditingTaskState(
      taskModel: taskModel ?? this.taskModel,
      assignees: assignees ?? this.assignees,
    );
  }
}

class EditingTaskNotifier extends Notifier<AsyncValue<EditingTaskState>> {
  @override
  AsyncValue<EditingTaskState> build() {
    return const AsyncValue.loading();
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

      await ref.read(tasksRepositoryProvider).insertItem(newTask);

      state = AsyncValue.data(EditingTaskState(
        taskModel: newTask,
        assignees: [],
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setTask(TaskModel task) async {
    state = const AsyncValue.loading();
    try {
      final assignees =
          await ref.read(usersRepositoryProvider).getTaskAssignedUsers(
                taskId: task.id,
              );

      state = AsyncValue.data(EditingTaskState(
        taskModel: task,
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
    state.whenData((currentState) async {
      final currentTask = currentState.taskModel;
      final updatedTask = currentTask.copyWith(
        name: name ?? currentTask.name,
        description: description ?? currentTask.description,
        status: status ?? currentTask.status,
        priority: priority ?? currentTask.priority,
        dueDate: dueDate ?? currentTask.dueDate,
        parentProjectId: parentProjectId ?? currentTask.parentProjectId,
        reminderOffsetMinutes:
            reminderOffsetMinutes ?? currentTask.reminderOffsetMinutes,
        removeReminder: reminderOffsetMinutes == null,
      );

      await ref.read(tasksRepositoryProvider).updateItem(updatedTask);

      state = AsyncValue.data(currentState.copyWith(taskModel: updatedTask));
    });
  }

  void updateAssignees({required List<UserModel> assignees}) {
    state.whenData((currentState) async {
      final currentTask = currentState.taskModel;
      final assignments = assignees
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

      state = AsyncValue.data(currentState.copyWith(assignees: assignees));
    });
  }

  void addAssignee(UserModel assignee) {
    state.whenData((currentState) async {
      final currentTask = currentState.taskModel;
      await ref
          .read(taskUserAssignmentsRepositoryProvider)
          .upsertItem(TaskUserAssignmentModel(
            taskId: currentTask.id,
            userId: assignee.id,
          ));

      state = AsyncValue.data(currentState.copyWith(assignees: [
        ...currentState.assignees,
        assignee,
      ]));
    });
  }

  void removeAssignee(UserModel assignee) {
    state.whenData((currentState) async {
      final currentTask = currentState.taskModel;
      final assignmentId = await ref
          .read(taskUserAssignmentsRepositoryProvider)
          .getTaskAssignmentId(
            taskId: currentTask.id,
            userId: assignee.id,
          );

      if (assignmentId != null) {
        await ref
            .read(taskUserAssignmentsRepositoryProvider)
            .deleteItem(assignmentId);
      }

      state = AsyncValue.data(currentState.copyWith(assignees: [
        ...currentState.assignees.where((user) => user.id != assignee.id),
      ]));
    });
  }

  Future<void> deleteNewTask() async {
    state.whenData((currentState) async {
      final currentTask = currentState.taskModel;

      for (var assignee in currentState.assignees) {
        final assignmentId = await ref
            .read(taskUserAssignmentsRepositoryProvider)
            .getTaskAssignmentId(
              taskId: currentTask.id,
              userId: assignee.id,
            );

        if (assignmentId != null) {
          await ref
              .read(taskUserAssignmentsRepositoryProvider)
              .deleteItem(assignmentId);
        }
      }

      await ref.read(tasksRepositoryProvider).deleteItem(currentTask.id);

      state = const AsyncValue.loading();
    });
  }

  Future<Map<String, dynamic>> toReadableMap() async {
    final value = state
        .whenData((currentState) => {
              'task': {
                'name': currentState.taskModel.name,
                'description': currentState.taskModel.description,
                'status': currentState.taskModel.status,
                'due_date': currentState.taskModel.dueDate?.toIso8601String(),
              },
              'assignees':
                  currentState.assignees.map((user) => user.email).toList(),
            })
        .value;

    return value ?? {};
  }

  bool get isValid => state.valueOrNull?.taskModel.name.isNotEmpty ?? false;
}
