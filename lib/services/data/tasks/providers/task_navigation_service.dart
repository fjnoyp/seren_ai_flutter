import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/project_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_selected_task_id_notifier_provider.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/action_buttons/delete_task_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final taskNavigationServiceProvider = Provider<TaskNavigationService>((ref) {
  return TaskNavigationService(ref);
});

class TaskNavigationService {
  final Ref ref;

  TaskNavigationService(this.ref);

  Future<void> openTask({required String initialTaskId}) async {
    final taskIdNotifier = ref.read(curSelectedTaskIdNotifierProvider.notifier);

    taskIdNotifier.setTaskId(initialTaskId);

    final curTaskId = ref.read(curSelectedTaskIdNotifierProvider);
    if (curTaskId == null) return;

    await _navigateToTaskPage(
      mode: EditablePageMode.edit,
      taskId: curTaskId,
    ).then(
      (_) {
        if (isWebVersion) {
          _handleProjectRedirect();
        }
      },
    );
  }

  Future<void> openNewTask({
    String? initialProjectId,
    StatusEnum? initialStatus,
  }) async {
    final taskIdNotifier = ref.read(curSelectedTaskIdNotifierProvider.notifier);

    await taskIdNotifier.createNewTask();

    final curTaskId = ref.read(curSelectedTaskIdNotifierProvider);
    if (curTaskId == null) return;

    if (initialProjectId != null) {
      await ref
          .read(tasksRepositoryProvider)
          .updateTaskParentProjectId(curTaskId, initialProjectId);
    }

    if (initialStatus != null) {
      await ref
          .read(tasksRepositoryProvider)
          .updateTaskStatus(curTaskId, initialStatus);
    }

    await _navigateToTaskPage(mode: EditablePageMode.create, taskId: curTaskId)
        .then((_) {
      if (isWebVersion) {
        _handleProjectRedirect();
      }
    });
  }

  Future<void> _navigateToTaskPage({
    required EditablePageMode mode,
    required String taskId,
  }) async {
    final context = ref.read(navigationServiceProvider).context;

    // TODO: add save state indicator (for mobile)
    final actions = [DeleteTaskButton(taskId)];

    await ref.read(navigationServiceProvider).navigateTo(
      AppRoutes.taskPage.name,
      arguments: {
        'actions': actions,
        'title': AppLocalizations.of(context)!.task,
        'mode': mode,
      },
    );
  }

  // Future<String> _getTaskTitle(String taskId) async {
  //   return await ref
  //       .read(tasksRepositoryProvider)
  //       .getById(taskId)
  //       .then((task) => task?.name ?? '');
  // }

  Future<void> _handleProjectRedirect() async {
    final curTaskId = ref.read(curSelectedTaskIdNotifierProvider);
    if (curTaskId == null) return;

    final curProjectId = await ref
        .read(tasksRepositoryProvider)
        .getById(curTaskId)
        .then((task) => task?.parentProjectId);

    if (curProjectId != null) {
      await ref.read(projectNavigationServiceProvider).openProjectPage(
          mode: EditablePageMode.readOnly, projectId: curProjectId);
    }
  }
}
