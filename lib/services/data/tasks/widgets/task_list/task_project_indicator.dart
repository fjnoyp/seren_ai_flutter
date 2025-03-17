import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/generate_color_from_id.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/project_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

class TaskProjectIndicator extends ConsumerWidget {
  const TaskProjectIndicator(this.task, {super.key});

  final TaskModel task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, _) {
        final taskProject =
            ref.watch(projectByIdStreamProvider(task.parentProjectId));
        if (taskProject.valueOrNull == null) return const SizedBox.shrink();

        return Text(
          taskProject.valueOrNull!.name,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: generateColorFromId(task.parentProjectId),
                fontSize: 11,
              ),
        );
      },
    );
  }
}
