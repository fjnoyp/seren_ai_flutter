import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/tasks_by_project_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/inline_creation/cur_inline_creating_task_id_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/inline_creation/inline_task_creation_button.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_list_item_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_filter_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

class _TasksList extends StatelessWidget {
  const _TasksList({
    required this.tasks,
    this.horizontalDragOffsetToChangeStatus,
  });

  final List<TaskModel> tasks;

  /// The horizontal drag offset to change the status of the task.
  /// If the offset is greater than this value, the task will be moved to the next status.
  ///
  /// If this value is null, the task item will not be draggable.
  final double? horizontalDragOffsetToChangeStatus;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: tasks.length,
      itemBuilder: (context, index) => horizontalDragOffsetToChangeStatus ==
              null
          ? TaskListItemView(task: tasks[index])
          : LayoutBuilder(
              builder: (context, constraints) {
                return Consumer(
                  builder: (context, ref, _) {
                    final task = tasks[index];
                    final curStatus = task.status!;
                    double initialPosition = 0;
                    return Listener(
                      onPointerDown: (details) {
                        initialPosition = details.localPosition.dx;
                      },
                      onPointerUp: (details) {
                        final offset =
                            details.localPosition.dx - initialPosition;
                        if (offset > horizontalDragOffsetToChangeStatus! * 2) {
                          ref.read(tasksRepositoryProvider).updateTaskStatus(
                              task.id, curStatus.nextStatus.nextStatus);
                        } else if (offset >
                            horizontalDragOffsetToChangeStatus!) {
                          ref
                              .read(tasksRepositoryProvider)
                              .updateTaskStatus(task.id, curStatus.nextStatus);
                        } else if (offset <
                            -horizontalDragOffsetToChangeStatus! * 2) {
                          ref.read(tasksRepositoryProvider).updateTaskStatus(
                              task.id, curStatus.previousStatus.previousStatus);
                        } else if (offset <
                            -horizontalDragOffsetToChangeStatus!) {
                          ref.read(tasksRepositoryProvider).updateTaskStatus(
                              task.id, curStatus.previousStatus);
                        }
                      },
                      child: Draggable(
                        feedback: Material(
                          child: SizedBox(
                            width: constraints.maxWidth,
                            child: TaskListItemView(task: task),
                          ),
                        ),
                        child: TaskListItemView(task: task),
                      ),
                    );
                  },
                );
              },
            ),
      separatorBuilder: (context, index) => Divider(
        color: Theme.of(context).dividerColor.withAlpha(38),
      ),
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

    final curInlineCreatingTaskId = ref.watch(curInlineCreatingTaskIdProvider);

    final tasks = ref
            .watch(tasksByProjectStreamProvider(projectId))
            .valueOrNull
            ?.where((task) =>
                filterState.filterCondition(task) ||
                task.id == curInlineCreatingTaskId)
            .toList() ??
        [];

    if (filterState.sortComparator != null) {
      tasks.sort(filterState.sortComparator);
    }

    return Row(
      children: StatusEnum.values
          .where((status) =>
              status != StatusEnum.cancelled && status != StatusEnum.archived)
          .map(
        (status) {
          final filteredTasks =
              tasks.where((task) => task.status == status).toList();
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
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return _TasksList(
                            tasks: filteredTasks,
                            horizontalDragOffsetToChangeStatus:
                                constraints.maxWidth,
                          );
                        },
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  SizedBox(
                    width: double.infinity,
                    child: InlineTaskCreationButton(
                      // additionalFields: const [TaskFieldEnum.assignees],
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
