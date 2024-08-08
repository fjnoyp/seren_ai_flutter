import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/cur_task_provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class TaskNameField extends HookConsumerWidget {
  const TaskNameField({
    super.key,
    required this.enabled,
  });

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curTaskName = ref.watch(curTaskProvider.select((state) => state.task.name));
    final nameController = useTextEditingController(text: curTaskName);

    // Must manually update the controller's text when the task name changes    
    useEffect(() {
    nameController.text = curTaskName;
    return null;
  }, [curTaskName]);
    
    return TextField(
      controller: nameController,
      enabled: enabled,
        
      onEditingComplete: () {
        ref.read(curTaskProvider.notifier).updateTask(
          ref.read(curTaskProvider).task.copyWith(name: nameController.text)
        );
      },
      decoration: InputDecoration(
        hintText: 'Enter task name',
        errorText: curTaskName.isEmpty ? 'Task name is required' : null,
      ),
    );
  }
}
