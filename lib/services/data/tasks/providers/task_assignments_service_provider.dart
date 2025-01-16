import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_user_assignment_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_user_assignments_repository.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final taskAssignmentsServiceProvider =
    Provider<TaskAssignmentsService>((ref) => TaskAssignmentsService(ref));

class TaskAssignmentsService {
  final Ref ref;

  TaskAssignmentsService(this.ref);

  Future<void> updateAssignees(
      {required String taskId, required List<UserModel> assignees}) async {
    final taskAssignmentsRepository =
        ref.read(taskUserAssignmentsRepositoryProvider);

    final taskAssignments = assignees
        .map((user) => TaskUserAssignmentModel(
              taskId: taskId,
              userId: user.id,
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

  Future<void> addAssignee(String taskId, UserModel assignee) async {
    final taskAssignmentsRepository =
        ref.read(taskUserAssignmentsRepositoryProvider);
    await taskAssignmentsRepository.upsertItem(TaskUserAssignmentModel(
      taskId: taskId,
      userId: assignee.id,
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
