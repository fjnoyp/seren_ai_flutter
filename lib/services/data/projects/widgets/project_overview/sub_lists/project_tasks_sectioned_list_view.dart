import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_overview/sub_lists/create_task_button.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/tasks_by_project_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/inline_creation/cur_inline_creating_task_id_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/inline_creation/inline_task_creation_button.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_filter_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_list_tile_item_view.dart';

class ProjectTasksSectionedListView extends ConsumerWidget {
  const ProjectTasksSectionedListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectId = ref.watch(curSelectedProjectIdNotifierProvider);
    if (projectId == null) return const SizedBox.shrink();

    // We should ideally separate out the common sort/filter logic
    // for the sectioned view and board view as well since we're duplicating that
    // between both those views at the moment.
    final filterState = ref.watch(taskFilterStateProvider);

    final curInlineCreatingTaskId = ref.watch(curInlineCreatingTaskIdProvider);

    return AsyncValueHandlerWidget(
      value: ref.watch(tasksByProjectStreamProvider(projectId)),
      data: (tasks) {
        return SingleChildScrollView(
          child: Column(children: [
            CreateTaskButton(
              initialProjectId: projectId,
              initialStatus: StatusEnum.open,
            ),
            ...StatusEnum.values.map(
              (status) {
                final filteredTasks = tasks
                        ?.where((task) =>
                            task.status == status &&
                                filterState.filterCondition(task) ||
                            task.id == curInlineCreatingTaskId)
                        .toList() ??
                    [];

                if (filterState.sortComparator != null) {
                  filteredTasks.sort(filterState.sortComparator);
                }

                return Card(
                  child: ExpansionTile(
                    initiallyExpanded: filteredTasks.isNotEmpty,
                    title: Text(status.toHumanReadable(context)),
                    expandedAlignment: Alignment.centerLeft,
                    shape: const Border(),
                    childrenPadding: const EdgeInsets.only(bottom: 24),
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) =>
                            TaskListTileItemView(filteredTasks[index]),
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: InlineTaskCreationButton(
                          // additionalFields: const [
                          //   TaskFieldEnum.assignees,
                          //   TaskFieldEnum.priority,
                          // ],
                          initialStatus: status,
                        ),
                      ),
                      // ListTile(
                      //   dense: true,
                      //   onTap: () =>
                      //       ref.read(taskNavigationServiceProvider).openNewTask(
                      //             initialProjectId: projectId,
                      //             initialStatus: status,
                      //           ),
                      //   leading: const SizedBox.shrink(),
                      //   title: Text(
                      //     AppLocalizations.of(context)!.createNewTask,
                      //     style: TextStyle(
                      //         color: Theme.of(context).colorScheme.outline),
                      //   ),
                      // ),
                    ],
                  ),
                );
              },
            ),
          ]),
        );
      },
    );
  }
}
