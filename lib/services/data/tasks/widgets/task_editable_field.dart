import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/string_extensions.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

// TODO: reduce code duplication once UI flows are confirmed 
// Combine with task_editable_meta_field


/// A row with an icon and text that can be selected by the user.
/// Displays an editable field of a task. 
class TaskEditableField extends StatelessWidget {
  final IconData iconData;
  final VoidCallback onPressed;
  final String text;
  final bool? hasError;

  const TaskEditableField({
    Key? key,
    required this.iconData,
    required this.onPressed,
    required this.text,
    this.hasError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            iconData,
            color: hasError ?? false ? Colors.red : null,
          ),
          Expanded(
            child: TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 10),
              ),
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: hasError ?? false ? Colors.red : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskDateEditableField extends HookConsumerWidget {
  final Function(DateTime?) onDateSelected;
  final DateTime? selectedDate;
  final bool? hasError;

  const TaskDateEditableField({
    Key? key,
    required this.onDateSelected,
    this.selectedDate,
    this.hasError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    void _selectDate() async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      );
      if (picked != null && picked != selectedDate) {        
        onDateSelected(picked);
      }
    }

    String _getDisplayText() {
      if (selectedDate == null) {
        return 'Set Due Date';
      } else {
        return '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
      }
    }

    return TaskEditableField(
      iconData: Icons.calendar_today,
      onPressed: _selectDate,
      text: _getDisplayText(),
      hasError: hasError,
    );
  }
}

class TaskStatusEditableField extends HookConsumerWidget {
  final Function(StatusEnum) onStatusSelected;
  final StatusEnum? selectedStatus;
  final bool? hasError;

  const TaskStatusEditableField({
    super.key,
    required this.onStatusSelected,
    this.selectedStatus,
    this.hasError,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void selectStatus() {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return TaskStatusSelectionModal(
            initialSelectedStatus: selectedStatus,
            onStatusSelected: onStatusSelected,
          );
        },
      );
    }

    String getDisplayText() {
      return selectedStatus?.toString().enumToHumanReadable ?? 'Select Status';
    }

    return TaskEditableField(
      iconData: Icons.flag,
      onPressed: selectStatus,
      text: getDisplayText(),
      hasError: hasError,
    );
  }
}

class TaskStatusSelectionModal extends HookWidget {
  final StatusEnum? initialSelectedStatus;
  final Function(StatusEnum) onStatusSelected;

  const TaskStatusSelectionModal({
    Key? key,
    required this.initialSelectedStatus,
    required this.onStatusSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: StatusEnum.values.map((status) {
          return ListTile(
            title: Text(status.toString().enumToHumanReadable),
            leading: Radio<StatusEnum>(
              value: status,
              groupValue: initialSelectedStatus,
              onChanged: (StatusEnum? value) {
                if (value != null) {
                  onStatusSelected(value);
                  Navigator.pop(context);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class TaskPriorityEditableField extends HookConsumerWidget {
  final Function(PriorityEnum) onPrioritySelected;
  final PriorityEnum? selectedPriority;
  final bool? hasError;

  const TaskPriorityEditableField({
    super.key,
    required this.onPrioritySelected,
    this.selectedPriority,
    this.hasError,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void selectPriority() {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return TaskPrioritySelectionModal(
            initialSelectedPriority: selectedPriority,
            onPrioritySelected: onPrioritySelected,
          );
        },
      );
    }

    String getDisplayText() {
      return selectedPriority?.toString().enumToHumanReadable ?? 'Select Priority';
    }

    return TaskEditableField(
      iconData: Icons.priority_high,
      onPressed: selectPriority,
      text: getDisplayText(),
      hasError: hasError,
    );
  }
}

class TaskPrioritySelectionModal extends HookWidget {
  final PriorityEnum? initialSelectedPriority;
  final Function(PriorityEnum) onPrioritySelected;

  const TaskPrioritySelectionModal({
    Key? key,
    required this.initialSelectedPriority,
    required this.onPrioritySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: PriorityEnum.values.map((priority) {
          return ListTile(
            title: Text(priority.toString().enumToHumanReadable),
            leading: Radio<PriorityEnum>(
              value: priority,
              groupValue: initialSelectedPriority,
              onChanged: (PriorityEnum? value) {
                if (value != null) {
                  onPrioritySelected(value);
                  Navigator.pop(context);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}


class TaskDescriptionEditableField extends HookConsumerWidget {
  final Function(String) onDescriptionChanged;
  final String description;
  final bool? hasError;

  const TaskDescriptionEditableField({
    Key? key,
    required this.onDescriptionChanged,
    this.description = '',
    this.hasError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TaskEditableField(
      iconData: Icons.description,
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return TaskDescriptionWritingMOdal(
              initialDescription: description,
              onDescriptionChanged: onDescriptionChanged,
            );
          },
        );
      },
      text: description.isEmpty ? 'Write Description' : description,
      hasError: hasError,
    );
  }
}

class TaskDescriptionWritingMOdal extends HookWidget {
  final String initialDescription;
  final Function(String) onDescriptionChanged;

  const TaskDescriptionWritingMOdal({
    Key? key,
    required this.initialDescription,
    required this.onDescriptionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final descriptionController = useTextEditingController(text: initialDescription);

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


class TaskAssigneesEditableField extends HookConsumerWidget {
  final Function(List<String>) onAssigneesSelected;
  final List<String> selectedUsers;
  final bool? hasError;

  const TaskAssigneesEditableField({
    super.key,
    required this.onAssigneesSelected,
    required this.selectedUsers,
    this.hasError,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return TaskEditableField(
      iconData: Icons.person,
      onPressed: () => {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return TaskAssigneesSelectionModal(
              initialSelectedUsers: selectedUsers,
              onUsersSelected: onAssigneesSelected,
            );
          },
        )
      },
      text: selectedUsers.isEmpty
          ? 'Choose Assignees'
          : selectedUsers.join(', '),
      hasError: hasError,
    );
  }
}

class TaskAssigneesSelectionModal extends HookWidget {
  final List<String> initialSelectedUsers;
  final Function(List<String>) onUsersSelected;

  const TaskAssigneesSelectionModal({
    Key? key,
    required this.initialSelectedUsers,
    required this.onUsersSelected,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final currentlySelectedUsers = useState<List<String>>(initialSelectedUsers);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search',
              border: OutlineInputBorder(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Assuming you have a list of 10 temp strings
              itemBuilder: (context, index) {
                final user = 'Temp String ${index + 1}';
                final isSelected = currentlySelectedUsers.value.contains(user);
                return ListTile(
                  title: Text(user),
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: (bool? value) {
                      if (value != null) {
                        final updatedUsers =
                            List<String>.from(currentlySelectedUsers.value);
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
            ),
          ),
        ],
      ),
    );
  }
}
