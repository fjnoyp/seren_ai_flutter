import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/tasks_by_project_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_field_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/inline_task_creation_widget.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_list_item_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_filter_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

class _TasksList extends StatelessWidget {
  const _TasksList({
    required this.tasks,
    Key? key,
  }) : super(key: key);

  final List<TaskModel> tasks;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final isLast = index == tasks.length - 1;
        return Column(
          children: [
            TaskListItemView(task: tasks[index]),
            if (!isLast) // Don't add divider after last item
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Divider(
                  color: Theme.of(context).dividerColor.withOpacity(0.15),
                  height: 1,
                ),
              ),
          ],
        );
      },
    );
  }
}

class ProjectTasksBoardView extends ConsumerWidget {
  const ProjectTasksBoardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectId = ref.watch(curSelectedProjectIdNotifierProvider);
    if (projectId == null) return const SizedBox.shrink();

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
                      child: _TasksList(tasks: filteredTasks),
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
