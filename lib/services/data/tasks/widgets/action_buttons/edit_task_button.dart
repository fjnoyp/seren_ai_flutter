import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_page.dart';

// Triggers edit of current task
class EditTaskButton extends ConsumerWidget {
  const EditTaskButton(this.taskId, {super.key});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      style: isWebVersion
          ? IconButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.secondary,
              iconSize: 18,
            )
          : null,
      icon: const Icon(Icons.edit),
      onPressed: () => openTaskPage(
        ref,
        mode: EditablePageMode.edit,
        initialTaskId: taskId,
      ),
    );
  }
}
