import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/tasks_by_project_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_field_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/inline_task_creation_widget.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_list_item_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_filter_state_provider.dart';

class ProjectTasksBoardView extends ConsumerWidget {
  const ProjectTasksBoardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectId = ref.watch(curSelectedProjectIdNotifierProvider);
    if (projectId == null) return const SizedBox.shrink();

    // We should ideally separate out the common sort/filter logic
    // for the sectioned view and board view as well since we're duplicating that
    // between both those views at the moment.
    final filterState = ref.watch(taskFilterStateProvider);

    final tasks = ref
            .watch(tasksByProjectStreamProvider(projectId))
            .valueOrNull
            ?.where(filterState.filterCondition)
            .toList() ??
        [];

    if (filterState.sortComparator != null) {
      tasks.sort(filterState.sortComparator);
    }

    final curInlineCreatingTaskId = ref.watch(curInlineCreatingTaskIdProvider);

    return Row(
      children: StatusEnum.values
          .where((status) =>
              status != StatusEnum.cancelled && status != StatusEnum.archived)
          .map(
        (status) {
          final filteredTasks = tasks
              .where((task) =>
                  task.status == status && task.id != curInlineCreatingTaskId)
              .toList();
          return Expanded(
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      status.toHumanReadable(context),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.builder(
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          return TaskListItemView(task: filteredTasks[index]);
                        },
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  SizedBox(
                    width: double.infinity,
                    child: InlineTaskCreationWidget(
                      additionalFields: const [TaskFieldEnum.assignees],
                      initialStatus: status,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ).toList(),
    );
  }
}
