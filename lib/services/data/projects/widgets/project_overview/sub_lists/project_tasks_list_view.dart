import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/tasks_by_project_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_list_item_view.dart';

class ProjectTasksListView extends ConsumerWidget {
  const ProjectTasksListView({
    super.key,
    this.filterCondition,
  });

  final bool Function(TaskModel)? filterCondition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectId = ref.watch(curSelectedProjectIdNotifierProvider);
    if (projectId == null) return const SizedBox.shrink();

    return AsyncValueHandlerWidget(
      value: ref.watch(tasksByProjectStreamProvider(projectId)),
      data: (tasks) {
        final filteredTasks = tasks
                ?.where(
                    (task) => filterCondition == null || filterCondition!(task))
                .toList() ??
            [];

        // Sort by most recently updated
        filteredTasks.sort((a, b) => (b.updatedAt ??
                DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0)));

        return ListView.separated(
          shrinkWrap: true,
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) =>
              TaskListTileItemView(filteredTasks[index]),
          separatorBuilder: (context, index) => const Divider(height: 1),
        );
      },
    );
  }
}
