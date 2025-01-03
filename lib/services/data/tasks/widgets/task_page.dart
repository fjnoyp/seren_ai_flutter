import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/common/is_show_save_dialog_on_pop_provider.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_user_viewable_projects_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_task_service_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_task_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
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
  //final JoinedTaskModel? initialJoinedTask;

  const TaskPage({
    super.key,
    required this.mode,
    //this.initialJoinedTask,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final isEnabled = mode != EditablePageMode.readOnly;

    final curTaskState = ref.watch(curTaskStateProvider);

    final curTask = curTaskState.value;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TaskProjectSelectionField(isEditable: isEnabled),

            Row(
              children: [
                // Title Input
                Expanded(child: TaskNameField(isEditable: isEnabled)),
                if (mode == EditablePageMode.readOnly)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TaskPriorityView(
                          priority:
                              curTask?.task.priority ?? PriorityEnum.normal),
                      const SizedBox(height: 4),
                      TaskStatusView(
                          status: curTask?.task.status ?? StatusEnum.open),
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
                    isEditable: isEnabled,
                    context: context,
                  ),
                  const Divider(),
                  if (isEnabled) ...[
                    TaskPrioritySelectionField(enabled: isEnabled),
                    const Divider(),
                    TaskStatusSelectionField(enabled: isEnabled),
                    const Divider(),
                  ],
                  TaskDueDateSelectionField(enabled: isEnabled),
                  const Divider(),
                  ReminderMinuteOffsetFromDueDateSelectionField(
                      enabled: isEnabled),
                  const Divider(),
                  TaskAssigneesSelectionField(enabled: isEnabled),
                ],
              ),
            ),

            if (mode == EditablePageMode.readOnly)
              TaskCommentSection(curTask?.task.id ?? ''),
            const SizedBox(height: 24),

            if (mode != EditablePageMode.readOnly)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final curAuthUser = ref.read(curUserProvider).value;

                    if (curAuthUser == null) {
                      log.severe(
                          AppLocalizations.of(context)!.userNotAuthenticated);
                      return;
                    }

                    await _validateTaskAndMaybeSave(ref, context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                  ),
                  child: Text(mode == EditablePageMode.edit
                      ? AppLocalizations.of(context)!.updateTask
                      : AppLocalizations.of(context)!.createTask),
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _validateTaskAndMaybeSave(
      WidgetRef ref, BuildContext context) async {
    final curTaskState = ref.read(curTaskStateProvider);

    final curJoinedTask = curTaskState.value;

    final isValidTask = curJoinedTask?.isValidTask ?? false;

    if (isValidTask) {
      await ref.read(curTaskServiceProvider).saveTask();

      if (context.mounted) {
        ref.read(isShowSaveDialogOnPopProvider.notifier).reset();
        ref.read(navigationServiceProvider).pop();
      }
    } else {
      // takes action to solve each validation error
      if (curJoinedTask?.task.parentProjectId.isEmpty ?? false) {
        _takeActionOnEmptyProjectValue(context)
            .then((_) => _validateTaskAndMaybeSave(ref, context));
      } else if (curJoinedTask?.task.name.isEmpty ?? false) {
        _takeActionOnEmptyNameValue(context)
            .then((_) => _validateTaskAndMaybeSave(ref, context));
      }
    }
  }

  Future<dynamic> _takeActionOnEmptyProjectValue(BuildContext context) {
    // TODO p4: refactor to avoid hard coded solution
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final selectableProjects = ref.read(curUserViewableProjectsProvider);
          return ListView.builder(
            itemCount: selectableProjects.valueOrNull?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              final project = selectableProjects.valueOrNull?[index];
              return ListTile(
                title: Text(project?.name ?? ''),
                onTap: () {
                  ref.read(curTaskServiceProvider).updateParentProject(project);
                  ref.read(navigationServiceProvider).pop(project);
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _takeActionOnEmptyNameValue(BuildContext context) async {}
}

// TODO p3: figure out how to remove code duplication due to WidgetRef vs Ref
Future<void> openBlankTaskPage(Ref ref) async {
  final navigationService = ref.read(navigationServiceProvider);

  navigationService
      .popUntil((route) => route.settings.name != AppRoutes.taskPage.name);

  ref.read(curTaskServiceProvider).createTask();

  ref.read(isShowSaveDialogOnPopProvider.notifier).setCanSave(true);

  await navigationService.navigateTo(AppRoutes.taskPage.name,
      arguments: {'mode': EditablePageMode.create, 'title': 'Create Task'});
}

// TODO p3: init state within the page itself ... we should only rely on arguments to init the page (to support deep linking)
/// `initialProject` and `initialStatus` fields are only used for create mode. 
/// They are used to set the parent project and status of the new task
///
/// **If you use them with edit mode, they will be ignored**
Future<void> openTaskPage(
  BuildContext context,
  WidgetRef ref, {
  required EditablePageMode mode,
  JoinedTaskModel? initialJoinedTask,
  ProjectModel? initialProject,
  StatusEnum? initialStatus,
}) async {
  // Remove previous TaskPage to avoid duplicate task pages
  ref
      .read(navigationServiceProvider)
      .popUntil((route) => route.settings.name != AppRoutes.taskPage.name);

  // CREATE - wipe existing task state
  if (mode == EditablePageMode.create) {
    ref.read(curTaskServiceProvider).createTask(
        project: initialProject, status: initialStatus);
  }
  // EDIT/READ - optionally load provided initial task
  else if (mode == EditablePageMode.edit || mode == EditablePageMode.readOnly) {
    // initialJoinedTask can be null if we are opening an existing task page for edit
    if (initialJoinedTask != null) {
      ref.read(curTaskServiceProvider).loadTask(initialJoinedTask);

      // TODO p3: modify to have comments listened to in realtime
      ref.read(curTaskServiceProvider).updateComments();
    }
  }

  final actions = switch (mode) {
    EditablePageMode.edit => [const DeleteTaskButton()],
    EditablePageMode.readOnly => [const EditTaskButton()],
    _ => null,
  };

  final title = switch (mode) {
    EditablePageMode.edit => AppLocalizations.of(context)!.updateTask,
    EditablePageMode.create => AppLocalizations.of(context)!.createTask,
    // if mode is readOnly, we assume initialJoinedTask is provided
    // or at least the task state is loaded
    EditablePageMode.readOnly => initialJoinedTask?.task.name ??
        ref.read(curTaskStateProvider).value!.task.name,
  };

  if (mode == EditablePageMode.edit || mode == EditablePageMode.create) {
    ref.read(isShowSaveDialogOnPopProvider.notifier).setCanSave(true);
  }

  await ref.read(navigationServiceProvider).navigateTo(AppRoutes.taskPage.name,
      arguments: {'mode': mode, 'actions': actions, 'title': title});
}
