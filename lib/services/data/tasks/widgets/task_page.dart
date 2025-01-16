import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_editing_task_id_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_selected_task_id_providers.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_stream_provider.dart';
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

    final curTaskId = isEnabled
        ? ref.watch(curEditingTaskIdNotifierProvider)!
        : ref.watch(curSelectedTaskIdStateProvider)!;

    final curTask = ref.watch(taskStreamProvider(curTaskId));

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
                    child: TaskNameField(
                        taskId: curTaskId, isEditable: isEnabled)),
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
                  TaskDueDateSelectionField(
                      taskId: curTaskId, enabled: isEnabled),
                  const Divider(),
                  ReminderMinuteOffsetFromDueDateSelectionField(
                      taskId: curTaskId, enabled: isEnabled),
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
                        ref.read(curEditingTaskIdNotifierProvider)!;
                    ref
                        .read(curEditingTaskIdNotifierProvider.notifier)
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

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// TODO p2: init state within the page itself ... we should only rely on arguments to init the page (to support deep linking)
/// `initialProject` and `initialStatus` fields are only used for create mode.
/// They are used to set the parent project and status of the new task
///
/// **If you use them with edit mode, they will be ignored**
Future<void> openTaskPage(
  BuildContext context,
  WidgetRef ref, {
  required EditablePageMode mode,
  TaskModel? initialTask,
  ProjectModel? initialProject,
  StatusEnum? initialStatus,
}) async {
  // Remove previous TaskPage to avoid duplicate task pages
  ref
      .read(navigationServiceProvider)
      .popUntil((route) => route.settings.name != AppRoutes.taskPage.name);

  switch (mode) {
    // CREATE - wipe existing task state
    case EditablePageMode.create:
      await ref.read(curEditingTaskIdNotifierProvider.notifier).createNewTask();
      break;
    // EDIT/READ - optionally load provided initial task id
    case EditablePageMode.edit:
      // initialTask can be null if we are opening an existing task page for edit
      if (initialTask != null) {
        ref
            .read(curEditingTaskIdNotifierProvider.notifier)
            .setTaskId(initialTask.id);
      }
      break;
    case EditablePageMode.readOnly:
      if (initialTask != null) {
        ref.read(curSelectedTaskIdStateProvider.notifier).state =
            initialTask.id;
      }
  }

  final curTaskId = mode == EditablePageMode.readOnly
      ? ref.watch(curSelectedTaskIdStateProvider)!
      : ref.watch(curEditingTaskIdNotifierProvider)!;

  if (mode == EditablePageMode.create) {
    if (initialProject != null) {
      ref
          .read(tasksRepositoryProvider)
          .updateTaskParentProjectId(curTaskId, initialProject.id);
    }
    if (initialStatus != null) {
      ref
          .read(tasksRepositoryProvider)
          .updateTaskStatus(curTaskId, initialStatus);
    }
  }

  final actions = switch (mode) {
    EditablePageMode.edit => [DeleteTaskButton(curTaskId)],
    EditablePageMode.readOnly => [EditTaskButton(curTaskId)],
    _ => null,
  };

  final title = switch (mode) {
    EditablePageMode.edit => AppLocalizations.of(context)!.updateTask,
    EditablePageMode.create => AppLocalizations.of(context)!.createTask,
    // if mode is readOnly, we assume initialTask is provided
    // or at least the task state is loaded
    EditablePageMode.readOnly => initialTask?.name ??
        await ref
            .read(tasksRepositoryProvider)
            .getById(curTaskId)
            .then((task) => task?.name),
  };

  await ref.read(navigationServiceProvider).navigateTo(AppRoutes.taskPage.name,
      arguments: {'mode': mode, 'actions': actions, 'title': title});
}
