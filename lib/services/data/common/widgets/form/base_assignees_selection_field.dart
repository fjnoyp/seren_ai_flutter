import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/selection_field.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/users_in_project_listener_provider.dart';

class BaseAssigneesSelectionField extends HookConsumerWidget {
  final bool enabled;
  final ProviderListenable<List<UserModel>> assigneesProvider;
  final ProviderListenable<ProjectModel?> projectProvider;
  final Function(WidgetRef, List<UserModel>) updateAssignees;
  //final ProviderListenable<List<UserModel>> selectableUsersProvider;
  const BaseAssigneesSelectionField({
    super.key,
    required this.enabled,
    required this.assigneesProvider,
    required this.projectProvider,
    required this.updateAssignees,
    //required this.selectableUsersProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curAssignees = ref.watch(assigneesProvider);
    final curProject = ref.watch(projectProvider);

    return AnimatedSelectionField<List<UserModel>>(
      labelWidget: const Icon(Icons.person),
      // validator: (assignees) => assignees == null || assignees.isEmpty
      //     ? 'Assignees are required'
      //     : null,
      valueToString: (assignees) => assignees?.isEmpty == true
          ? 'Choose Assignees'
          : assignees!.map((assignment) => assignment.email).join(', '),
      enabled: enabled && curProject != null,
      value: curAssignees,
      onValueChanged: updateAssignees,
      showSelectionModal: (BuildContext context) async {
        showModalBottomSheet<List<UserModel>>(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return AssigneesSelectionModal(
              initialSelectedUsers: curAssignees,
              onAssigneesChanged: updateAssignees,
              //selectableUsersProvider: selectableUsersProvider,
              projectProvider: projectProvider,
            );
          },
        );
      },
    );
  }
}

class AssigneesSelectionModal extends HookConsumerWidget {
  final List<UserModel> initialSelectedUsers;
  final void Function(WidgetRef, List<UserModel>) onAssigneesChanged;
  //final ProviderListenable<List<UserModel>> selectableUsersProvider;
  final ProviderListenable<ProjectModel?> projectProvider;

  const AssigneesSelectionModal({
    super.key,
    required this.initialSelectedUsers,
    required this.onAssigneesChanged,
    //required this.selectableUsersProvider,
    required this.projectProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentlySelectedUsers = useState(initialSelectedUsers);
    
    final curProject = ref.watch(projectProvider);

    if(curProject == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final watchedSelectableUsers = ref.watch(usersInProjectListenerProvider(curProject.id));

    if(watchedSelectableUsers == null) {
      return const Center(child: CircularProgressIndicator());
    }

    

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Only users in '),
                Text(curProject!.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text(' can be assigned'),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                // Add logic to add more users to the current project
              },
              child: Text('Add Users to ${curProject!.name}'),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.builder(
                itemCount: watchedSelectableUsers.length,
                itemBuilder: (context, index) {
                  final user = watchedSelectableUsers[index];
                  final isSelected =
                      currentlySelectedUsers.value.contains(user);
                  return ListTile(
                    title: Text(user.email),
                    leading: Checkbox(
                      value: isSelected,
                      onChanged: (bool? value) {
                        if (value != null) {
                          final updatedUsers = List<UserModel>.from(
                              currentlySelectedUsers.value);
                          if (value) {
                            updatedUsers.add(user);
                          } else {
                            updatedUsers.remove(user);
                          }
                          currentlySelectedUsers.value = updatedUsers;
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                onAssigneesChanged(ref, currentlySelectedUsers.value);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
