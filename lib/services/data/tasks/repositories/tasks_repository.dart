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
    // TODO p4: move this logic to backend
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
    final query = '''
      SELECT p.parent_org_id
      FROM tasks t
      JOIN projects p ON t.parent_project_id = p.id
      WHERE t.id = :task_id
    ''';

    final result = await db.execute(query, [taskId]);
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
