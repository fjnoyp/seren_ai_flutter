import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/string_extensions.dart';
import 'package:seren_ai_flutter/services/data/projects/cur_user_viewable_projects_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/teams/cur_team/cur_user_viewable_teams_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/users_in_project_read_provider.dart';

Widget TeamSelectFormField(
    WidgetRef ref, ValueNotifier<TeamModel?> teamController, {bool enabled = true}) {
  final watchedTeams = ref.watch(curUserViewableTeamsListenerProvider);

  return ModalSelectFormField<TeamModel>(
    controller: teamController,
    emptyValue: 'Select a Team',
    labelWidget: SizedBox(
        width: 60,
        child:
            const Text('Team', style: TextStyle(fontWeight: FontWeight.bold))),
    options: watchedTeams ?? [],
    optionLabel: (team) => team.name,
    validator: (team) => team == null ? 'Team is required' : null,
    enabled: enabled,
  );
}

Widget ProjectSelectFormField(
    WidgetRef ref, ValueNotifier<ProjectModel?> projectController, {bool enabled = true, String emptyValue = 'Select a Project'}) {
  final watchedProjects = ref.watch(curUserViewableProjectsListenerProvider);

  return ModalSelectFormField<ProjectModel>(
    controller: projectController,
    emptyValue: emptyValue,
    labelWidget: SizedBox(
        width: 60,
        child: const Text('Project',
            style: TextStyle(fontWeight: FontWeight.bold))),
    options: watchedProjects ?? [],
    optionLabel: (project) => project.name,
    validator: (project) => project == null ? 'Project is required' : null,
    enabled: enabled,
  );
}


Widget TaskDateSelectFormField(ValueNotifier<DateTime?> dateController, {bool enabled = true}) {
  return DateSelectFormField(
    controller: dateController,
    emptyValue: 'Set Due Date',
    labelWidget: const Icon(Icons.date_range),
    validator: (date) => date == null ? 'Due date is required' : null,
    enabled: enabled,
  );
}

Widget TaskStatusSelectFormField(ValueNotifier<StatusEnum?> statusController, {bool enabled = true}) {
  return ModalSelectFormField<StatusEnum>(
    controller: statusController,
    emptyValue: 'Select Status',
    labelWidget: const Icon(Icons.flag),
    options: StatusEnum.values,
    optionLabel: (status) => status.toString().enumToHumanReadable,
    validator: (status) => status == null ? 'Status is required' : null,
    enabled: enabled,
  );
}

Widget TaskPrioritySelectFormField(
    ValueNotifier<PriorityEnum?> priorityController, {bool enabled = true}) {
  return ModalSelectFormField<PriorityEnum>(
    controller: priorityController,
    emptyValue: 'Select Priority',
    labelWidget: const Icon(Icons.priority_high),
    options: PriorityEnum.values,
    optionLabel: (priority) => priority.toString().enumToHumanReadable,
    validator: (priority) => priority == null ? 'Priority is required' : null,
    enabled: enabled,
  );
}

// === TASK DESCRIPTION ===

class TaskDescriptionFormField extends ActionSelectFormField<String> {
  TaskDescriptionFormField(
    ValueNotifier<String?> controller, {
    super.key,
  }) : super(
          controller: controller,
          emptyValue: 'Write Description',
          labelWidget: const Icon(Icons.description),
          validator: (description) => description == null || description.isEmpty
              ? 'Description is required'
              : null,
          //options: [], // Not used for description
          optionLabel: (description) => description,
          showSelectionUI: (BuildContext context) async {
            return showModalBottomSheet<String>(
              context: context,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return TaskDescriptionWritingModal(
                  initialDescription: controller.value ?? '',
                  onDescriptionChanged: (String newDescription) {
                    //Navigator.pop(context, newDescription);
                    controller.value = newDescription;
                  },
                );
              },
            );
          },
        );
}

class TaskDescriptionWritingModal extends HookWidget {
  final String initialDescription;
  final Function(String) onDescriptionChanged;

  const TaskDescriptionWritingModal({
    Key? key,
    required this.initialDescription,
    required this.onDescriptionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final descriptionController =
        useTextEditingController(text: initialDescription);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter description here...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                onDescriptionChanged(descriptionController.text);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

// === TASK ASSIGNEES ===

class TaskAssigneesFormField extends ActionSelectFormField<Set<UserModel>> {
  TaskAssigneesFormField(
    {required ValueNotifier<Set<UserModel>?> controller, 
    required ValueNotifier<ProjectModel?> projectController,
    String emptyValue = 'Choose Assignees',
    super.enabled,
    super.key,
  }) : super(
          controller: controller,
          emptyValue: emptyValue,
          labelWidget: const Icon(Icons.person),
          //options: [], // Not used for assignees
          optionLabel: (assignees) =>
              assignees.isEmpty ? 'Choose Assignees' : assignees.map((user) => user.email).join(', '),
          validator: (assignees) => assignees == null || assignees.isEmpty
              ? 'Assignees are required'
              : null,
          showSelectionUI: (BuildContext context) async {
            return showModalBottomSheet<Set<UserModel>>(
              context: context,
              builder: (BuildContext context) {
                return TaskAssigneesSelectionModal(
                  initialSelectedUsers: controller.value ?? Set<UserModel>(),                  
                  projectController: projectController,
                  onUsersSelected: (Set<UserModel> selectedUsers) {
                    controller.value = selectedUsers;
                  },
                );
              },
            );
          },
        );
}

class TaskAssigneesSelectionModal extends HookConsumerWidget {
  final Set<UserModel> initialSelectedUsers;
  final Function(Set<UserModel>) onUsersSelected;  
  final ValueNotifier<ProjectModel?> projectController;

  const TaskAssigneesSelectionModal({
    Key? key,
    required this.initialSelectedUsers,
    required this.onUsersSelected,
    required this.projectController,
  }) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    if(projectController.value == null) {
      return const Center(child: Text('Select a Project first'));
    }
    final curProject = projectController.value!;
    final curProjectId = curProject.id;
    final usersInProject = ref.watch(usersInProjectReadProvider(curProjectId));

    final searchController = useTextEditingController();
    final currentlySelectedUsers = useState<Set<UserModel>>(initialSelectedUsers);

    if (usersInProject.isLoading) {
      return const CircularProgressIndicator();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Only users in '),
              Text(curProject.name, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(' can be assigned'),
            ],
          ),
          /*
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search',
              border: OutlineInputBorder(),
            ),
          ),
          */
          ElevatedButton(
            onPressed: () {
              // Add logic to add more users to the current project
            },
            child: Text('Add Users to ${curProject.name}'),
          ),
          Expanded(
              child: usersInProject.when(
                data: (users) {
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final isSelected = currentlySelectedUsers.value.contains(user);
                      return ListTile(
                        title: Text(user.email),
                        //subtitle: Text(user.email),
                        leading: Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            if (value != null) {
                            final updatedUsers = Set<UserModel>.from(currentlySelectedUsers.value);
                              if (value) {
                                updatedUsers.add(user);
                              } else {
                                updatedUsers.remove(user);
                              }
                              currentlySelectedUsers.value = updatedUsers;
                              onUsersSelected(updatedUsers);
                            }
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
          ),
        ],
      ),
    );
  }
}

// === BASE CLASSES ===

class ActionSelectFormField<T> extends FormField<T> {
  ActionSelectFormField({
    super.key,
    super.initialValue,
    required ValueNotifier<T?> controller,
    required String emptyValue,
    required Widget labelWidget,
    //required List<T> options,
    required String Function(T) optionLabel,
    required Future<T?> Function(BuildContext) showSelectionUI,
    super.onSaved,
    validator,
    super.enabled, 
    //super.validator,
  }) : super(
          builder: (FormFieldState<T> state) {
            return Row(
              children: [
                labelWidget,
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(

                    onPressed: enabled ? () async {
                      final result = await showSelectionUI(state.context);
                      if (result != null) {
                        state.didChange(result);
                        controller.value = result;
                        //state.validate();
                      }
                    } : null,
                    style: TextButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 10),
                    ),
                    child: ValueListenableBuilder<T?>(
                      valueListenable: controller,                      
                      builder: (context, value, child) {
                        return Text(
                          value == null ? emptyValue : optionLabel(value),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(state.context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: state.hasError ? Colors.red : null,
                                backgroundColor: enabled ? null : Colors.grey[200],
                              ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
          // TODO: bug from FormField causes validator to always be called with null regardless of controller value ... 
          validator: (_) {
            //print('Controller: ${controller.value}');
            //print('Validator: $value');
            return validator(controller.value);
            //return null; 
          },
        );
}

class ModalSelectFormField<T> extends ActionSelectFormField<T> {
  ModalSelectFormField({
    super.key,
    super.initialValue,
    required super.controller,
    required super.emptyValue,
    required super.labelWidget,
    required List<T> options,
    required super.optionLabel,
    super.onSaved,
    super.validator,
    super.enabled,
  }) : super(
          showSelectionUI: (BuildContext context) async {
            return showModalBottomSheet<T>(
              context: context,
              builder: (BuildContext context) {
                return ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final T option = options[index];
                    return ListTile(
                      title: Text(optionLabel(option)),
                      onTap: () {
                        Navigator.pop(context, option);
                      },
                    );
                  },
                );
              },
            );
          },
        );
}

class DateSelectFormField extends ActionSelectFormField<DateTime> {
  DateSelectFormField({
    super.key,
    super.initialValue,
    required super.controller,
    required super.emptyValue,
    required super.labelWidget,
    super.onSaved,
    super.validator,
    super.enabled,
  }) : super(
          //options: [], // Not used for date picker
          optionLabel: (date) =>
              date.toString(), // You might want to format this
          showSelectionUI: (BuildContext context) async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            return picked;
          },
        );
}
