import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';

import 'package:seren_ai_flutter/services/data/tasks/providers/cur_selected_task_id_notifier_provider.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/action_buttons/delete_task_button.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/action_buttons/edit_task_button.dart';

final taskNavigationServiceProvider = Provider<TaskNavigationService>((ref) {
  return TaskNavigationService(ref);
});

class TaskNavigationService {
  final Ref ref;

  TaskNavigationService(this.ref);

  Future<void> openTask({
    required EditablePageMode mode,
    String? initialTaskId,
    ProjectModel? initialProject,
    StatusEnum? initialStatus,
  }) async {
    final taskIdNotifier = ref.read(curSelectedTaskIdNotifierProvider.notifier);

    // Handle create mode
    if (mode == EditablePageMode.create) {
      await taskIdNotifier.createNewTask();

      final curTaskId = ref.read(curSelectedTaskIdNotifierProvider);
      if (curTaskId == null) return;

      if (initialProject != null) {
        await ref
            .read(tasksRepositoryProvider)
            .updateTaskParentProjectId(curTaskId, initialProject.id);
      }

      if (initialStatus != null) {
        await ref
            .read(tasksRepositoryProvider)
            .updateTaskStatus(curTaskId, initialStatus);
      }

      await _navigateToTaskPage(
        mode: EditablePageMode.create,
        taskId: curTaskId,
      );
      return;
    }

    // Handle existing task
    if (initialTaskId != null) {
      taskIdNotifier.setTaskId(initialTaskId);
    }

    final curTaskId = ref.read(curSelectedTaskIdNotifierProvider);
    if (curTaskId == null) return;

    await _navigateToTaskPage(
      mode: mode,
      taskId: curTaskId,
    );
  }

  Future<void> _navigateToTaskPage({
    required EditablePageMode mode,
    required String taskId,
  }) async {
    final context = ref.read(navigationServiceProvider).context;

    final actions = switch (mode) {
      EditablePageMode.edit => [DeleteTaskButton(taskId)],
      EditablePageMode.readOnly => [EditTaskButton(taskId)],
      EditablePageMode.create => [DeleteTaskButton(taskId)],
    };

    final title = switch (mode) {
      EditablePageMode.edit => AppLocalizations.of(context)!.updateTask,
      EditablePageMode.readOnly => await _getTaskTitle(taskId),
      EditablePageMode.create => AppLocalizations.of(context)!.createTask,
    };

    await ref.read(navigationServiceProvider).navigateToWithReplacement(
      AppRoutes.taskPage.name,
      arguments: {
        'mode': mode,
        'actions': actions,
        'title': title,
      },
    );
  }

  Future<String> _getTaskTitle(String taskId) async {
    return await ref
        .read(tasksRepositoryProvider)
        .getById(taskId)
        .then((task) => task?.name ?? '');
  }

  // Future<void> _handleProjectRedirect(Ref ref, BuildContext context) async {
  //   final curTaskId = ref.read(curSelectedTaskIdNotifierProvider);
  //   if (curTaskId == null) return;

  //   final curProjectId = await ref.read(tasksRepositoryProvider)
  //       .getById(curTaskId)
  //       .then((task) => task?.parentProjectId);

  //   if (curProjectId != null) {
  //     await openProjectPage(ref, context, projectId: curProjectId);
  //   }
  // }
}
