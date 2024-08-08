import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/cur_task_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_user_assignments_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_user_assignments_db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/tasks_db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/joined_task_save_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_form/task_assignees_selection_field.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_form/task_description_selection_field.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_form/task_due_date_selection_field.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_form/task_name_field.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_form/task_selection_fields.dart';

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

enum TaskPageMode { readOnly, edit, create }

final log = Logger('TaskPage');

class TaskPage extends HookConsumerWidget {
  final TaskPageMode mode;
  final JoinedTaskModel? initialJoinedTask;

  const TaskPage({
    super.key,
    required this.mode,
    this.initialJoinedTask,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (initialJoinedTask != null) {
          ref.read(curTaskProvider.notifier).setNewTask(initialJoinedTask!);
        }

        else if(mode == TaskPageMode.create) {
          final authUser = ref.watch(curAuthUserProvider);
          if(authUser == null) throw Exception('Error: Current user is not authenticated.');
          ref.read(curTaskProvider.notifier).setToNewTask(authUser);
        }
      });
      return null;
    }, [initialJoinedTask, mode]);

    
    final theme = Theme.of(context);

    final isEnabled = mode != TaskPageMode.readOnly;

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

            if (mode != TaskPageMode.readOnly)
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
                      final curJoinedTask =  ref.read(curTaskProvider);
                      await ref.read(joinedTaskSaveProvider).saveTask(curJoinedTask);
                      
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                  ),
                  child: Text(mode == TaskPageMode.edit
                      ? 'Update Task'
                      : 'Create Task'),
                ),
              ),

            if (mode == TaskPageMode.readOnly)
              ElevatedButton(
                  onPressed: () {
                    // remove self from stack
                    Navigator.pop(context);
                    openTaskPage(context,
                        mode: TaskPageMode.edit, joinedTask: initialJoinedTask);
                  },
                  child: Text('Edit'))
          ],
        ),
      ),
    );
  }
}
