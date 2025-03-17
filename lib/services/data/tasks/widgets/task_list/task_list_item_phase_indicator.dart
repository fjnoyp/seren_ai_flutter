import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/generate_color_from_id.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_tag.dart';

class TaskListItemPhaseIndicator extends ConsumerWidget {
  const TaskListItemPhaseIndicator(this.task, {super.key});

  final TaskModel task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (parentTaskId, parentTaskName) = task.parentTaskId != null
        ? ref.watch(taskByIdStreamProvider(task.parentTaskId!)
            .select((task) => (task.value?.id ?? '', task.value?.name ?? '')))
        : ('', '');

    return task.isPhase
        ? TaskTag.phase(outlined: true, isLarge: false)
        : parentTaskId.isNotEmpty
            ? TaskTag.custom(
                text: parentTaskName,
                color: generateColorFromId(parentTaskId),
                outlined: true,
                isLarge: false,
              )
            : const SizedBox.shrink();
  }
}
