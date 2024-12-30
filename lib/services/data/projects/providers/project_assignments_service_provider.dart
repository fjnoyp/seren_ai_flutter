import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/models/user_project_assignment_model.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/user_project_assignments_repository.dart';
import 'package:seren_ai_flutter/services/data/projects/user_project_assignments_db_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final projectAssignmentsServiceProvider =
    Provider.family<ProjectAssignmentsService, String>(
        (ref, projectId) => ProjectAssignmentsService(ref, projectId));

class ProjectAssignmentsService {
  final Ref ref;
  final String projectId;

  ProjectAssignmentsService(this.ref, this.projectId);

  Future<void> updateAssignees(List<UserModel>? assignees) async {
    if (assignees == null) return;

    final userProjectAssignmentsDb = ref.read(userProjectAssignmentsDbProvider);

    final previousAssignments = await ref
        .read(userProjectAssignmentsRepositoryProvider)
        .getUserProjectAssignments(projectId: projectId);

    for (var assignment in previousAssignments) {
      if (!assignees.any((e) => e.id == assignment.id)) {
        await userProjectAssignmentsDb.deleteItem(assignment.id);
      }
    }

    // Only create new assignments for users that weren't previously assigned
    final newAssignments = assignees
        .where((newAssignee) => !previousAssignments
            .any((prevAssignee) => prevAssignee.id == newAssignee.id))
        .map((e) =>
            UserProjectAssignmentModel(projectId: projectId, userId: e.id))
        .toList();

    if (newAssignments.isNotEmpty) {
      await userProjectAssignmentsDb.upsertItems(newAssignments);
    }
  }
}
