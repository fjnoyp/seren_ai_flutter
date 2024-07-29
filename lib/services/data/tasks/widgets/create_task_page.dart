import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_editable_field.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_editable_meta_field.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';

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

final log = Logger('CreateTaskPage');

class CreateTaskPage extends HookConsumerWidget {
  const CreateTaskPage({super.key});

  void test() {}
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    //final _descriptionController = TextEditingController();

    final taskProject = useState<ProjectModel?>(null);
    final taskTeam = useState<TeamModel?>(null);

    final taskAssignedUsers = useState<List<String>>([]);
    final taskDueDate = useState<DateTime?>(null);
    final taskDescription = useState<String>('');

    final taskPriority = useState<PriorityEnum?>(null);
    final taskStatus = useState<StatusEnum?>(null);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project
              ProjectEditableField(
                selectedProject: taskProject.value,
                onProjectSelected: (project) {
                  taskProject.value = project;
                },
                hasError: taskProject.value == null,
              ),
              TeamEditableField(
                selectedTeam: taskTeam.value,
                onTeamSelected: (team) {
                  taskTeam.value = team;
                },
                hasError: taskTeam.value == null,
              ),

              // Title Input
              TextFormField(
                controller: _nameController,
                style: theme.textTheme.titleMedium,
                decoration: InputDecoration(
                  hintText: 'Task Name',
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8), 
              Divider(),

              // ======================
              // ====== SUBITEMS ======
              // ======================
              Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Column(children: [
                    // === PRIORITY SELECTION ===
                    TaskPriorityEditableField(
                      selectedPriority: taskPriority.value,
                      onPrioritySelected: (priority) {
                        taskPriority.value = priority;
                      },
                      hasError: taskPriority.value == null,
                    ),
                    const Divider(),

                    // === STATUS SELECTION ===
                    TaskStatusEditableField(
                      selectedStatus: taskStatus.value,
                      onStatusSelected: (status) {
                        taskStatus.value = status;
                      },
                      hasError: taskStatus.value == null,
                    ),
                    const Divider(),

                    // === DATE SELECTION ===
                    TaskDateEditableField(
                      selectedDate: taskDueDate.value,
                      onDateSelected: (date) {
                        taskDueDate.value = date;
                      },
                      hasError: taskDueDate.value == null,
                    ),
                    const Divider(),
                    // === ASSIGNEES SELECTION ===
                    TaskAssigneesEditableField(
                      selectedUsers: taskAssignedUsers.value,
                      onAssigneesSelected: (assignees) {
                        taskAssignedUsers.value = assignees;
                      },
                      hasError: taskAssignedUsers.value.isEmpty,
                    ),
                    const Divider(),
                    // === WRITE DESCRIPTION ===
                    TaskDescriptionEditableField(
                      description: taskDescription.value,
                      onDescriptionChanged: (description) {
                        taskDescription.value = description;
                      },
                      hasError: taskDescription.value.isEmpty,
                    ),
                  ])),

              Text('Comments', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              // TODO: Implement comments section
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,                
                child: ElevatedButton(
                  onPressed: () {

                    final curAuthUser = ref.watch(curAuthUserProvider);

                    if(curAuthUser == null){
                      log.severe('Error: Current user is not authenticated.');
                      return;
                    }

                    

                    if (_formKey.currentState!.validate()) {
                      // Handle task creation logic here
                      final newTask = TaskModel(
                        id: 'new_id', // Generate or assign a unique ID
                        name: _nameController.text,
                        description: '',
                        statusEnum: StatusEnum.inProgress,
                        priorityEnum: PriorityEnum.normal,
                        dueDate: null,
                        createdDate: DateTime.now(),
                        lastUpdatedDate: DateTime.now(),
                        authorUserId: curAuthUser.id,                            
                        parentTeamId:
                            'current_team_id', // Replace with actual team ID
                        parentProjectId:
                            'current_project_id', // Replace with actual project ID
                      );
                      // Add the new task to the database or state management
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                  ),
                  child: const Text('Create Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
