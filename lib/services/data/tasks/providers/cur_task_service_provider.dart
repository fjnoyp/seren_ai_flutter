import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_comment_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_user_assignment_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_task_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/joined_task_comments_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_comments_db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_user_assignments_db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_db_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final curTaskServiceProvider = Provider<CurTaskService>((ref) {
  return CurTaskService(ref);
});

class CurTaskService {
  final Ref ref;
  //final AsyncValue<JoinedTaskModel?> _state;
  final CurTaskStateNotifier _notifier;

  CurTaskService(this.ref)
      : _state = ref.watch(curTaskStateProvider),
        _notifier = ref.watch(curTaskStateProvider.notifier);

  void createTask({ProjectModel? project, StatusEnum? status}) {
    _notifier.setToNewTask(project: project, status: status);
  }

  void setTask(JoinedTaskModel joinedTask) {
    _notifier.setNewTask(joinedTask);
  }

  void updateAssignees(List<UserModel>? assignees) {
    if (_state.value != null) {
      _notifier.setNewTask(_state.value!.copyWith(assignees: assignees));
    }
  }

  void updateTask(TaskModel task) {
    if (_state.value != null) {
      _notifier.setNewTask(_state.value!.copyWith(task: task));
    }
  }

  void updateStatus(StatusEnum? status) {
    if (_state.value != null) {
      _notifier.setNewTask(_state.value!
          .copyWith(task: _state.value!.task.copyWith(status: status)));
    }
  }

  void updatePriority(PriorityEnum? priority) {
    if (_state.value != null) {
      _notifier.setNewTask(_state.value!
          .copyWith(task: _state.value!.task.copyWith(priority: priority)));
    }
  }

  void updateDescription(String? description) {
    if (_state.value != null) {
      _notifier.setNewTask(_state.value!.copyWith(
          task: _state.value!.task.copyWith(description: description)));
    }
  }

  void updateTaskName(String name) {
    if (_state.value != null) {
      _notifier.setNewTask(_state.value!
          .copyWith(task: _state.value!.task.copyWith(name: name)));
    }
  }

  void updateDueDate(DateTime dueDate) {
    if (_state.value != null) {
      _notifier.setNewTask(_state.value!
          .copyWith(task: _state.value!.task.copyWith(dueDate: dueDate)));
    }
  }

  void updateParentProject(ProjectModel? project) {
    if (_state.value != null) {
      _notifier.setNewTask(_state.value!.copyWith(
          task: _state.value!.task.copyWith(parentProjectId: project?.id),
          project: project));
    }
  }

  void addComment(String text) {
    if (_state.value != null) {
      final curUser = ref.read(curUserProvider).value;
      final comment = TaskCommentModel(
        authorUserId: curUser!.id,
        parentTaskId: _state.value!.task.id,
        content: text,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );
      ref.read(taskCommentsDbProvider).upsertItem(comment);
      _notifier.setNewTask(_state.value!
          .copyWith(comments: [..._state.value!.comments, comment]));
    }
  }

  Future<void> setReminder(int? reminderOffsetMinutes) async {
    if (_state.value != null) {
      _notifier.setNewTask(
        _state.value!.copyWith(
          task: _state.value!.task.copyWith(
            removeReminder: reminderOffsetMinutes == null,
            reminderOffsetMinutes: reminderOffsetMinutes,
          ),
        ),
      );
    }
  }

  Future<void> saveTask() async {
    // TODO p4: optimize by running all futures in parallel
    await ref.read(tasksDbProvider).upsertItem(_state.value!.task);

    final taskUserAssignments = _state.value!.assignees
        .map((user) => TaskUserAssignmentModel(
              taskId: _state.value!.task.id,
              userId: user.id,
            ))
        .toList();

    final taskUserAssignmentsDbProvider =
        ref.read(taskUserAssignmentsReadDbProvider);
    final previousAssignments =
        await taskUserAssignmentsDbProvider.getItems(eqFilters: [
      {'key': 'task_id', 'value': _state.value!.task.id}
    ]);
    for (var assignment in previousAssignments) {
      if (!taskUserAssignments.any((e) => e.userId == assignment.userId)) {
        await taskUserAssignmentsDbProvider.deleteItem(assignment.id);
      }
    }

    await taskUserAssignmentsDbProvider.upsertItems(taskUserAssignments);
  }
}
