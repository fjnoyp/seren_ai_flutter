import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_queries.dart';

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository(ref.watch(dbProvider));
});

// TODO p5: use these enums in the updateTask methods instead
enum TaskFieldEnum {
  name,
  status,
  priority,
  assignees,
}

class TasksRepository extends BaseRepository<TaskModel> {
  const TasksRepository(super.db, {super.primaryTable = 'tasks'});

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
  Stream<List<TaskModel>> watchUserAssignedTasks({required String userId}) {
    return watch(
      TaskQueries.userAssignedTasksQuery,
      {'user_id': userId},
    );
  }

  // Get assigned tasks for a user (tasks where they are assigned to the task directly)
  Future<List<TaskModel>> getUserAssignedTasks({required String userId}) async {
    return get(
      TaskQueries.userAssignedTasksQuery,
      {'user_id': userId},
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

  Future<void> updateTaskName(String taskId, String? name) async {
    if (name == null) return;

    await updateField(
      taskId,
      'name',
      name,
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

    await updateField(
      taskId,
      'status',
      status.name,
    );
  }

  Future<void> updateTaskPriority(String taskId, PriorityEnum? priority) async {
    if (priority == null) return;

    await updateField(
      taskId,
      'priority',
      priority.name,
    );
  }

  Future<void> updateTaskDueDate(String taskId, DateTime? dueDate) async {
    await updateField(
      taskId,
      'due_date',
      dueDate?.toIso8601String(),
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
  }

  Future<void> updateTaskStartDateTime(
    String taskId,
    DateTime? startDateTime,
  ) async {
    await updateField(
      taskId,
      'start_date_time',
      startDateTime?.toIso8601String(),
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

  Stream<List<TaskModel>> watchUserViewableTasksInRange({
    required String userId,
    required String orgId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return watch(
      TaskQueries.userViewableTasksInRangeQuery,
      {
        'user_id': userId,
        'author_user_id': userId,
        'org_id': orgId,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
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
