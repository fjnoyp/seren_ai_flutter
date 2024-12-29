import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_comment_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';

extension TaskCommentsModelRelationships on TaskCommentModel {
  // Relationship loading methods
  Future<UserModel?> getAuthor(Ref ref) async {
    if (authorUserId.isEmpty) return null;
    return ref.read(usersRepositoryProvider).getUser(
          userId: authorUserId,
        );
  }

  Future<TaskModel?> getParentTask(Ref ref) async {
    if (parentTaskId.isEmpty) return null;
    return ref.read(tasksRepositoryProvider).getTaskById(
          taskId: parentTaskId,
        );
  }
}
