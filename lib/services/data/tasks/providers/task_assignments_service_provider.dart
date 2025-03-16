import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_user_assignment_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_user_assignments_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';
import 'package:seren_ai_flutter/services/notifications/task_notification_service.dart';

final taskAssignmentsServiceProvider =
    Provider<TaskAssignmentsService>((ref) => TaskAssignmentsService(ref));

class TaskAssignmentsService {
  final Ref ref;

  TaskAssignmentsService(this.ref);

  // Try to assign users found from <userSearchQuery> to the task
  Future<List<SearchUserResult>> tryAssignUsersByName(
      String taskId, List<String> userSearchQuery) async {
    if (userSearchQuery.isEmpty) return [];

    final userAssignmentResults = <SearchUserResult>[];

    final orgId = ref.read(curSelectedOrgIdNotifierProvider);
    if (orgId == null) return [];

    // TODO p4: show modal asking user to confirm assignment
    // And possibly choose between similar matches
    for (var userName in userSearchQuery) {
      final users = await ref.read(usersRepositoryProvider).searchUsersByName(
            searchQuery: userName,
            orgId: orgId,
          );
      if (users.isNotEmpty) {
        userAssignmentResults.add(users.first);
        await addAssignee(taskId, users.first.id);
      }
    }

    return userAssignmentResults;
  }

  Future<void> updateAssignees({
    required String taskId,
    required List<String> assigneeIds,
  }) async {
    final taskAssignmentsRepository =
        ref.read(taskUserAssignmentsRepositoryProvider);

    final task = await ref.read(tasksRepositoryProvider).getById(taskId);
    if (task == null) return;

    final taskAssignments = assigneeIds
        .map((userId) => TaskUserAssignmentModel(
              taskId: taskId,
              userId: userId,
            ))
        .toList();

    // Get previous assignments for comparison
    final previousAssignments =
        await taskAssignmentsRepository.getTaskAssignments(taskId: taskId);

    // Handle removals
    for (var assignment in previousAssignments) {
      if (!assigneeIds.contains(assignment.userId)) {
        await taskAssignmentsRepository.deleteItem(assignment.id);

        await ref
            .read(taskNotificationServiceProvider)
            .handleTaskAssignmentChange(
              taskId: taskId,
              affectedUserId: assignment.userId,
              isAssignment: false,
            );
      }
    }

    // Handle new assignments
    for (var newAssignment in taskAssignments) {
      if (!previousAssignments
          .any((prev) => prev.userId == newAssignment.userId)) {
        await taskAssignmentsRepository.upsertItem(newAssignment);

        await ref
            .read(taskNotificationServiceProvider)
            .handleTaskAssignmentChange(
              taskId: taskId,
              affectedUserId: newAssignment.userId,
              isAssignment: true,
            );
      }
    }
  }

  Future<void> addAssignee(String taskId, String userId) async {
    final taskAssignmentsRepository =
        ref.read(taskUserAssignmentsRepositoryProvider);

    await taskAssignmentsRepository.upsertItem(TaskUserAssignmentModel(
      taskId: taskId,
      userId: userId,
    ));

    await ref.read(taskNotificationServiceProvider).handleTaskAssignmentChange(
          taskId: taskId,
          affectedUserId: userId,
          isAssignment: true,
        );
  }

  Future<void> removeAssignee(String taskId, UserModel assignee) async {
    final taskAssignmentsRepository =
        ref.read(taskUserAssignmentsRepositoryProvider);

    final assignmentId = await taskAssignmentsRepository.getTaskAssignmentId(
      taskId: taskId,
      userId: assignee.id,
    );

    if (assignmentId == null) return;

    await taskAssignmentsRepository.deleteItem(assignmentId);

    await ref.read(taskNotificationServiceProvider).handleTaskAssignmentChange(
          taskId: taskId,
          affectedUserId: assignee.id,
          isAssignment: false,
        );
  }
}
