import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_user_assignment_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_user_assignments_repository.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/providers/search_users_by_name_service_provider.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';

final taskAssignmentsServiceProvider =
    Provider<TaskAssignmentsService>((ref) => TaskAssignmentsService(ref));

class TaskAssignmentsService {
  final Ref ref;

  TaskAssignmentsService(this.ref);

  // userSearchQuery will be mapped to user first or last name when finding a match
  Future<List<SearchUserResult>> tryAssignUsersByName(
      String taskId, List<String> userSearchQuery) async {
    if (userSearchQuery.isEmpty) return [];

    final userAssignmentResults = <SearchUserResult>[];

    // TODO p4: show modal asking user to confirm assignment
    // And possibly choose between similar matches
    for (var userName in userSearchQuery) {
      final users = await ref
          .read(searchUsersByNameServiceProvider)
          .searchUsers(userName);
      if (users.isNotEmpty) {
        userAssignmentResults.add(users.first);
        await _addAssignee(taskId, users.first.id);
      }
    }

    return userAssignmentResults;
  }

  Future<void> updateAssignees(
      {required String taskId, required List<String> assigneeIds}) async {
    final taskAssignmentsRepository =
        ref.read(taskUserAssignmentsRepositoryProvider);

    final taskAssignments = assigneeIds
        .map((userId) => TaskUserAssignmentModel(
              taskId: taskId,
              userId: userId,
            ))
        .toList();

    // Delete removed assignments
    final previousAssignments =
        await taskAssignmentsRepository.getTaskAssignments(taskId: taskId);

    for (var assignment in previousAssignments) {
      if (!taskAssignments.any((e) => e.userId == assignment.userId)) {
        await taskAssignmentsRepository.deleteItem(assignment.id);
      }
    }

    //Add new assignments
    await taskAssignmentsRepository.upsertItems(taskAssignments);
  }

  Future<void> _addAssignee(String taskId, String userId) async {
    final taskAssignmentsRepository =
        ref.read(taskUserAssignmentsRepositoryProvider);
    await taskAssignmentsRepository.upsertItem(TaskUserAssignmentModel(
      taskId: taskId,
      userId: userId,
    ));
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
  }
}
