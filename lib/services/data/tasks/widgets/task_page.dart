import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/cur_task_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_user_assignments_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_user_assignments_db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/tasks_db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_form/task_assignees_selection_field.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_form/task_description_selection_field.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_form/task_due_date_selection_field.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_form/task_name_field.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_form/task_selection_fields.dart';
import 'package:seren_ai_flutter/services/data/teams/cur_team/cur_user_team_roles_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/cur_team/joined_cur_user_team_roles_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:uuid/uuid.dart';

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
  //final TaskPageMode mode;
  //final JoinedTaskModel? initialJoinedTask;

  const TaskPage({
    super.key,
    //required this.mode,
    //this.initialJoinedTask,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('TaskPage build');
    final theme = Theme.of(context);
    final formKey = GlobalKey<FormState>();

    final mode = TaskPageMode.edit;

    //final isEnabled = mode != TaskPageMode.readOnly;
    final isEnabled = true;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
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
                    onPressed: () {
                      final curAuthUser = ref.watch(curAuthUserProvider);

                      if (curAuthUser == null) {
                        log.severe('Error: Current user is not authenticated.');
                        return;
                      }

                      // TODO p1: use curTaskProvider to save

                      // TODO p2: add validator ui - since we don't use formfield (since we use provider to manage task form state) we must manually implement validation

                      ref.read(curTaskProvider.notifier).isValidTask();
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
                      //openTaskPage(context, mode: TaskPageMode.edit, joinedTask: initialJoinedTask);
                    },
                    child: Text('Edit'))
            ],
          ),
        ),
      ),
    );
  }
}
