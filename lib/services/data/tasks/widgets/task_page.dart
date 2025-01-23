import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_page.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_selected_task_id_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/action_buttons/delete_task_button.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/action_buttons/edit_task_button.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/form/task_selection_fields.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_comments/task_comment_section.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_priority_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_status_view.dart';

/* === Thoughts on ai generation of create task === 
1) Tasks must be assigned to specific users / projects 
2) Desire to avoid duplication of user / project subset creation logic? 
3) Options:
    A) ai (backend) recalculates subset itself 
    B) client sends the possible selections to backend either fully or as ids 
4) For now: 
    Client will send everything, to avoid need to duplicate logic 

=== Additional Considerations === 
In the future ai (backend) should be independent - this will require refactoring 
SQL logic to a separate shared file to ensure frontend / backend logic remains in sync

We cannot merge sql request logic as client must WATCH data while edge functions 
inherently only READ data. 
We could keep ai as data intake only, and just have 3rd intermediary process insert data
in case where client is not sending the data context  */

final log = Logger('TaskPage');

/// For creating / editing a task
class TaskPage extends HookConsumerWidget {
  final EditablePageMode mode;

  const TaskPage({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final isEnabled = mode != EditablePageMode.readOnly;

    final curTaskId = ref.watch(curSelectedTaskIdNotifierProvider)!;

    final curTask = ref.watch(taskByIdStreamProvider(curTaskId));

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TaskProjectSelectionField(taskId: curTaskId, isEditable: isEnabled),

            Row(
              children: [
                // Title Input
                Expanded(
                    flex: mode == EditablePageMode.readOnly ? 0 : 1,
                    child: TaskNameField(
                        taskId: curTaskId, isEditable: isEnabled)),
                if (isWebVersion && mode == EditablePageMode.readOnly)
                  Expanded(
                      child: Row(
                    children: [
                      EditTaskButton(curTaskId),
                      const SizedBox.shrink(),
                    ],
                  )),
                if (mode == EditablePageMode.readOnly)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TaskPriorityView(
                          priority:
                              curTask.value?.priority ?? PriorityEnum.normal),
                      const SizedBox(height: 4),
                      TaskStatusView(
                          status: curTask.value?.status ?? StatusEnum.open),
                    ],
                  )
              ],
            ),
            const SizedBox(height: 8),

            // ======================
            // ====== SUBITEMS ======
            // ======================
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Column(
                children: [
                  TaskDescriptionSelectionField(
                    taskId: curTaskId,
                    isEditable: isEnabled,
                    context: context,
                  ),
                  const Divider(),
                  if (isEnabled) ...[
                    TaskPrioritySelectionField(
                        taskId: curTaskId, enabled: isEnabled),
                    const Divider(),
                    TaskStatusSelectionField(
                        taskId: curTaskId, enabled: isEnabled),
                    const Divider(),
                  ],
                  TaskStartDateSelectionField(
                      taskId: curTaskId, enabled: isEnabled),
                  TaskDueDateSelectionField(
                      taskId: curTaskId, enabled: isEnabled),
                  const Divider(),
                  ReminderMinuteOffsetFromDueDateSelectionField(
                    context: context,
                    taskId: curTaskId,
                    enabled: isEnabled && curTask.value?.dueDate != null,
                  ),
                  const Divider(),
                  TaskParentTaskSelectionField(
                    context: context,
                    taskId: curTaskId,
                    projectId: curTask.value?.parentProjectId ?? '',
                    isEditable: isEnabled,
                  ),
                  const Divider(),
                  TaskBlockedByTaskSelectionField(
                    context: context,
                    taskId: curTaskId,
                    projectId: curTask.value?.parentProjectId ?? '',
                    isEditable: isEnabled,
                  ),
                  const Divider(),
                  TaskEstimatedDurationSelectionField(
                    context: context,
                    taskId: curTaskId,
                    enabled: isEnabled,
                  ),
                  const Divider(),
                  TaskAssigneesSelectionField(
                      taskId: curTaskId, enabled: isEnabled),
                ],
              ),
            ),

            if (mode == EditablePageMode.readOnly)
              TaskCommentSection(curTask.value?.id ?? ''),
            const SizedBox(height: 24),

            if (mode == EditablePageMode.create)
              PopScope(
                onPopInvokedWithResult: (_, result) async {
                  if (result != true) {
                    final curTaskId =
                        ref.read(curSelectedTaskIdNotifierProvider)!;
                    ref
                        .read(curSelectedTaskIdNotifierProvider.notifier)
                        .clearTaskId();
                    ref.read(tasksRepositoryProvider).deleteItem(curTaskId);
                  }
                },
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        ref.read(navigationServiceProvider).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
                    ),
                    child: Text(AppLocalizations.of(context)!.createTask),
                  ),
                ),
              ),

            if (isWebVersion && mode == EditablePageMode.edit)
              DeleteTaskButton(curTaskId, showLabelText: true),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// // TODO p2: init state within the page itself ... we should only rely on arguments to init the page (to support deep linking)
// Future<void> openTaskPage(
//   BuildContext context,
//   WidgetRef ref, {
//   required EditablePageMode mode,
//   String? initialTaskId,
// }) async {
//   if (mode == EditablePageMode.create) {
//     return await openNewTaskPage(context, ref);
//   }

//   // Remove previous TaskPage to avoid duplicate task pages
//   ref
//       .read(navigationServiceProvider)
//       .popUntil((route) => route.settings.name != AppRoutes.taskPage.name);

//   // load provided initial task id
//   // initialTask can be null if we are opening an existing task page for edit
//   if (initialTaskId != null) {
//     ref
//         .read(curSelectedTaskIdNotifierProvider.notifier)
//         .setTaskId(initialTaskId);
//   }

//   final curTaskId = ref.watch(curSelectedTaskIdNotifierProvider)!;

//   final actions = switch (mode) {
//     EditablePageMode.edit => [DeleteTaskButton(curTaskId)],
//     EditablePageMode.readOnly => [EditTaskButton(curTaskId)],
//     _ => null,
//   };

//   final title = switch (mode) {
//     EditablePageMode.edit => AppLocalizations.of(context)!.updateTask,
//     // if mode is readOnly, we assume initialTask is provided
//     // or at least the task state is loaded
//     EditablePageMode.readOnly => initialTaskId != null
//         ? await ref
//                 .read(tasksRepositoryProvider)
//                 .getById(curTaskId)
//                 .then((task) => task?.name) ??
//             ''
//         : '',
//     // we don't handle create mode here because it is handled in openNewTaskPage
//     // which is called in the beginning of this method
//     _ => '',
//   };

//   await ref.read(navigationServiceProvider).navigateTo(AppRoutes.taskPage.name,
//       arguments: {'mode': mode, 'actions': actions, 'title': title});

//   // TODO p3: use this to have the same redirect behaviour as openNewTaskPage
//   // for now, it doesn't work because we need to remove "ref" from openProjectPage first
//   // await ref.read(navigationServiceProvider).navigateTo(AppRoutes.taskPage.name,
//   //     arguments: {
//   //       'mode': mode,
//   //       'actions': actions,
//   //       'title': title
//   //     }).then((_) async {
//   //   // Remove previous TaskPage to avoid duplicate task pages
//   //   ref
//   //       .read(navigationServiceProvider)
//   //       .popUntil((route) => route.settings.name != AppRoutes.taskPage.name);
//   //   if (isWebVersion) {
//   //     await _redirectToProjectPage(context, ref);
//   //   }
//   // });
// }

// Future<void> openNewTaskPage(
//   BuildContext context,
//   WidgetRef ref, {
//   ProjectModel? initialProject,
//   StatusEnum? initialStatus,
// }) async {
//   await ref.read(curSelectedTaskIdNotifierProvider.notifier).createNewTask();

//   final curTaskId = ref.watch(curSelectedTaskIdNotifierProvider)!;

//   if (initialProject != null) {
//     ref
//         .read(tasksRepositoryProvider)
//         .updateTaskParentProjectId(curTaskId, initialProject.id);
//   }

//   if (initialStatus != null) {
//     ref
//         .read(tasksRepositoryProvider)
//         .updateTaskStatus(curTaskId, initialStatus);
//   }

//   await ref.read(navigationServiceProvider).navigateTo(
//     AppRoutes.taskPage.name,
//     arguments: {
//       'mode': EditablePageMode.create,
//       'actions': [DeleteTaskButton(curTaskId)],
//       'title': AppLocalizations.of(context)!.createTask,
//     },
//   ).then((_) async {
//     // Remove previous TaskPage to avoid duplicate task pages (if any)
//     ref
//         .read(navigationServiceProvider)
//         .popUntil((route) => route.settings.name != AppRoutes.taskPage.name);
//     if (isWebVersion) {
//       await _redirectToProjectPage(context, ref);
//     }
//   });
// }

// Future<void> _redirectToProjectPage(BuildContext context, WidgetRef ref) async {
//   final curTaskId = ref.watch(curSelectedTaskIdNotifierProvider);
//   if (curTaskId != null) {
//     final curProjectId = await ref
//         .read(tasksRepositoryProvider)
//         .getById(curTaskId)
//         .then((task) => task?.parentProjectId);
//     await openProjectPage(ref, context, projectId: curProjectId);
//   }
// }

Future<void> openTaskPage(
  BuildContext context,
  WidgetRef ref, {
  required EditablePageMode mode,
  String? initialTaskId,
}) async {
  ref
      .read(taskNavigationServiceProvider)
      .openTask(context: context, mode: mode, initialTaskId: initialTaskId);
}

Future<void> openNewTaskPage(
  BuildContext context,
  WidgetRef ref, {
  ProjectModel? initialProject,
  StatusEnum? initialStatus,
}) async {
  ref
      .read(taskNavigationServiceProvider)
      .openTask(context: context, mode: EditablePageMode.create);
}
