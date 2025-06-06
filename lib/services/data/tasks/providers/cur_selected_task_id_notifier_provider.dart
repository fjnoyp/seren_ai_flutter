import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final curSelectedTaskIdNotifierProvider =
    NotifierProvider<CurSelectedTaskIdNotifier, String?>(() {
  return CurSelectedTaskIdNotifier();
});

class CurSelectedTaskIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setTaskId(String taskId) => state = taskId;

  void clearTaskId() => state = null;

  Future<String> createNewTask({
    bool isPhase = false,
    String? initialProjectId,
    String? initialParentTaskId,
    StatusEnum? initialStatus,
    bool updateState = false,
  }) async {
    assert(!isPhase || initialParentTaskId == null,
        'Error: initialParentTaskId cannot be set for phase tasks');
    try {
      final curUser = ref.read(curUserProvider).value;
      if (curUser == null) throw Exception('No current user');

      // If initialProjectId is set and is not "everything", use it
      // Otherwise, get the default project
      final parentProjectId = initialProjectId != null &&
              !CurSelectedProjectIdNotifier.isEverythingId(initialProjectId)
          ? initialProjectId
          : await ref
              .read(curSelectedProjectIdNotifierProvider.notifier)
              .getSelectedProjectOrDefault();

      final context =
          ref.read(navigationServiceProvider).navigatorKey.currentContext!;

      final newTask = TaskModel(
        name: isPhase
            ? AppLocalizations.of(context)?.newPhaseDefaultName ?? 'New Phase'
            : AppLocalizations.of(context)?.newTaskDefaultName ?? 'New Task',
        description: '',
        status: initialStatus ?? StatusEnum.open,
        authorUserId: curUser.id,
        parentProjectId: parentProjectId,
        parentTaskId: initialParentTaskId,
        type: isPhase ? TaskType.phase : TaskType.task,
        startDateTime:
            initialStatus == StatusEnum.inProgress ? DateTime.now() : null,
        dueDate: initialStatus == StatusEnum.finished ? DateTime.now() : null,
      );

      await ref.read(tasksRepositoryProvider).upsertItem(newTask);

      if (updateState) state = newTask.id;

      return newTask.id;
    } catch (e, __) {
      throw Exception('Failed to create new task: $e');
    }
  }
}
