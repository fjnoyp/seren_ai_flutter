import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editablePageModeEnum.dart';
import 'package:seren_ai_flutter/services/data/tasks/ui_state/cur_task_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/joined_task_save_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/form/task_selection_fields.dart';

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

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TaskTeamSelectionField(enabled: isEnabled),
            TaskProjectSelectionField(enabled: isEnabled),

            // Title Input
            TaskNameField(enabled: isEnabled),
            SizedBox(height: 8),
            Divider(),

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

            //Text('Comments', style: theme.textTheme.titleMedium),
            //const SizedBox(height: 8),
            // TODO p2: Implement comments section
            const SizedBox(height: 24),

            if (mode != EditablePageMode.readOnly)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final curAuthUser = ref.watch(curAuthUserProvider);

                    if (curAuthUser == null) {
                      log.severe('Error: Current user is not authenticated.');
                      return;
                    }

                    // TODO p2: add validator ui - since we don't use formfield (since we use provider to manage task form state) we must manually implement validation
                    final isValidTask =
                        ref.read(curTaskProvider.notifier).isValidTask();

                    if (isValidTask) {
                      final curJoinedTask = ref.read(curTaskProvider);
                      await ref
                          .read(joinedTaskSaveProvider)
                          .saveTask(curJoinedTask);

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                  ),
                  child: Text(mode == EditablePageMode.edit
                      ? 'Update Task'
                      : 'Create Task'),
                ),
              ),

            if (mode == EditablePageMode.readOnly)
              ElevatedButton(
                  onPressed: () {
                    // remove self from stack
                    Navigator.pop(context);
                    openTaskPage(context, ref, mode: EditablePageMode.edit);
                  },
                  child: Text('Edit'))
          ],
        ),
      ),
    );
  }
}

// TODO p3: figure out how to remove code duplication due to WidgetRef vs Ref 
Future<void> openBlankTaskPage(BuildContext context, Ref ref) async {
  Navigator.popUntil(context, (route) => route.settings.name != taskPageRoute);

  final authUser = ref.watch(curAuthUserProvider);
  if (authUser == null){
    throw Exception('Error: Current user is not authenticated.');
  }
  ref.read(curTaskProvider.notifier).setToNewTask(authUser);

  await Navigator.pushNamed(context, taskPageRoute,
      arguments: {'mode': EditablePageMode.create});
}

Future<void> openTaskPage(BuildContext context, WidgetRef ref,
    {required EditablePageMode mode, JoinedTaskModel? initialJoinedTask}) async {
  // Remove previous TaskPage to avoid duplicate task pages
  Navigator.popUntil(context, (route) => route.settings.name != taskPageRoute);

  // CREATE - wipe existing task state
  if (mode == EditablePageMode.create) {
    final authUser = ref.watch(curAuthUserProvider);
    if (authUser == null) {
      throw Exception('Error: Current user is not authenticated.');
    }
    ref.read(curTaskProvider.notifier).setToNewTask(authUser);
  }
  // EDIT/READ - optionally load provided initial task
  else if (mode == EditablePageMode.edit || mode == EditablePageMode.readOnly) {
    if (initialJoinedTask != null) {
      ref.read(curTaskProvider.notifier).setNewTask(initialJoinedTask);
    }
  }

  await Navigator.pushNamed(context, taskPageRoute,
      arguments: {'mode': mode});
}
