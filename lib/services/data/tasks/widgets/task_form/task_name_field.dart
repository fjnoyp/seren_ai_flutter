import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/cur_task_provider.dart';

class TaskNameField extends ConsumerWidget {
  const TaskNameField({
    super.key,
    required this.enabled,
  });

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curTaskName = ref.watch(curTaskProvider.select((state) => state.task.name));
    
    return TextFormField(
      initialValue: curTaskName,
      enabled: enabled,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Task name is required';
        }
        return null;
      },
      onChanged: (newName) {
        ref.read(curTaskProvider.notifier).updateTask(
          ref.read(curTaskProvider).task.copyWith(name: newName)
        );
      },
    );
  }
}
