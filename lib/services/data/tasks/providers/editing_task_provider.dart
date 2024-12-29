import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_comment_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_comments_db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_user_assignments_db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_db_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final createTaskProvider = FutureProvider.autoDispose<TaskModel>((ref) async {
  final curUser = ref.read(curUserProvider).value;
  if (curUser == null) throw Exception('No current user');

  final defaultProject = await ref
      .read(projectsRepositoryProvider)
      .getProjectById(projectId: curUser.defaultProjectId ?? '');

  return TaskModel(
    name: 'New Task',
    description: '',
    status: StatusEnum.open,
    authorUserId: curUser.id,
    parentProjectId: defaultProject?.id,
  );
});

final editingTaskProvider =
    NotifierProvider<EditingTaskNotifier, AsyncValue<TaskModel?>>(() {
  return EditingTaskNotifier();
});

class EditingTaskNotifier extends Notifier<AsyncValue<TaskModel?>> {
  @override
  AsyncValue<TaskModel?> build() {
    return const AsyncValue.data(null);
  }

  // Core state mutations
  Future<void> createNewTask(
      {ProjectModel? project, StatusEnum? status}) async {
    state = const AsyncValue.loading();
    try {
      if (ref.read(curUserProvider).value case final curUser?) {
        final defaultProject = await ref
            .read(projectsRepositoryProvider)
            .getProjectById(projectId: curUser.defaultProjectId ?? '');

        final newTask = TaskModel.empty().copyWith(
          authorUser: curUser,
          task: TaskModel.defaultTask().copyWith(
            authorUserId: curUser.id,
            parentProjectId: project?.id ?? defaultProject?.id,
            status: status,
          ),
          project: project ?? defaultProject,
          assignees: [],
          comments: [],
        );

        state = AsyncValue.data(newTask);
      }
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.empty);
    }
  }

  void loadExistingTask(TaskModel task) {
    state = AsyncValue.data(task);
  }

  // Field updates
  void updateName(String name) {
    _updateTask((task) => task.copyWith(name: name));
  }

  void updateDescription(String? description) {
    _updateTask((task) => task.copyWith(description: description));
  }

  void updateStatus(StatusEnum? status) {
    _updateTask((task) => task.copyWith(status: status));
  }

  void updatePriority(PriorityEnum? priority) {
    _updateTask((task) => task.copyWith(priority: priority));
  }

  void updateDueDate(DateTime? dueDate) {
    _updateTask((task) => task.copyWith(dueDate: dueDate));
  }

  void updateAssignees(List<UserModel> assignees) {
    _updateJoinedTask((joined) => joined.copyWith(assignees: assignees));
  }

  void updateProject(ProjectModel? project) {
    _updateJoinedTask((joined) => joined.copyWith(
          project: project,
          task: joined.task.copyWith(parentProjectId: project?.id),
        ));
  }

  // Comments
  void addComment(String text) async {
    if (state.value == null) return;

    final curUser = ref.read(curUserProvider).value;
    if (curUser == null) return;

    final comment = TaskCommentModel(
      authorUserId: curUser.id,
      parentTaskId: state.value!.task.id,
      content: text,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    await ref.read(taskCommentsDbProvider).upsertItem(comment);
    _updateJoinedTask((joined) => joined.copyWith(
          comments: [...joined.comments, comment],
        ));
  }

  // Save all changes
  Future<void> saveChanges() async {
    if (state.value == null) return;

    final joinedTask = state.value!;

    // Save task
    await ref.read(tasksDbProvider).upsertItem(joinedTask.task);

    // Save assignees
    final assignments = joinedTask.assignees
        .map((user) => TaskUserAssignmentModel(
              taskId: joinedTask.task.id,
              userId: user.id,
            ))
        .toList();

    final assignmentsDb = ref.read(taskUserAssignmentsReadDbProvider);

    // Delete removed assignments
    final previousAssignments = await assignmentsDb.getItems(eqFilters: [
      {'key': 'task_id', 'value': joinedTask.task.id}
    ]);

    for (var assignment in previousAssignments) {
      if (!assignments.any((e) => e.userId == assignment.userId)) {
        await assignmentsDb.deleteItem(assignment.id);
      }
    }

    // Add new assignments
    await assignmentsDb.upsertItems(assignments);
  }

  // Helper methods
  void _updateTask(TaskModel Function(TaskModel) update) {
    if (state.value == null) return;
    _updateJoinedTask((joined) => joined.copyWith(
          task: update(joined.task),
        ));
  }

  void _updateJoinedTask(TaskModel Function(TaskModel) update) {
    if (state.value == null) return;
    state = AsyncValue.data(update(state.value!));
  }

  // Validation
  bool get isValid => state.value?.task.name.isNotEmpty ?? false;
}
