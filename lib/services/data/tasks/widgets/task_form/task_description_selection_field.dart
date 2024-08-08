
// === TASK DESCRIPTION ===
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_form/selection_field.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/cur_task_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_form/selection_field.dart';

class TaskDescriptionSelectionField extends ConsumerWidget {
  const TaskDescriptionSelectionField({
    super.key,
    required this.enabled,
  });

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curTaskDescription = ref.watch(curTaskProvider.select((state) => state.task.description));

    return SelectionField<String>(
      labelWidget: const Icon(Icons.description),
      validator: (description) => description == null || description.isEmpty
          ? 'Description is required'
          : null,
      valueToString: (description) => description ?? 'Enter Description',
      enabled: enabled,
      value: curTaskDescription,      
      onValueChanged3: (ref, description) => ref.read(curTaskProvider.notifier).updateTask(ref.read(curTaskProvider).task.copyWith(description: description)),
      showSelectionModal: (BuildContext context, void Function(WidgetRef, String)? onValueChanged3) async {
         showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return TaskDescriptionWritingModal(
              initialDescription: curTaskDescription ?? '',
              onDescriptionChanged: (WidgetRef ref, String newDescription) {
                ref.read(curTaskProvider.notifier).updateTask(ref.read(curTaskProvider).task.copyWith(description: newDescription));
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}

class TaskDescriptionWritingModal extends HookWidget {
  final String initialDescription;
  final void Function(WidgetRef, String) onDescriptionChanged;

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
            Consumer(builder: (context, ref, child) {
              return ElevatedButton(
                onPressed: () {
                onDescriptionChanged(ref, descriptionController.text);
                //Navigator.pop(context);
              },
              child: const Text('Save'),
            );
            }),
          ],
        ),
      ),
    );
  }
}
