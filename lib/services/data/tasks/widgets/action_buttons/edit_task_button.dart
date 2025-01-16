import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_editing_task_id_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_page.dart';

// Triggers edit of current task
class EditTaskButton extends ConsumerWidget {
  const EditTaskButton(this.taskId, {super.key});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        // remove self from stack
        ref.read(navigationServiceProvider).pop();
        ref.read(curEditingTaskIdNotifierProvider.notifier).setTaskId(taskId);
        openTaskPage(context, ref, mode: EditablePageMode.edit);
      },
    );
  }
}
