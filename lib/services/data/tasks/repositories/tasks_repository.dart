import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_queries.dart';
import 'package:seren_ai_flutter/services/notifications/task_notification_service.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_field_enum.dart';

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository(ref.watch(dbProvider), ref);
});

class TasksRepository extends BaseRepository<TaskModel> {
  final Ref ref;

  const TasksRepository(super.db, this.ref, {super.primaryTable = 'tasks'});

  @override
  TaskModel fromJson(Map<String, dynamic> json) {
    return TaskModel.fromJson(json);
  }

  // Watch viewable tasks for a user (tasks where they are assigned to the project or are the author)
  Stream<List<TaskModel>> watchUserViewableTasks({
    required String userId,
    required String orgId,
  }) {
    return watch(
      TaskQueries.userViewableTasksQuery,
      {
        'user_id': userId,
        'org_id': orgId,
      },
      triggerOnTables: {
        'tasks',
        'user_project_assignments',
        'team_project_assignments',
        'user_team_assignments',
        'projects',
        'user_org_roles',
      },
    );
  }

  // TODO p2: introduce pagination once we have a lot of tasks
  // Get viewable tasks for a user (tasks where they are assigned to the project or are the author)
  Future<List<TaskModel>> getUserViewableTasks({
    required String userId,
    required String orgId,
  }) async {
    return get(
      TaskQueries.userViewableTasksQuery,
      {
        'user_id': userId,
        'org_id': orgId,
      },
    );
  }

  // Watch assigned tasks for a user (tasks where they are assigned to the task directly)
  Stream<List<TaskModel>> watchUserAssignedTasks({
    required String userId,
    required String orgId,
  }) {
    return watch(
      TaskQueries.userAssignedTasksQuery,
      {
        'user_id': userId,
        'org_id': orgId,
      },
      triggerOnTables: {
        'tasks',
        'task_user_assignments',
        'projects',
      },
    );
  }

  // Get assigned tasks for a user (tasks where they are assigned to the task directly)
  Future<List<TaskModel>> getUserAssignedTasks({
    required String userId,
    required String orgId,
  }) async {
    return get(
      TaskQueries.userAssignedTasksQuery,
      {
        'user_id': userId,
        'org_id': orgId,
      },
    );
  }

  Stream<List<TaskModel>> watchChildTasks({required String parentTaskId}) {
    return watch(
      TaskQueries.getTasksByParentIdQuery,
      {'parent_task_id': parentTaskId},
    );
  }

  Future<List<TaskModel>> getChildTasks({
    required String parentTaskId,
  }) {
    return get(
      TaskQueries.getTasksByParentIdQuery,
      {'parent_task_id': parentTaskId},
    );
  }

  Future<List<String>> getChildTaskIds({
    required String parentTaskId,
  }) async {
    final result =
        await db.execute(TaskQueries.getTasksByParentIdQuery, [parentTaskId]);
    return result.map((row) => row['id'] as String).toList();
  }

  Stream<List<TaskModel>> watchTasksByProject({required String projectId}) {
    return watch(
      TaskQueries.getTasksByProjectIdQuery,
      {'project_id': projectId},
    );
  }

  Future<List<TaskModel>> getTasksByProject({required String projectId}) async {
    return get(
      TaskQueries.getTasksByProjectIdQuery,
      {'project_id': projectId},
    );
  }

  Stream<List<TaskModel>> watchParentTasksByProject(
      {required String projectId}) {
    return watch(
      TaskQueries.getParentTasksByProjectIdQuery,
      {'project_id': projectId},
    );
  }

  Future<List<TaskModel>> getParentTasksByProject(
      {required String projectId}) async {
    return get(
      TaskQueries.getParentTasksByProjectIdQuery,
      {'project_id': projectId},
    );
  }

  Future<void> updateTaskName(String taskId, String? name) async {
    if (name == null) return;

    final task = await getById(taskId);
    if (task == null) return;

    final oldName = task.name;
    await updateField(taskId, 'name', name);

    await ref.read(taskNotificationServiceProvider).handleTaskFieldUpdate(
          taskId: taskId,
          field: TaskFieldEnum.name,
          oldValue: oldName,
          newValue: name,
        );
  }

  Future<void> updateTaskDescription(String taskId, String? description) async {
    await updateField(
      taskId,
      'description',
      description,
    );
  }

  Future<void> updateTaskStatus(String taskId, StatusEnum? status) async {
    if (status == null) return;

    final task = await getById(taskId);
    if (task == null) return;

    final oldStatus = task.status;
    await updateField(taskId, 'status', status.name);

    await ref.read(taskNotificationServiceProvider).handleTaskFieldUpdate(
          taskId: taskId,
          field: TaskFieldEnum.status,
          oldValue: oldStatus,
          newValue: status,
        );

    if (status == StatusEnum.inProgress && task.startDateTime == null) {
      await updateTaskStartDateTime(taskId, DateTime.now());
    } else if (status == StatusEnum.finished && task.dueDate == null) {
      await updateTaskDueDate(taskId, DateTime.now());
    }

    // Handle child task status updates
    if (task.isPhase) {
      await _handleChildTasksStatus(task.id, status);
    }
    // Handle parent task status updates
    else if (task.parentTaskId != null) {
      await _handleParentTaskStatus(task.parentTaskId!, status);
    }
  }

  // New method to handle parent task status updates
  Future<void> _handleParentTaskStatus(
      String parentTaskId, StatusEnum childStatus) async {
    // If child task is set to inProgress, set parent to inProgress
    if (childStatus == StatusEnum.inProgress) {
      await updateTaskStatus(parentTaskId, StatusEnum.inProgress);
      return;
    }

    // If child task is set to any other status, check sibling tasks (this will include the child task itself)
    final siblingTasks = await getChildTasks(parentTaskId: parentTaskId);

    // Get all active sibling tasks
    final activeSiblingTasks = siblingTasks.where((t) => t.isActive).toList();

    // If all sibling tasks are inactive (archived or cancelled),
    // set parent task to the appropriate status
    if (activeSiblingTasks.isEmpty) {
      final allTasksCancelled =
          siblingTasks.every((t) => t.status == StatusEnum.cancelled);
      if (allTasksCancelled) {
        await updateTaskStatus(parentTaskId, StatusEnum.cancelled);
      } else {
        await updateTaskStatus(parentTaskId, StatusEnum.archived);
      }
      return;
    }

    // If not all sibling tasks are inactive, check only active siblings:

    // If all active sibling tasks are open, set parent task to open
    bool allActiveTasksOpen =
        activeSiblingTasks.every((t) => t.status == StatusEnum.open);
    if (allActiveTasksOpen) {
      await updateTaskStatus(parentTaskId, StatusEnum.open);
      return;
    }

    // If all active sibling tasks are finished, set parent task to finished
    bool allActiveTasksFinished =
        activeSiblingTasks.every((t) => t.status == StatusEnum.finished);
    if (allActiveTasksFinished) {
      await updateTaskStatus(parentTaskId, StatusEnum.finished);
    }
    // Otherwise, do nothing
  }

  Future<void> _handleChildTasksStatus(
      String parentTaskId, StatusEnum status) async {
    // If parent task is set to finished or open, set all ACTIVE child tasks to the parent's status
    if (status == StatusEnum.finished || status == StatusEnum.open) {
      final activeChildTasks = (await getChildTasks(parentTaskId: parentTaskId))
          .where((t) => t.isActive)
          .toList();
      for (final task in activeChildTasks) {
        await updateTaskStatus(task.id, status);
      }
      return;
    }

    // If parent task is set to cancelled or archived, set all child tasks to the parent's status
    if (status == StatusEnum.cancelled || status == StatusEnum.archived) {
      final childTaskIds = await getChildTaskIds(parentTaskId: parentTaskId);
      for (final taskId in childTaskIds) {
        await updateTaskStatus(taskId, status);
      }
    }
  }

  Future<void> updateTaskPriority(String taskId, PriorityEnum? priority) async {
    if (priority == null) return;

    final task = await getById(taskId);
    if (task == null) return;

    final oldPriority = task.priority;
    await updateField(taskId, 'priority', priority.name);

    await ref.read(taskNotificationServiceProvider).handleTaskFieldUpdate(
          taskId: taskId,
          field: TaskFieldEnum.priority,
          oldValue: oldPriority,
          newValue: priority,
        );
  }

  Future<void> updateTaskDueDate(String taskId, DateTime? dueDate) async {
    await updateField(
      taskId,
      'due_date',
      dueDate?.toUtc().toIso8601String(),
    );

    // If due date is set, check if it's after the parent task's due date
    // If it is, update the parent task's due date to the child task's due date
    final task = await getById(taskId);
    if (task != null && dueDate != null && task.parentTaskId != null) {
      final parentTask = await getById(task.parentTaskId!);
      if (parentTask != null && parentTask.dueDate?.isBefore(dueDate) == true) {
        await updateTaskDueDate(
          task.parentTaskId!,
          dueDate,
        );
      }
    }

    // If due date is null, set reminder offset to null
    // never used, since we currently don't have a way to set due date to null
    if (dueDate == null) {
      await updateField(
        taskId,
        'reminder_offset_minutes',
        null,
      );
    }

    await ref
        .read(taskNotificationServiceProvider)
        .handleTaskReminder(taskId: taskId);
  }

  /// Gets the parent organization ID for a task
  /// This is determined by the task's project's organization
  Future<String?> getTaskParentOrgId(String taskId) async {
    final result =
        await db.execute(TaskQueries.getTaskParentOrgIdQuery, [taskId]);
    return result.isEmpty ? null : result.first['parent_org_id'] as String?;
  }

  Future<void> updateTaskParentProjectId(
    String taskId,
    String? parentProjectId,
  ) async {
    if (parentProjectId == null) return;

    await updateField(
      taskId,
      'parent_project_id',
      parentProjectId,
    );
  }

  Future<void> updateTaskReminderOffsetMinutes(
    String taskId,
    int? reminderOffsetMinutes,
  ) async {
    await updateField(
      taskId,
      'reminder_offset_minutes',
      reminderOffsetMinutes,
    );

    await ref
        .read(taskNotificationServiceProvider)
        .handleTaskReminder(taskId: taskId);
  }

  Future<void> updateTaskEstimatedDurationMinutes(
    String taskId,
    int? estimatedDurationMinutes,
  ) async {
    await updateField(
      taskId,
      'estimated_duration_minutes',
      estimatedDurationMinutes,
    );

    // Auto set due date if it's not set and the task has a start date and estimated duration
    final task = await getById(taskId);
    if (task != null &&
        estimatedDurationMinutes != null &&
        task.startDateTime != null &&
        task.dueDate == null) {
      await updateTaskDueDate(
        taskId,
        task.startDateTime!.add(
          Duration(minutes: estimatedDurationMinutes),
        ),
      );
    }
  }

  Future<void> updateTaskStartDateTime(
    String taskId,
    DateTime? startDateTime,
  ) async {
    await updateField(
      taskId,
      'start_date_time',
      startDateTime?.toUtc().toIso8601String(),
    );

    // If start date is set, check if it's before the parent task's start date
    // If it is, update the parent task's start date to the child task's start date
    final task = await getById(taskId);
    if (task != null && startDateTime != null && task.parentTaskId != null) {
      final parentTask = await getById(task.parentTaskId!);
      if (parentTask != null &&
          parentTask.startDateTime?.isAfter(startDateTime) == true) {
        await updateTaskStartDateTime(
          task.parentTaskId!,
          startDateTime,
        );
      }
    }
  }

  Future<void> updateTaskParentTaskId(
    String taskId,
    String? parentTaskId,
  ) async {
    await updateField(
      taskId,
      'parent_task_id',
      parentTaskId,
    );

    // If parent task id is set, check if it's after the parent task's start date
    // If it is, handle task parent's start date and due date
    if (parentTaskId != null) {
      final task = await getById(taskId);
      if (task != null) {
        final parentTask = await getById(parentTaskId);
        if (parentTask != null) {
          // Handle start date
          if (task.startDateTime != null &&
              parentTask.startDateTime?.isAfter(task.startDateTime!) == true) {
            await updateTaskStartDateTime(
              parentTaskId,
              task.startDateTime,
            );
          }

          // Handle due date
          if (task.dueDate != null &&
              parentTask.dueDate?.isBefore(task.dueDate!) == true) {
            await updateTaskDueDate(
              parentTaskId,
              task.dueDate,
            );
          }
        }
      }
    }
  }

  Future<void> updateTaskBlockedByTaskId(
    String taskId,
    String? blockedByTaskId,
  ) async {
    await updateField(
      taskId,
      'blocked_by_task_id',
      blockedByTaskId,
    );
  }

  Stream<List<TaskModel>> watchRecentlyUpdatedTasks({
    required String userId,
    required String orgId,
    int limit = 20,
  }) {
    return watch(
      TaskQueries.recentlyUpdatedTasksQuery,
      {
        'user_id': userId,
        'org_id': orgId,
        'limit': limit,
      },
      triggerOnTables: {
        'tasks',
        'user_project_assignments',
        'team_project_assignments',
        'user_team_assignments',
        'projects',
        'user_org_roles',
      },
    );
  }
}
