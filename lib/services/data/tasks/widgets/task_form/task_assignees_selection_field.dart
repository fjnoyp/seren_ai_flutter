import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/cur_task_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/cur_task_selection_options_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_user_assignments_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_form/selection_field.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

class TaskAssigneesSelectionField extends HookConsumerWidget {
  const TaskAssigneesSelectionField({
    super.key,
    required this.enabled,
  });

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curTaskAssignees = ref.watch(curTaskAssigneesProvider);

    //updateAssignees(Set<UserModel>? assignees) => ref.read(curTaskProvider.notifier).updateAssignees(assignees);

    final curProject = ref.watch(curTaskProjectProvider);

    return SelectionField<List<UserModel>>(
      labelWidget: const Icon(Icons.person),
      validator: (assignees) => assignees == null || assignees.isEmpty
          ? 'Assignees are required'
          : null,
      valueToString: (assignees) => assignees?.isEmpty == null
          ? 'Choose Assignees'
          : assignees!.map((assignment) => assignment.email).join(', '),
      enabled: enabled && curProject != null,
      value: curTaskAssignees,
      onValueChanged3: (ref, assignees) =>
          ref.read(curTaskProvider.notifier).updateAssignees(assignees),
      showSelectionModal: (BuildContext context,
          void Function(WidgetRef, List<UserModel>)? onValueChanged3) async {
        showModalBottomSheet<List<UserModel>>(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return TaskAssigneesSelectionModal(
              initialSelectedUsers: curTaskAssignees,
              onAssigneesChanged:
                  (WidgetRef ref, List<UserModel> newAssignees) {
                ref
                    .read(curTaskProvider.notifier)
                    .updateAssignees(newAssignees);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}

class TaskAssigneesSelectionModal extends HookConsumerWidget {
  final List<UserModel> initialSelectedUsers;
  final void Function(WidgetRef, List<UserModel>) onAssigneesChanged;

  const TaskAssigneesSelectionModal({
    super.key,
    required this.initialSelectedUsers,
    required this.onAssigneesChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentlySelectedUsers = useState(initialSelectedUsers);
    final watchedSelectableUsers = ref.watch(curTaskSelectionOptionsProvider
        .select((state) => state.selectableUsers));

    final curProject = ref.watch(curTaskProjectProvider);

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
                maxHeight: MediaQuery.of(context).size.height *
                    0.5, // 50% of screen height
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
