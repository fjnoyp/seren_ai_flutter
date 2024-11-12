import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editablePageModeEnum.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_user_viewable_projects_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_task_service_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_task_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/action_buttons/delete_task_button.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/action_buttons/edit_task_button.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/form/task_selection_fields.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_comments/task_comment_section.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
            TaskProjectSelectionField(enabled: isEnabled),

            // Title Input
            TaskNameField(enabled: isEnabled),
            const SizedBox(height: 8),
            const Divider(),

            // ======================
            // ====== SUBITEMS ======
            // ======================
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Column(
                children: [
                  TaskPrioritySelectionField(enabled: isEnabled),
                  const Divider(),
                  TaskStatusSelectionField(enabled: isEnabled),
                  const Divider(),
                  TaskDueDateSelectionField(enabled: isEnabled),
                  const Divider(),
                  TaskAssigneesSelectionField(enabled: isEnabled),
                  const Divider(),
                  TaskDescriptionSelectionField(enabled: isEnabled),
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
        Navigator.pop(context);
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
    // TODO: refactor to avoid hard coded solution
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final selectableProjects =
              ref.read(curUserViewableProjectsProvider);
          return ListView.builder(
            itemCount: selectableProjects.valueOrNull?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              final project = selectableProjects.valueOrNull?[index];
              return ListTile(
                title: Text(project?.name ?? ''),
                onTap: () {
                  ref.read(curTaskServiceProvider).updateParentProject(project);
                  Navigator.pop(context, project);
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
Future<void> openBlankTaskPage(BuildContext context, Ref ref) async {
  Navigator.popUntil(context, (route) => route.settings.name != AppRoutes.taskPage.name);

  ref.read(curTaskServiceProvider).createTask();

  await Navigator.pushNamed(context, AppRoutes.taskPage.name,
      arguments: {'mode': EditablePageMode.create});
}

// TODO p2: init state within the page itself ... we should only rely on arguments to init the page (to support deep linking)
Future<void> openTaskPage(BuildContext context, WidgetRef ref,
    {required EditablePageMode mode,
    JoinedTaskModel? initialJoinedTask}) async {
  // Remove previous TaskPage to avoid duplicate task pages
  Navigator.popUntil(context, (route) => route.settings.name != AppRoutes.taskPage.name);

  // CREATE - wipe existing task state
  if (mode == EditablePageMode.create) {
    ref.read(curTaskServiceProvider).createTask();
  }
  // EDIT/READ - optionally load provided initial task
  else if (mode == EditablePageMode.edit || mode == EditablePageMode.readOnly) {
    // initialJoinedTask can be null if we are opening an existing task page for edit
    if (initialJoinedTask != null) {
      ref.read(curTaskServiceProvider).loadTask(initialJoinedTask);

      // TODO: modify to have comments listened to in realtime
      ref.read(curTaskServiceProvider).updateComments();
    }
  }

  final actions = switch (mode) {
    EditablePageMode.edit => [const DeleteTaskButton()],
    EditablePageMode.readOnly => [const EditTaskButton()],
    _ => null,
  };

  await Navigator.pushNamed(context, AppRoutes.taskPage.name,
      arguments: {'mode': mode, 'actions': actions});
}
