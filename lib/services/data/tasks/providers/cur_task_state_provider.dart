import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

final curTaskStateProvider =
    NotifierProvider<CurTaskStateNotifier, AsyncValue<JoinedTaskModel?>>(() {
  return CurTaskStateNotifier();
});

class CurTaskStateNotifier extends Notifier<AsyncValue<JoinedTaskModel?>> {
  @override
  AsyncValue<JoinedTaskModel?> build() {
    return const AsyncValue.data(null);
  }

  void setNewTask(JoinedTaskModel joinedTask) {
    state = AsyncValue.data(joinedTask);
  }

  Future<void> setToNewTask({ProjectModel? project, StatusEnum? status}) async {
    state = const AsyncValue.loading();
    try {
      if (ref.read(curUserProvider).value case final curUser?) {
        final defaultProject = await ref
            .read(projectsRepositoryProvider)
            .getProjectById(projectId: curUser.defaultProjectId ?? '');

        final newTask = JoinedTaskModel.empty().copyWith(
          authorUser: curUser,
          task: TaskModel.defaultTask().copyWith(
            authorUserId: curUser.id,
            parentProjectId: project?.id ?? defaultProject?.id,
            status: status,
          ),
          project: project ?? defaultProject,
        );

        state = AsyncValue.data(newTask);
      } else {
        throw Exception('Error: Current user is not authenticated.');
      }
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.empty);
    }
  }
}
