import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/current_route_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/common/base_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/project_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_selected_task_id_notifier_provider.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/action_buttons/delete_task_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final taskNavigationServiceProvider = Provider<TaskNavigationService>((ref) {
  return TaskNavigationService(ref);
});

class TaskNavigationService extends BaseNavigationService {
  TaskNavigationService(super.ref);

  @override
  NotifierProvider get idNotifierProvider => curSelectedTaskIdNotifierProvider;

  @override
  void setIdFunction(String id) =>
      ref.read(curSelectedTaskIdNotifierProvider.notifier).setTaskId(id);

  Future<void> openTask({required String initialTaskId}) async {
    final taskIdNotifier = ref.read(curSelectedTaskIdNotifierProvider.notifier);

    taskIdNotifier.setTaskId(initialTaskId);

    final curTaskId = ref.read(curSelectedTaskIdNotifierProvider);
    if (curTaskId == null) return;

    await _navigateToTaskPage(
      mode: EditablePageMode.edit,
      taskId: curTaskId,
    );
  }

  Future<void> openNewTask({
    String? initialProjectId,
    StatusEnum? initialStatus,
    String? initialParentTaskId,
    bool isPhase = false,
  }) async {
    assert(
      initialParentTaskId == null || isPhase == false,
      'initialParentTaskId can only be set if isPhase is false',
    );

    final taskIdNotifier = ref.read(curSelectedTaskIdNotifierProvider.notifier);

    final curTaskId = await taskIdNotifier.createNewTask(
      isPhase: isPhase,
      initialProjectId: initialProjectId,
      initialParentTaskId: initialParentTaskId,
      initialStatus: initialStatus,
    );

    await _navigateToTaskPage(mode: EditablePageMode.create, taskId: curTaskId);
  }

  Future<void> _navigateToTaskPage({
    required EditablePageMode mode,
    required String taskId,
  }) async {
    final context = ref.read(navigationServiceProvider).context;

    final actions = [DeleteTaskButton(taskId)];

    final title = mode == EditablePageMode.create
        ? AppLocalizations.of(context)!.createTask
        : AppLocalizations.of(context)!.updateTask;

    final curRoute = ref.read(currentRouteProvider);
    // If we're not already on a project page, we open project page first
    if (!curRoute.startsWith(AppRoutes.projectOverview.name)) {
      final curProjectId = ref.read(curSelectedProjectIdNotifierProvider);

      await ref.read(projectNavigationServiceProvider).openProjectPage(
          mode: EditablePageMode.readOnly, projectId: curProjectId);
    }

    await ref.read(navigationServiceProvider).navigateTo(
      '${AppRoutes.taskPage.name}/$taskId',
      arguments: {
        'actions': actions,
        'title': title,
        'mode': mode,
      },
    );
  }
}
