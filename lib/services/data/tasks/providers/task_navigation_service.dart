import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/data/common/base_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_selected_task_id_notifier_provider.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/action_buttons/delete_task_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/web/web_task_page.dart';

final taskNavigationServiceProvider = Provider<TaskNavigationService>((ref) {
  return TaskNavigationService(ref);
});

class TaskNavigationService extends BaseNavigationService {
  TaskNavigationService(super.ref);

  @override
  NotifierProvider get idNotifierProvider => curSelectedTaskIdNotifierProvider;

  @override
  Future<void> setIdFunction(String id) async {
    await _ensureTaskOrgIsSelected(id);
    ref.read(curSelectedTaskIdNotifierProvider.notifier).setTaskId(id);
  }

  Future<void> openTask(
      {required String initialTaskId, bool asPopup = true}) async {
    final taskIdNotifier = ref.read(curSelectedTaskIdNotifierProvider.notifier);

    taskIdNotifier.setTaskId(initialTaskId);

    final curTaskId = ref.read(curSelectedTaskIdNotifierProvider);
    if (curTaskId == null) return;

    await _ensureTaskOrgIsSelected(curTaskId);

    await _openTaskPage(
      mode: EditablePageMode.edit,
      taskId: curTaskId,
      asPopup: asPopup,
    );
  }

  Future<void> openNewTask({
    String? initialProjectId,
    StatusEnum? initialStatus,
    String? initialParentTaskId,
    bool isPhase = false,
    bool asPopup = true,
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
      updateState: true,
    );

    await _openTaskPage(
      mode: EditablePageMode.create,
      taskId: curTaskId,
      asPopup: asPopup,
    );
  }

  Future<void> _ensureTaskOrgIsSelected(String taskId) async {
    final task = await ref.read(taskByIdStreamProvider(taskId).future);
    if (task == null) {
      throw Exception('Task not found');
    }

    // If the task org is not the current org, we need to select the task org
    final curSelectedOrgId = ref.read(curSelectedOrgIdNotifierProvider);

    // Get the task's parent org ID from the repository
    final taskParentOrgId =
        await ref.read(tasksRepositoryProvider).getTaskParentOrgId(taskId);

    if (taskParentOrgId != null && taskParentOrgId != curSelectedOrgId) {
      await ref
          .read(curSelectedOrgIdNotifierProvider.notifier)
          .setDesiredOrgId(taskParentOrgId);
    }
  }

  Future<void> _openTaskPage({
    required EditablePageMode mode,
    required bool asPopup,
    required String taskId,
  }) async {
    if (asPopup && isWebVersion) {
      // only show popup on web
      await ref.read(navigationServiceProvider).showPopupDialog(
            const TaskPopupDialog(),
            barrierDismissible: false,
            applyBarrierColor: false,
          );
    } else {
      await _navigateToTaskPage(
        mode: mode,
        taskId: taskId,
      );
    }
  }

  Future<void> _navigateToTaskPage({
    required EditablePageMode mode,
    required String taskId,
  }) async {
    final context = ref.read(navigationServiceProvider).context;

    final actions = [DeleteTaskButton(taskId, shouldPopOnDelete: true)];

    final title = mode == EditablePageMode.create
        ? AppLocalizations.of(context)!.createTask
        : AppLocalizations.of(context)!.updateTask;

    // final curRoute = ref.read(currentRouteProvider);
    // // If we're not already on a project page, we open project page first
    // if (!curRoute.startsWith(AppRoutes.projectOverview.name)) {
    //   final task = await ref.read(taskByIdStreamProvider(taskId).future);
    //   final projectId = task?.parentProjectId;

    //   final curProjectId = ref.read(curSelectedProjectIdNotifierProvider);

    //   await ref.read(projectNavigationServiceProvider).openProjectPage(
    //       mode: EditablePageMode.readOnly,
    //       projectId: projectId ?? curProjectId);
    // }

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
